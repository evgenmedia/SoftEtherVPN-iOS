//
//  Account.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/27.
//

import Foundation
// This is actually the Remote Server

extension ACCOUNT{
    static func setup(_ co:UnsafeMutablePointer<CLIENT_OPTION>, _ ca:UnsafeMutablePointer<CLIENT_AUTH>) -> UnsafeMutablePointer<ACCOUNT> {
        let ptr = salloc(self)
        var rtn = ptr.pointee
        rtn.StartupAccount=1
        rtn.CheckServerCert=0
        rtn.ClientOption=co
        rtn.ClientAuth=ca
        rtn.StatusPrinter=AppleStatusPrinter
        ptr.pointee = rtn
        return ptr
    }
}
