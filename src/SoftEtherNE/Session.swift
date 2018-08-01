//
//  Session.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/27.
//

import Foundation

class SEClientThread: Thread {
    var end : ((_ error: Error?) -> Void)
    var session:SESSION{
        return sp.pointee
    }
    let sp:UnsafeMutablePointer<SESSION>
    var thread:THREAD{
        return tp.pointee
    }
    let tp:UnsafeMutablePointer<THREAD>
    init(_ sp:UnsafeMutablePointer<SESSION>, _ handle:@escaping (_ error: Error?) -> Void) {
        self.sp = sp
        self.end = handle
        tp=salloc(THREAD.self)
        super.init()
    }
    
    override func main() {
        ClientThread(tp, sp)
        end(NSError(domain: "tech.nsyd.se.ClientThread", code: -1, userInfo: nil))
    }
}

extension SESSION{
    static func setup(_ opt:UnsafeMutablePointer<CLIENT_OPTION>, _ auth:UnsafeMutablePointer<CLIENT_AUTH>, _ pa:UnsafeMutablePointer<PACKET_ADAPTER>, _ account:UnsafeMutablePointer<ACCOUNT>)->UnsafeMutablePointer<SESSION>{
//        let ptr = UnsafeMutablePointer<SESSION>.allocate(capacity: 1)
        let ptr = salloc(self)
        var rtn = ptr.pointee
        NSLog("\(UnsafeMutablePointer(&rtn))")
        rtn.Account=account
        rtn.ClientOption=opt
        rtn.ClientAuth=auth
        rtn.PacketAdapter=pa
        
        rtn.MaxConnection = opt.pointee.MaxConnection
        rtn.UseEncrypt = opt.pointee.UseEncrypt
        rtn.UseCompress = opt.pointee.UseCompress
        
        // Cedar
        rtn.Cedar=salloc(CEDAR.self)
        
        ptr.pointee = rtn
        return ptr
    }
}

