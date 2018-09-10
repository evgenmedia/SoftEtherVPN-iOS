//
//  Network.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/30.
//

import Foundation
import NetworkExtension

class SockHandler: NSCondition {
    let sp:UnsafeMutablePointer<SOCK>
    var s:SOCK{
        get {
            return sp.pointee
        }
        set (s){
            sp.pointee = s
        }
    }
    var hostname:String
    var param:NWTLSParameters
    var tcp:NWTCPConnection?
    let timeout:UINT
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
        self.timeout=timeout
        super.init()
        
        
        
        
        let tunnel = PacketTunnelProvider.instance!
        let endPoint = NWHostEndpoint(hostname: self.hostname, port: String(port))
        
        s.ServerMode = 0
        s.AsyncMode = 0
        s.SecureMode = 0
        s.connection = Unmanaged<SockHandler>.passRetained(self).toOpaque()
        s.RemoteX = UnsafeMutableRawPointer(&s).assumingMemoryBound(to: X.self)
        
        sp.pointee = s
        tcp = tunnel.createTCPConnection(to: endPoint, enableTLS: try_start_ssl==1, tlsParameters: param, delegate: self)
        
        tcp!.addObserver(self, forKeyPath: "state", options: .initial, context: &tcp)
        
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "state" else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        NSLog("state: \(tcp!.state.rawValue)")
        switch tcp!.state {
        case .connected:
            s.Connected = 1;
            testConnect()
            testConnect()
            broadcast()
        default:
            break
        }
        
    }
    
    func testConnect(){
        let addr = "172.20.18.6"
        let content = "image/jpeg"
        let header = "POST /vpnsvc/test.cgi HTTP/1.1\r\n"
            + "Host: \(addr)\r\n"
            + "Content-Type: \(content)\r\n"
            + "Connection: Keep-Alive\r\n"
            + "Content-Length: 0\r\n\r\n"
        var data = header.data(using: .utf8)!
        

        tcp!.write(data) { (err) in
            if let e = err{
                print(e.localizedDescription)
                return
            }
            self.tcp!.readMinimumLength(1, maximumLength: 5000, completionHandler: { (data, err) in
                if let e = err{
                    print(e.localizedDescription)
                    return
                }
                let str = String(data: data!, encoding: String.Encoding.utf8)!
                print(str)
            })
        }
    }
    
    func wait() -> Bool {
        return super.wait(until: getTimeout())
    }
    
    func getTimeout() -> Date{
        var date = Date().addingTimeInterval(TimeInterval(timeout)/1000)
        if timeout == 0{
            date = date.addingTimeInterval(TimeInterval(TIMEOUT_TCP_PORT_CHECK)/1000)
        }
        return date
    }
    
    @_silgen_name("ConnectEx4")
    public static func ConnectEx4(_ hostname: UnsafeMutablePointer<Int8>!,
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
        if sh.wait(){
            return sh.sp
        }
        return nil
    }
    
    static func GetSockHandler(_ sock: UnsafeMutablePointer<SOCK>!)->SockHandler{
        let obj = Unmanaged<SockHandler>.fromOpaque(sock.pointee.connection)
        return obj.takeUnretainedValue()
    }
    
    @_silgen_name("Send")
    public static func Send(_ sock: UnsafeMutablePointer<SOCK>!, _ data: UnsafeMutableRawPointer!, _ size: UINT, _ secure: bool) -> UINT
    {
        let sh = GetSockHandler(sock)
        let dataS = Data(bytes: data, count: Int(size))
        var err:Error?
        sh.tcp!.write(dataS, completionHandler: { (e) in
            err = e
            sh.broadcast()
        })
        if sh.wait(){
            if let e = err{
                return 0
            }else{
                sh.s.SendSize+=UInt64(size)
                sh.s.SendNum+=1
                return size
            }
        }
        return 0
    }
    
    @_silgen_name("Recv")
    public static func Recv(_ sock: UnsafeMutablePointer<SOCK>!, _ data: UnsafeMutableRawPointer!, _ size: UINT, _ secure: bool) -> UINT{
        let sh = GetSockHandler(sock)
        var err:Error?
        var dataR:Data?
        sh.tcp?.readLength(Int(size), completionHandler: { (rec, e) in
            err = e
            dataR = rec
            sh.broadcast()
        })
        if sh.wait(){
            if let e = err{
                return 0
            }else{
                dataR?.copyBytes(to: data.assumingMemoryBound(to: UInt8.self), count: Int(size))
                sh.s.RecvSize+=UInt64(size)
                sh.s.RecvNum+=1
                //sh.s.WriteBlocked=0
                return size
            }
        }
        return 0
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


