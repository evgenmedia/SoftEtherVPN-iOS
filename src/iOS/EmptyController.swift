//
//  EmptyController.swift
//  SoftEtherVPN
//
//  Created by xy on 2018/7/27.
//

import Foundation
import UIKit
import NetworkExtension

class EmptyController: UIViewController {
    
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var vpnManager:NETunnelProviderManager = NETunnelProviderManager()
    
    
    let tunnelBundleId = "tech.nsyd.se.SoftEtherVPN.SoftEtherNE"
    let serverAddress = "1.1.1.1"
    let serverPort = "54345"
    let mtu = "1400"
    let ip = "10.8.0.2"
    let subnet = "255.255.255.0"
    let dns = "8.8.8.8,8.4.4.4"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        var exec = [strdup("vpnclient")]
        //        InitMayaqua(0, 0, 1,&exec)
        //
        //        CtStartClient()
        //        let client = CtGetClient()
        //        client?.pointee.Config.AllowRemoteConfig = 1
        ////        let client = CiNewClient()
        //        print(MAX_ACCOUNT_NAME_LEN)
        initVPNTunnelProviderManager()
    }
    
    
    
    private func initVPNTunnelProviderManager() {
        NETunnelProviderManager.loadAllFromPreferences { (savedManagers: [NETunnelProviderManager]?, error: Error?) in
            if let error = error {
                print(error)
            }
            if let savedManagers = savedManagers {
                if savedManagers.count > 0 {
                    self.vpnManager = savedManagers[0]
                }
            }
            
            self.vpnManager.loadFromPreferences(completionHandler: { (error:Error?) in
                if let error = error {
                    print(error)
                }
                
                let providerProtocol = NETunnelProviderProtocol()
                providerProtocol.providerBundleIdentifier = self.tunnelBundleId
                
//                providerProtocol.providerConfiguration = ["port": self.serverPort,
//                                                          "server": self.serverAddress,
//                                                          "ip": self.ip,
//                                                          "subnet": self.subnet,
//                                                          "mtu": self.mtu,
//                                                          "dns": self.dns
//                ]
                providerProtocol.serverAddress = self.serverAddress
                self.vpnManager.protocolConfiguration = providerProtocol
                self.vpnManager.localizedDescription = "asdfasdf"
                self.vpnManager.isEnabled = true
                
                self.vpnManager.saveToPreferences(completionHandler: { (error:Error?) in
                    if let error = error {
                        print(error)
                    } else {
                        print("Save successfully")
                    }
                })
                self.VPNStatusDidChange(nil)
                
            })
        }
    }
    
    func VPNStatusDidChange(_ notification: Notification?) {
        print("VPN Status changed:")
        let status = self.vpnManager.connection.status
        switch status {
        case .connecting:
            print("Connecting...")
            //connectButton.setTitle("Disconnect", for: .normal)
            break
        case .connected:
            print("Connected...")
            //connectButton.setTitle("Disconnect", for: .normal)
            break
        case .disconnecting:
            print("Disconnecting...")
            break
        case .disconnected:
            print("Disconnected...")
            //connectButton.setTitle("Connect", for: .normal)
            break
        case .invalid:
            print("Invliad")
            break
        case .reasserting:
            print("Reasserting...")
            break
        }
    }
    
    @IBAction func click(_ sender: UIButton) {
        print("Go!")
        self.vpnManager.loadFromPreferences { (error:Error?) in
            if let error = error {
                print(error)
            }
            if (!self.stat) {
                do {
                    try self.vpnManager.connection.startVPNTunnel()
                    self.stat=true
                    self.VPNStatusDidChange(nil)
                    print("start")
                } catch {
                    print(error)
                }
            } else {
                self.vpnManager.connection.stopVPNTunnel()
                self.stat=false
                self.VPNStatusDidChange(nil)
                print("stop")
            }
        }
    }
    var stat = false
}
