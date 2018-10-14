//
//  Session.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/27.
//

import Foundation
import NetworkExtension

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

class PackAdapterInstance{
    let packetFlow:NEPacketTunnelFlow
    let paPtr = salloc(PACKET_ADAPTER.self)
    init(_ packet: NEPacketTunnelFlow) {
        packetFlow=packet
        var pa = PACKET_ADAPTER()
        pa.Init = SPAInit
        pa.GetCancel = SPAGetCancel
        pa.GetNextPacket = SPAGetNextPacket
        pa.PutPacket = SPAPutPacket
        pa.Free = SPAFree
        pa.Param = nil
        paPtr.pointee = pa
    }
}



func SPAInit(_ s:UnsafeMutablePointer<SESSION>?) ->  UInt32{
    return 1
}

func SPAGetCancel(_ s:UnsafeMutablePointer<SESSION>?)->UnsafeMutablePointer<CANCEL>?{
    return nil
}

func SPAGetNextPacket(_ s: UnsafeMutablePointer<SESSION>!, _ pack: UnsafeMutablePointer<UnsafeMutableRawPointer?>!) -> UINT{
    return 0
}

func SPAPutPacket(_ s:UnsafeMutablePointer<SESSION>?, _ pack: UnsafeMutableRawPointer?, _ size: UINT)->UINT{
    return 1
}

func SPAFree(_ s:UnsafeMutablePointer<SESSION>?){
    
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
        rtn.lock = Lock.CNewLock()
        rtn.TrafficLock = Lock.CNewLock()
        // Cedar
        rtn.Cedar=salloc(CEDAR.self)
        rtn.Cedar.pointee.CurrentTcpQueueSizeLock = Lock.CNewLock()
        rtn.Cedar.pointee.FifoBudgetLock = Lock.CNewLock()
        rtn.Cedar.pointee.QueueBudgetLock = Lock.CNewLock()
        rtn.Cedar.pointee.lock = Lock.CNewLock()
        rtn.Cedar.pointee.TrafficLock = Lock.CNewLock()
        rtn.Cedar.pointee.Client=salloc(CLIENT.self)
        ptr.pointee = rtn
        return ptr
    }
}

