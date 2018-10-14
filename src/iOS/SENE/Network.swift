//
//  Network.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/30.
//

import Foundation
import NetworkExtension

class SockHandler : NSCondition {
    let sp:UnsafeMutablePointer<SOCK>
    var s:SOCK{
        get {
            return sp.pointee
        }
        set {
            sp.pointee = newValue
        }
    }
    var hostname:String
    var param:NWTLSParameters
    var tcp:NWTCPConnection!
    let timeout:Double
    var buf:UInt8?
    var err:Error?
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
        sp = salloc(SOCK.self)
        self.hostname = toSWString(hostname)
        param = NWTLSParameters()
        if timeout == 0{
            self.timeout = Double(TIMEOUT_TCP_PORT_CHECK)/1000
        }else{
            self.timeout = Double(timeout)/1000
        }
        
        super.init()
        
        let tunnel = PacketTunnelProvider.instance!
        let endPoint = NWHostEndpoint(hostname: self.hostname, port: String(port))
        
        
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
        
        tcp = tunnel.createTCPConnection(to: endPoint, enableTLS: try_start_ssl==1, tlsParameters: param, delegate: self)
        
        tcp.addObserver(self, forKeyPath: "state", options: .initial, context: &tcp)
        
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
        default:
            break
        }
        
    }
    
    func waitTimeout()->Bool{
        return wait(until: getTimeout())
    }
    
    func getTimeout() -> Date{
        return Date().addingTimeInterval(TimeInterval(self.timeout))
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
    
    static func GetSockHandler(_ sock: UnsafeMutablePointer<SOCK>!)->SockHandler{
        let obj = Unmanaged<SockHandler>.fromOpaque(sock.pointee.connection)
        return obj.takeUnretainedValue()
    }
    
    func selectOn(_ event: NSCondition){
        lock()
        
        defer {
            name = nil
            unlock()
        }
        
        tcp.readLength(1, completionHandler: { (rec, e) in
            event.lock()
            self.lock()
            defer{
                self.unlock()
                event.signal()
                event.unlock()
            }
            if let r = rec{
                self.buf = r.first
                self.s.RecvSize+=UINT64(r.count)
            }
            
            if e != nil{
                self.err = e
            }
        })
    }
    
    @_silgen_name("Send")
    public static func SSend(_ sock: UnsafeMutablePointer<SOCK>!, _ data: UnsafeMutableRawPointer!, _ size: UINT, _ secure: bool) -> UINT
    {
        let sh = GetSockHandler(sock)
        let dataS = Data(bytes: data, count: Int(size))
    
        sh.lock()
        defer {
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
            
            sh.s.SendSize+=UInt64(size)
            sh.s.SendNum+=1
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
        let sh = GetSockHandler(sock)
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
        
        if let byte = sh.buf{
            nextData.pointee = byte
            nextData = nextData.advanced(by: 1)
            readed+=1
            sh.buf = nil
        }
        
        sh.tcp.readMinimumLength(1-Int(readed), maximumLength: Int(size-readed), completionHandler: { (rec, e) in
            sh.lock()
            defer {
                sh.name = "Recv"
                sh.broadcast()
                sh.unlock()
            }
            
            if e != nil{
                sh.err = e
            }
            
            if let r = rec{
                r.copyBytes(to: nextData, count: r.count)
                readed+=UINT(r.count)
                sh.s.RecvSize+=UINT64(r.count)
                sh.s.RecvNum+=1
            }
        })
        
        while sh.name != "Recv" {
            if !sh.waitTimeout(){
                return 0
            }
        }
        
        if let e = sh.err{
            NSLog("Network Error: \(e.localizedDescription)")
            return 0
        }else{
            return readed
        }
    }
    
    @_silgen_name("Select")
    public static func SSelect(_ set: UnsafeMutablePointer<SOCKSET>!, _ timeout: UINT, _ c1: UnsafeMutablePointer<CANCEL>!, _ c2: UnsafeMutablePointer<CANCEL>!){
        var socks = [SockHandler]()
        let notify = NSCondition()
        
        withUnsafeMutablePointer(to: &(set.pointee.Sock), { ptr in
            let first = UnsafeMutableRawPointer(ptr).assumingMemoryBound(to: (UnsafeMutablePointer<SOCK>?).self)
            for i in 0...set.pointee.NumSocket{
                if let sock = first.advanced(by: Int(i)).pointee{
                    socks.append(GetSockHandler(sock))
                }
            }
        })
        
        notify.lock()
        for s in socks{
            s.selectOn(notify)
        }
        
        notify.wait(until: Date().addingTimeInterval(TimeInterval(Double(timeout)/1000)))
        notify.unlock()
        
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

//class HttpHeader:NSObject{
//
//    
//    public func NewHttpHeader(_ method: UnsafeMutablePointer<Int8>!, _ target: UnsafeMutablePointer<Int8>!, _ version: UnsafeMutablePointer<Int8>!) -> UnsafeMutablePointer<HTTP_HEADER>!{
//        return nil
//    }
//
//    public func NewHttpValue(_ name: UnsafeMutablePointer<Int8>!, _ data: UnsafeMutablePointer<Int8>!) -> UnsafeMutablePointer<HTTP_VALUE>!{
//        return nil
//    }
//
//    public func AddHttpValue(_ header: UnsafeMutablePointer<HTTP_HEADER>!, _ value: UnsafeMutablePointer<HTTP_VALUE>!){
//
//    }
//
//    public func FreeHttpHeader(_ header: UnsafeMutablePointer<HTTP_HEADER>!){
//
//    }
//
//    public func RecvHttpHeader(_ s: UnsafeMutablePointer<SOCK>!) -> UnsafeMutablePointer<HTTP_HEADER>!{
//        return nil
//    }
//
//    @_silgen_name("GetHttpValue")
//    public func GetHttpValue(_ header: UnsafeMutablePointer<HTTP_HEADER>!, _ name: UnsafeMutablePointer<Int8>!) -> UnsafeMutablePointer<HTTP_VALUE>!{
//        return nil
//    }
//}
//
//public func IPToStr(_ str: UnsafeMutablePointer<Int8>!, _ size: UINT, _ ip: UnsafeMutablePointer<IP>!){
//    if (ip.pointee.addr == (0xDF,0xFF,0xFF,0xFE)){ // is IPv6
//        "::1".setPtr(str)
//    }else{
//        String(format: "%d.%d.%d.%d", ip.pointee.addr.0,ip.pointee.addr.1,ip.pointee.addr.2,ip.pointee.addr.3).setPtr(str)
//    }
//}


