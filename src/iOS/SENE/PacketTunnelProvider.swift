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
    var pa:PackAdapterInstance?
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
        InitNetwork()
        let auth = CLIENT_AUTH.setup("asd","asdpas")
        let opt = CLIENT_OPTION.setup("mac-mini.local", 443)
        let acc = ACCOUNT.setup(opt, auth)
        pa = PackAdapterInstance(packetFlow)//pa!.paPtr
        s = SESSION.setup(opt, auth, NullGetPacketAdapter(), acc)
        
        
        let thread = NamedThread(ClientThread,s,"ClientThread",{
            let err = Int(self.s!.pointee.Err)
            if err != 0{
                NSLog("Exit Error: %@", NSLocalizedString("ERR_\(err)", comment: ""))
                self.cancelTunnelWithError(NSError(domain: "tech.nsyd.se.ClientThread", code: -err, userInfo: nil))
            }
        })
        
        //t=SEClientThread(s!,self.cancelTunnelWithError)
        print("Hello World!")
        NSLog("%@", "Hello Log!")
        //t?.start()
        
        completionHandler(nil)
    }
    
    
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        StopSession(s)
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

