//
//  PacketTunnelProvider.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/19.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
    var s:UnsafeMutablePointer<SESSION>?
    var t:SEClientThread?
    static var instance:PacketTunnelProvider?
    override init() {
        super.init()
        
        PacketTunnelProvider.instance = self
    }
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // Add code here to start the process of connecting the tunnel.
        
//        let raw = GetWaterMark()?.bindMemory(to: UInt8.self, capacity: Int(SizeOfWaterMark()))
//        var water = Data()
//        water.append(raw!, count: Int(SizeOfWaterMark()))
//        NSLog(water.hexEncodedString())
        //t.start()
        InitStringLibrary()
        let auth = CLIENT_AUTH.setup("asd","asdpas")
        let opt = CLIENT_OPTION.setup("172.20.18.2", 443)
        let acc = ACCOUNT.setup(opt, auth)
        var pa = salloc(PACKET_ADAPTER.self)
        s = SESSION.setup(opt, auth, pa, acc)
        t=SEClientThread(s!,self.cancelTunnelWithError)
        t?.start()
        
        completionHandler(nil)
    }
    
    
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        completionHandler()
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

