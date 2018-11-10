//
//  PacketTunnelProvider.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/19.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
    var session:UnsafeMutablePointer<SESSION>!
    var connections = [SockHandler]()
    var s:SESSION{
        get {
            return session.pointee
        }
        set {
            session.pointee = newValue
        }
    }
    var t:SClientThread!
    static var instance:PacketTunnelProvider!
    var pa:PackAdapterInstance!
    override init() {
        super.init()
        PacketTunnelProvider.instance = self
        
    }
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // Add code here to start the process of connecting the tunnel.
        
//        let endPoint = NWHostEndpoint(hostname: "mac-mini.local", port: "12345")
//
//        var tcp = createTCPConnection(to: endPoint, enableTLS: false, tlsParameters: NWTLSParameters(), delegate: nil)
//        Thread.sleep(until: Date().addingTimeInterval(TimeInterval(2)))
//        let cnd = NSCondition()
//        cnd.lock()
//        while true {
//            tcp.readMinimumLength(0, maximumLength: 100, completionHandler: { (data, err) in
//                cnd.lock()
//                if let d = data{
//                    let c = (d.count)
//                }
//                cnd.broadcast()
//                cnd.unlock()
//            })
//            cnd.wait(until:Date().addingTimeInterval(TimeInterval(10)))
//            tcp.write("Test\n".data(using: String.Encoding.utf8)!, completionHandler: {_ in })
//        }
        
       
        
        InitStringLibrary()
        InitNetwork()
        let auth = CLIENT_AUTH.setup("asd","asdpas")
        let opt = CLIENT_OPTION.setup("ca-nsyd.vpnazure.net", 443)
        let acc = ACCOUNT.setup(opt, auth)
        pa = PackAdapterInstance(self)//pa!.paPtr
        session = SESSION.setup(opt, auth, pa.pa, acc)
        t = SClientThread(self, completionHandler)
    
    }
    
    
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        completionHandler()
        t.endHandler = completionHandler
        
        StopSession(session)
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}

