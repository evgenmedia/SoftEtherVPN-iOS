//
//  Session.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/27.
//

import Foundation
import NetworkExtension

typealias ErrFunc = ((_ error: Error?) -> Void)

class SClientThread: NamedThread {
    var stratHandler : ErrFunc
    var endHandler : (()->Void)?
    let tun:PacketTunnelProvider
    
    init(_ tun:PacketTunnelProvider, _ stratHandler:@escaping ErrFunc) {
        self.tun = tun
        self.stratHandler = stratHandler
        super.init(ClientThread, tun.session, "ClientThread")
        super.exitFunc = onTerminate
    }
    
    func currErr() -> Error{
        return NSError(domain: "tech.nsyd.se.ne.ClientThread", code: -Int(tun.s.Err), userInfo: nil)
    }
    
    func onTerminate() {
        if let end = endHandler {
            end()
        }else{
            let e = currErr()
            NSLog("Exit Error: %@", e.localizedDescription)
            tun.cancelTunnelWithError(e)
        }
    }
    
    func Connected() {
        stratHandler(nil)
    }
    
    @_silgen_name("SessionConnected")
    static func SConnected(_ t: UnsafeMutablePointer<THREAD>!){
        guard let thread:Thread = GetOpaque(t) else{
            return
        }
        guard let client = thread as? SClientThread else {
            return
        }
        client.Connected()
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
        rtn.HaltEvent = Event.CNewEvent()
        
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

