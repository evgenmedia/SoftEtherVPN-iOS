//
//  ViewController.swift
//  SoftEther
//
//  Created by Shuyi Dong on 2018-09-09.
//

import UIKit
import NetworkExtension

class ViewController: UIViewController {

    var vpnManager:NETunnelProviderManager = NETunnelProviderManager()
    
    
    let tunnelBundleId = "tech.nsyd.se.NE"
    let serverAddress = "1.1.1.1"
    let serverPort = "54345"
    let mtu = "1400"
    let ip = "10.8.0.2"
    let subnet = "255.255.255.0"
    let dns = "8.8.8.8,8.4.4.4"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVPNTunnelProviderManager()
        do {
            try self.vpnManager.connection.startVPNTunnel()
        } catch {
            print(error)
        }
        // Do any additional setup after loading the view, typically from a nib.
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
                
                providerProtocol.providerConfiguration = ["port": self.serverPort,
                                                          "server": self.serverAddress,
                                                          "ip": self.ip,
                                                          "subnet": self.subnet,
                                                          "mtu": self.mtu,
                                                          "dns": self.dns
                ]
                providerProtocol.serverAddress = self.serverAddress
                self.vpnManager.protocolConfiguration = providerProtocol
                self.vpnManager.localizedDescription = "NEPacketTunnelVPNDemoConfig"
                self.vpnManager.isEnabled = true
                
                self.vpnManager.saveToPreferences(completionHandler: { (error:Error?) in
                    if let error = error {
                        print(error)
                    } else {
                        print("Save successfully")
                    }
                })
//                self.VPNStatusDidChange(nil)
                
            })
        }
    }
}

