//
//  Network.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/30.
//

import Foundation
import NetworkExtension
import os.signpost

class SockHandler : NSCondition {
    
    class RingBuffer:NSCondition {
        let array:UnsafeMutablePointer<UInt8>
        var block = DispatchSemaphore(value: 0)
        var sizeMax:Int
        var writeHead = 0
        var readHead = 0
        var full = false
        init(_ size: Int) {
            sizeMax = size
            array = UnsafeMutablePointer.allocate(capacity: sizeMax)
        }
    
        deinit {
            array.deallocate()
        }
        func write(_ buf: UnsafeRawPointer, _ size: Int) -> Bool{
            let available = self.available
            if size > available{
                return false
            }else if size == available{
                full = true
            }
            var buf = buf.assumingMemoryBound(to: UInt8.self)
            let toEnd = sizeMax-writeHead
            if toEnd < size{
                array.advanced(by: writeHead).assign(from: buf, count: toEnd)
                buf = buf.advanced(by: toEnd)
                array.assign(from: buf, count: size-toEnd)
            }else{
                array.advanced(by: writeHead).assign(from: buf, count: size)
            }
            
            writeHead=(writeHead+size)%sizeMax
            broadcast()
            return true
        }
        func copyTo(_ buf: UnsafeMutableRawPointer, _ size: Int) -> Int{
            if size<1 || isEmpty {
                return 0
            }
            let size = min(size, current)
            var buf = buf.assumingMemoryBound(to: UInt8.self)
            let array = self.array.advanced(by: readHead)
            let toEnd = sizeMax-readHead
            if toEnd < size{
                buf.assign(from: array, count: toEnd)
                buf = buf.advanced(by: toEnd)
                buf.assign(from: self.array, count: size-toEnd)
            }else{
                buf.assign(from: array, count: size)
            }
            
            full = false
            readHead=(readHead+size)%sizeMax
            broadcast()
            
            return size
        }
        var available:Int{
            if full{
                return 0
            }
            if readHead == writeHead{
                return sizeMax
            } else if readHead > writeHead{
                return readHead - writeHead
            }
            return sizeMax - writeHead + readHead
        }
        var isEmpty:Bool{
            return writeHead == readHead && !full
        }
        var current:Int{
            return sizeMax - available
        }
    }
    
    let sp = salloc(SOCK.self)
    var s:SOCK{
        get {
            return sp.pointee
        }
        set {
            sp.pointee = newValue
        }
    }
    var hostname:String
    //var param:NWTLSParameters
    static var count = 0
    var count = SockHandler.count
    var tcp:NWTCPConnection!
    let timeout:Double
    let buf = RingBuffer(Int(RECV_BUF_SIZE))
    var err:Error?
    var signID:OSSignpostID!
    init(_ hostname: UnsafeMutablePointer<Int8>!,
                  _ port: UINT,
                  _ timeout: UINT,
                  _ cancel_flag: UnsafeMutablePointer<bool>!,
                  _ nat_t_svc_name: UnsafeMutablePointer<Int8>!,
                  _ nat_t_error_code: UnsafeMutablePointer<UINT>!,
                  _ try_start_ssl: bool,
                  _ ssl_no_tls: bool,
                  _ no_get_hostname: bool,
                  _ ret_ip: UnsafeMutablePointer<IP>!) {
        self.hostname = String(cString: hostname)
        //param = NWTLSParameters()
        if timeout == 0{
            self.timeout = Double(TIMEOUT_TCP_PORT_CHECK)/1000
        }else{
            self.timeout = Double(timeout)/1000
        }
        super.init()
        
        let tunnel = PacketTunnelProvider.instance!
        let endPoint = NWHostEndpoint(hostname: self.hostname, port: String(port))
        
        tunnel.connections.append(self)
        s.ServerMode = 0
        s.AsyncMode = 0
        s.SecureMode = 0
        s.connection = Unmanaged<SockHandler>.passRetained(self).toOpaque()
        s.RemoteX = UnsafeMutableRawPointer(&s).assumingMemoryBound(to: X.self)
        s.lock = Lock.CNewLock()
        s.ssl_lock = Lock.CNewLock()
        s.disconnect_lock = Lock.CNewLock()
        sp.pointee = s
        
        lock()
        
        tcp = tunnel.createTCPConnection(to: endPoint, enableTLS: try_start_ssl==1, tlsParameters: nil, delegate: self)
        
        tcp.addObserver(self, forKeyPath: "state", options: .initial, context: &tcp)
        signID = OSSignpostID(log: SockHandler.connectionLog, object: self)
    
        SockHandler.count+=1
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "state" else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        switch tcp.state {
        case .connected:
            s.Connected = 1;
            name = "Connected"
            broadcast()
        case .connecting:
            break
        case .disconnected:
            s.Connected = 0;
            tcp.cancel()
            fallthrough
        default:
//            raise(SIGINT)
            break
        }
        
    }
    
    func waitTimeout()->Bool{
        return wait(until: getTimeout())
    }
    
    func getTimeout() -> Date{
        return timeoutDate(self.timeout)
    }
    
    let recvLock = DispatchSemaphore(value: 0)
    
    func recv(_ bufTarget: UnsafeMutableRawPointer, _ size: Int) -> uint{
        buf.lock()
        os_signpost(.event, log: SockHandler.connectionLog, name: "recv", signpostID: signID)
        defer {
            buf.unlock()
        }
        var read = 0
        let ptr = bufTarget.assumingMemoryBound(to: UInt8.self)
        
        if asyncMode {
            if buf.isEmpty {
                return SOCK_LATER
            }
            
            read = buf.copyTo(ptr, size)
            if read == buf.sizeMax{
                self.read()
            }
        }else{
            tcp.readMinimumLength(1, maximumLength: size) { (data, err) in
                data?.withUnsafeBytes { (dat:UnsafePointer<UInt8>) in
                    ptr.assign(from: dat, count: (data!.count))
                    read = data!.count
                }
                
                if let err = err{
                    self.err = err
                }
                
                self.recvLock.signal()
            }
            recvLock.wait()
        }
        
        s.RecvSize+=UINT64(read)
        s.RecvNum+=1
        return uint(read)
    }
    
    @_silgen_name("ConnectEx4")
    public static func SConnectEx4(_ hostname: UnsafeMutablePointer<Int8>!,
                           _ port: UINT,
                           _ timeout: UINT,
                           _ cancel_flag: UnsafeMutablePointer<bool>!,
                           _ nat_t_svc_name: UnsafeMutablePointer<Int8>!,
                           _ nat_t_error_code: UnsafeMutablePointer<UINT>!,
                           _ try_start_ssl: bool,
                           _ ssl_no_tls: bool,
                           _ no_get_hostname: bool,
                           _ ret_ip: UnsafeMutablePointer<IP>!) -> UnsafeMutablePointer<SOCK>!
    {
        let sh = SockHandler(hostname, port, timeout, cancel_flag, nat_t_svc_name, nat_t_error_code, try_start_ssl, ssl_no_tls, no_get_hostname, ret_ip)
        defer {
            sh.name = nil
            sh.unlock()
        }
        
        while sh.name != "Connected" {
            if !sh.waitTimeout(){
                return nil
            }
        }
        
        return sh.sp
    }
    
    static func GetSockHandler(_ sock: UnsafeMutablePointer<SOCK>?)->SockHandler?{
        guard let s = sock else{
            return nil
        }
        return GetOpaque(s.pointee.connection)
    }
    
    var asyncMode = false
    
    var flag:(() -> Any)?
    
    enum SelectState:String {
        case notConnected = "notConnected"
        case connectionError = "connectionError"
        case dataBuffered = "dataBuffered"
        case selectIPG = "selectIPG"
        case normal = "normal"
    }
    
    var reading = false
    
    fileprivate func read() {
        if !reading{
            reading=true
            os_signpost(.begin, log: SockHandler.connectionLog, name: "read", signpostID: self.signID)
            tcp.readMinimumLength(1, maximumLength: buf.available) { (data, err) in
                self.buf.lock()
                os_signpost(.end, log: SockHandler.connectionLog, name: "read", signpostID: self.signID)
                data?.withUnsafeBytes { (dat:UnsafePointer<UInt8>) in
                    self.buf.write(dat, data!.count)
                }
                
                if let err = err{
                    self.err = err
                }
                self.reading=false
                self.flag?()
                self.buf.unlock()
            }
        }
    }
    
    func selectOn(_ flagFunc: (() -> Any)?=nil) -> SelectState{
        buf.lock()
        defer {
//            name = nil
            buf.unlock()
        }
        
        if self.err != nil{
//            NSLog("Select Error %@\n", e.localizedDescription)
            return .connectionError
        }
        
        if !asyncMode{
            asyncMode = true
            s.AsyncMode = 1
            //SockHandler.dq.async(execute: selectMonitor)
        }
        
        if !buf.isEmpty{
            flagFunc?()
            return .dataBuffered
        }
        
        if flag != nil{
            return .selectIPG
        }
        
        flag = flagFunc
        
        read()
        
        return .normal
    }
    
    func selectOff(check event: NSCondition? = nil) {
        lock()
        flag = nil
        unlock()
    }
    
    @_silgen_name("Send")
    public static func SSend(_ sock: UnsafeMutablePointer<SOCK>!, _ data: UnsafeMutableRawPointer!, _ size: UINT, _ secure: bool) -> UINT
    {
        guard let sh = GetSockHandler(sock) else{
            return 0
        }
        let dataS = Data(bytes: data, count: Int(size))
    
        sh.lock()
        defer {
            sh.s.SendSize+=UInt64(size)
            sh.s.SendNum+=1
            sh.name = nil
            sh.unlock()
        }
        
        if sh.err != nil{
            return 0
        }
        
        sh.tcp.write(dataS, completionHandler: { (e) in
            sh.lock()
            defer {
                sh.name = "Send"
                sh.broadcast()
                sh.unlock()
            }
            
            if e != nil{
                sh.err = e
            }
        })
        
//        while sh.name != "Send" {
//            if !sh.waitTimeout(){
//                return 0
//            }
//        }
        
        if let e = sh.err{
            NSLog("Network: \(e.localizedDescription)")
            return 0
        }else{
            return size
        }
    }
    
    @_silgen_name("Recv")
    public static func SRecv(_ sock: UnsafeMutablePointer<SOCK>!, _ data: UnsafeMutableRawPointer!, _ size: UINT, _ secure: bool) -> UINT{
        guard let sh = GetSockHandler(sock) else{
            return 0
        }
        
        return sh.recv(data, Int(size))
    }
    static private func forEachSOCK(_ first:UnsafeMutableRawPointer,_ size:UINT, _ block: (SockHandler)->Bool){
        let first = first.assumingMemoryBound(to: (UnsafeMutablePointer<SOCK>?).self)
        for i in 0...Int(size){
            if let sh = GetSockHandler(first.advanced(by: i).pointee){
                if !block(sh){
                    break
                }
            }
        }
    }
    
    static var SelectTimeout = 250.0/1000
    
    static let connectionLog:OSLog = .disabled//OSLog(subsystem: "tech.nsyd.se.SENE", category: "Connection")
    // .disabled//
    
    static let selectID = OSSignpostID.init(log: connectionLog)
    
    @_silgen_name("Select")
    public static func SSelect(_ set: UnsafeMutablePointer<SOCKSET>!, _ timeout: UINT, _ c1: UnsafeMutablePointer<CANCEL>!, _ c2: UnsafeMutablePointer<CANCEL>!){
        os_signpost(.begin, log: connectionLog, name: "Select", signpostID: selectID)
        let monitor = DispatchSemaphore(value: 0)
        var timeout = UInt32(DispatchTime.now().uptimeNanoseconds/1000000)+UInt32(timeout)
        var wakeup = false
        defer {
            os_signpost(.end, log: connectionLog, name: "Select", signpostID: selectID,"status: %d", wakeup)
        }
        
        
        withUnsafeMutablePointer(to: &(set.pointee.Sock)){ ptr in
            var toWait = true
            forEachSOCK(ptr,set.pointee.NumSocket){ sh -> Bool in
                let result = sh.selectOn(monitor.signal)
                if result != .normal {
                    os_signpost(.event, log: connectionLog, name: "selectOn not Normal", signpostID: selectID, "%s",result.rawValue)
                    toWait = false
                }
                return result == .normal
            }
            defer{
                forEachSOCK(ptr,set.pointee.NumSocket){ sh -> Bool in
                    sh.selectOff()
                    return true
                }
            }
            
            if !toWait{
                return
            }
            
            Cancel.RegisterCancel(c1, monitor.signal)
            Cancel.RegisterCancel(c2, monitor.signal)
            
            defer{
                Cancel.RegisterCancel(c1, nil)
                Cancel.RegisterCancel(c2, nil)
            }
            wakeup = SemaphoreWait(monitor,until: timeout)
        }
    }
    
    @_silgen_name("Disconnect")
    public static func SDisconnect(_ sock: UnsafeMutablePointer<SOCK>!){
        guard let sh = GetSockHandler(sock) else{
            return
        }
        sh.tcp.writeClose()
    }
    
}

extension SockHandler:NWTCPConnectionAuthenticationDelegate{
    func evaluateTrust(for connection: NWTCPConnection, peerCertificateChain: [Any], completionHandler completion: @escaping (SecTrust) -> Void){
        var optionalTrust: SecTrust?
//        var policyTrust: SecPolicy?
        
        _ = SecTrustCreateWithCertificates([peerCertificateChain[0]] as CFTypeRef, nil, &optionalTrust)
        
        completion(optionalTrust!)
    }
}

@_silgen_name("StartSSLEx")
func SStartSSLEx(_ sock: UnsafeMutablePointer<SOCK>!, _ x: UnsafeMutablePointer<X>!, _ priv: UnsafeMutablePointer<K>!, _ ssl_timeout: UINT, _ sni_hostname: UnsafeMutablePointer<Int8>!) -> bool{
    return 1
}

class Cancel {
    var action:(()->Any)?
    var str:String?
    static func RegisterCancel(_ c: UnsafeMutablePointer<CANCEL>!, _ cond: (()->Any)?){
        guard let cancel:Cancel = GetOpaque(c) else {
            return
        }
        cancel.action = cond
    }
    
    @_silgen_name("NewCancel")
    static func SNewCancel() -> UnsafeMutablePointer<CANCEL>!{
        return ToOpaque(Cancel())
    }
    
    @_silgen_name("ReleaseCancel")
    static func SReleaseCancel(_ c: UnsafeMutablePointer<CANCEL>!){
        ReleaseOpaque(c)
    }
    
    @_silgen_name("Cancel")
    static func SCancel(_ c: UnsafeMutablePointer<CANCEL>!){
        guard let cancel:Cancel = GetOpaque(c) else {
            return
        }
        cancel.action?()
        
    }
}

@_silgen_name("WaitForTubes")
func SWaitForTubes(_ tubes: UnsafeMutablePointer<UnsafeMutablePointer<TUBE>?>!, _ num: UINT, _ timeout: UINT){
    let cond = DispatchSemaphore(value: 0)
    withEachEvent(tubes,num){ c in
        c.action = cond.signal
    }
    
    SemaphoreWait(cond, UInt32(5000))
    
    withEachEvent(tubes,num){ c in
        c.action = nil
    }
}

@_silgen_name("ReleaseSockEvent")
func SReleaseSockEvent(_ event: UnsafeMutablePointer<SOCK_EVENT>!){
    ReleaseOpaque(event)
}

@_silgen_name("WaitSockEvent")
func SWaitSockEvent(_ event: UnsafeMutablePointer<SOCK_EVENT>!, _ timeout: UINT) -> bool{
    guard let e:Cancel = GetOpaque(event) else {
        return 0
    }
    let cond = DispatchSemaphore(value: 0)
    e.action = cond.signal
    
    var result = true
    if e.str == nil{
        result = SemaphoreWait(cond, timeout)
        e.str = nil
    }
    return result ? 1 : 0
}

@_silgen_name("SetSockEvent")
func SSetSockEvent(_ event: UnsafeMutablePointer<SOCK_EVENT>!){
    guard let e:Cancel = GetOpaque(event) else {
        return
    }
    e.str = "Set"
    e.action?()
}

@_silgen_name("NewSockEvent")
func SNewSockEvent() -> UnsafeMutablePointer<SOCK_EVENT>!{
    let ptr:UnsafeMutablePointer<SOCK_EVENT>=ToOpaque(Cancel())
    NSLog("Sock Event: %p\n", ptr)
    return ptr
}

func withEachEvent(_ tubes: UnsafeMutablePointer<UnsafeMutablePointer<TUBE>?>!, _ num: UINT, _ fuc: (Cancel)->Void) {
    for i in 0...Int(num) {
        guard let t = tubes.advanced(by: i).pointee?.pointee else{
            continue
        }
        guard let c:Cancel = GetOpaque(t.SockEvent) else{
            continue
        }
        fuc(c)
    }
}

