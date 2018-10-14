//
//  Connection.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/27.
//

import Foundation


extension CLIENT_OPTION{
    static func setup(_ server:String, _ port:Int,udp:Int = 0)->UnsafeMutablePointer<CLIENT_OPTION>{
        let ptr = salloc(self)
        var rtn = ptr.pointee
        "VPN".setPtr(&rtn.AccountName)
        server.setPtr(&rtn.Hostname)
        "DEFAULT".setPtr(&rtn.HubName)
        rtn.Port=UINT32(port)
        rtn.PortUDP=UINT32(udp)
        rtn.UseEncrypt=1
        rtn.MaxConnection=1
        rtn.NoUdpAcceleration=1
        rtn.NumRetry=1
        ptr.pointee = rtn
        return ptr
    }
}


extension CLIENT_AUTH{
    
    static func setup(_ username:String, _ hpasswd:String) -> UnsafeMutablePointer<CLIENT_AUTH> {
        let ptr = salloc(CLIENT_AUTH.self)
        var rtn = ptr.pointee
        rtn.AuthType=UInt32(CLIENT_AUTHTYPE_PLAIN_PASSWORD)
        
        username.setPtr(&rtn.Username)
        hpasswd.setPtr(&rtn.PlainPassword)
        
        ptr.pointee = rtn
        return ptr
    }
    
}
