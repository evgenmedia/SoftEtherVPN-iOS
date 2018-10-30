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
    var tcp:NWTCPConnection!
    let timeout:Double
    var buf:UInt8?
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
        signID = OSSignpostID(log: SockHandler.selectLog, object: self)
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
    
    var minRead = 1
//    weak var selectEvent:NSCondition?
    var asyncMode:Bool { return minRead == 0 }
    
    var reading = false
    
    var lastRecv:UINT64 = 0
    
    var flag:UnsafeMutablePointer<Bool>?
    
    enum SelectErr:String {
        case notConnected = "notConnected"
        case connectionError = "connectionError"
        case dataBuffered = "dataBuffered"
        case selectIPG = "selectIPG"
        case normal = "normal"
    }
    
    static let dq = DispatchQueue(label: "ConnectionSelect", qos: .userInteractive, attributes: .concurrent)
    
    func selectOn(_ flagPtr: UnsafeMutablePointer<Bool>) -> SelectErr{
        lock()
        defer {
            name = nil
            unlock()
        }
        // SelectTimeout*1.5
        if tcp.state != .connected{
            return .notConnected
        }
        
        if let e = self.err{
            NSLog("Select Error %@\n", e.localizedDescription)
            return .connectionError
        }
        
        if !asyncMode{
            minRead = 0
            SockHandler.dq.async(execute: selectMonitor)
        }
        
        if buf != nil{
            flagPtr.pointee = true
            SockHandler.notify.broadcast()
            return .dataBuffered
        }
        
        if flag != nil{
            return .selectIPG
        }
        
        flag = flagPtr

        if !reading{
            broadcast() // wake up Monitor
        }
        return .normal
    }
    
//    let seleLock = NSCondition()
    var monRun = false
    func selectMonitor(){
        lock()
        s.AsyncMode = 1
        if monRun{
            return
        }
        monRun = true
        defer {
            minRead = 1
            unlock()
        }
        while tcp.state == .connected && asyncMode{
            while reading || flag == nil{
                wait()
            }
            if buf != nil{
                break
            }
            reading = true
            tcp.readLength(1, completionHandler: { (rec, e) in
                self.lock()
                self.lastRecv = Tick64()
                defer{
                    if let flag = self.flag{
                        flag.pointee = true
                        SockHandler.notify.broadcast()
                    }
                    self.reading = false
                    self.unlock()
                }
                if let r = rec{
                    self.buf = r.first
                }
                
                if e != nil{
                    self.err = e
                }
            })
        }
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
        
        while sh.name != "Send" {
            if !sh.waitTimeout(){
                return 0
            }
        }
        
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
        var readed:UINT = 0
        var nextData = data.assumingMemoryBound(to: UInt8.self)
        
        sh.lock()
        defer {
            sh.name = nil
            sh.unlock()
        }
        
        if sh.err != nil{
            return 0
        }
        
        if let byte = sh.buf {
            nextData.pointee = byte
            nextData = nextData.advanced(by: 1)
            readed+=1
            sh.buf = nil
        }else if sh.asyncMode {
            return SOCK_LATER
        }
        
        sh.tcp.readMinimumLength(max(0,sh.minRead-Int(readed)), maximumLength: Int(size-readed), completionHandler: { (rec, e) in
            sh.lock()
            defer {
                sh.name = "Recv"
                sh.broadcast()
                sh.unlock()
            }
            
            if let r = rec{
                r.copyBytes(to: nextData, count: r.count)
                readed+=UINT(r.count)
            }
            
            if e != nil{
                sh.err = e
            }
            
            
            sh.s.RecvSize+=UINT64(readed)
            sh.s.RecvNum+=1
        })
        
        while sh.name != "Recv" {
            if !sh.waitTimeout(){
                return 0
            }
        }
        
        if let e = sh.err{
            NSLog("Network Error: \(e.localizedDescription)")
            if readed != 0{
                sh.err = nil
                return readed
            }
            return 0
        }else{
            return readed
        }
    }
    static private func forEachSOCK(_ first:UnsafeMutableRawPointer,_ size:UINT, _ block: (SockHandler)->Void){
        let first = first.assumingMemoryBound(to: (UnsafeMutablePointer<SOCK>?).self)
        for i in 0...Int(size){
            if let sh = GetSockHandler(first.advanced(by: i).pointee){
                block(sh)
            }
        }
    }
    
    static var selectStr = "select"
    
    static let notify = NSCondition()
    static var SelectTimeout = 250.0/1000
    
    static let selectLog:OSLog = .disabled//OSLog(subsystem: "tech.nsyd.se.SENE", category: "Select")
    
    @_silgen_name("Select")
    public static func SSelect(_ set: UnsafeMutablePointer<SOCKSET>!, _ timeout: UINT, _ c1: UnsafeMutablePointer<CANCEL>!, _ c2: UnsafeMutablePointer<CANCEL>!){
        let signID = OSSignpostID(log: selectLog)
        os_signpost(.begin, log: selectLog, name: "Select",signpostID:signID)
        notify.lock()
        defer {
            notify.unlock()
            os_signpost(.end, log: selectLog, name: "Select",signpostID:signID)
        }
        var m = false
        withUnsafeMutablePointer(to: &(set.pointee.Sock)){ ptr in
        withUnsafeMutablePointer(to: &m){ monitor in
            forEachSOCK(ptr,set.pointee.NumSocket){ sh in
                os_signpost(.begin, log: SockHandler.selectLog, name: "Select On",signpostID:sh.signID)
                let result = sh.selectOn(monitor)
                os_signpost(.end, log: SockHandler.selectLog, name: "Select On",signpostID:sh.signID,"Result: %{public}@", result.rawValue)
            }
            
            Cancel.RegisterCancel(c1, notify)
            Cancel.RegisterCancel(c2, notify)
            
            if !monitor.pointee{
                let cond = notify.wait(until: timeoutDate(Double(timeout)/1000))
                notify.broadcast()
            }
            
            Cancel.RegisterCancel(c1, nil)
            Cancel.RegisterCancel(c2, nil)
            
            forEachSOCK(ptr,set.pointee.NumSocket){ sh in
                sh.selectOff()
            }
        }}
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
    weak var cond:NSCondition?
    var str:String?
    static func RegisterCancel(_ c: UnsafeMutablePointer<CANCEL>!, _ cond: NSCondition?){
        guard let cancel:Cancel = GetOpaque(c) else {
            return
        }
        cancel.cond = cond
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
        cancel.cond?.name = "Cancel"
        cancel.cond?.broadcast()
        
    }
}

@_silgen_name("WaitForTubes")
func SWaitForTubes(_ tubes: UnsafeMutablePointer<UnsafeMutablePointer<TUBE>?>!, _ num: UINT, _ timeout: UINT){
    let cond = NSCondition()
    withEachEvent(tubes,num){ c in
        c.cond = cond
    }
    
    if cond.name == nil {
        cond.wait(until: timeoutDate(num))
    }
    
    withEachEvent(tubes,num){ c in
        c.cond = nil
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
    e.cond = NSCondition()
    
    var result = true
    if e.str == nil{
        result = e.cond!.wait(until: timeoutDate(timeout))
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
    e.cond?.broadcast()
}

@_silgen_name("NewSockEvent")
func SNewSockEvent() -> UnsafeMutablePointer<SOCK_EVENT>!{
    var ptr:UnsafeMutablePointer<SOCK_EVENT>=ToOpaque(Cancel())
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

//public func IPToStr(_ str: UnsafeMutablePointer<Int8>!, _ size: UINT, _ ip: UnsafeMutablePointer<IP>!){
//    if (ip.pointee.addr == (0xDF,0xFF,0xFF,0xFE)){ // is IPv6
//        "::1".setPtr(str)
//    }else{
//        String(format: "%d.%d.%d.%d", ip.pointee.addr.0,ip.pointee.addr.1,ip.pointee.addr.2,ip.pointee.addr.3).setPtr(str)
//    }
//}


