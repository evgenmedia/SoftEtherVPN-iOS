//
//  PacketAdapter.swift
//  SENE
//
//  Created by Shuyi Dong on 2018-10-14.
//

import Foundation
import NetworkExtension

class PackAdapterInstance : Thread{
    let packetFlow:NEPacketTunnelFlow
    let pa = salloc(PACKET_ADAPTER.self)
    enum State {
        case running
        case beforeRunning
        case ready
        case canceled
    }
    var cancel = Cancel()
    var cond = NSCondition()
    var state:State = .ready
    var ipc:UnsafeMutablePointer<IPC>!
    var sockPtr:UnsafeMutablePointer<SOCK>!
    var sock:SOCK{ return sockPtr.pointee }
    static var i:PackAdapterInstance?
    private static var TmpSock:UnsafeMutablePointer<SOCK>!
    init(_ tun:PacketTunnelProvider) {
        packetFlow=tun.packetFlow
        super.init()
        PackAdapterInstance.i=self
        // PA struct
        var pa = PACKET_ADAPTER()
        do {
        pa.Init = { (s:UnsafeMutablePointer<SESSION>?) -> UINT in
            return PackAdapterInstance.GetPacketAdapter(s).Init(s)
        }
        pa.GetCancel = { (s:UnsafeMutablePointer<SESSION>?) -> UnsafeMutablePointer<CANCEL>? in
            return PackAdapterInstance.GetPacketAdapter(s).GetCancel(s)
        }
        pa.GetNextPacket = { (s:UnsafeMutablePointer<SESSION>?, pack: UnsafeMutablePointer<UnsafeMutableRawPointer?>?) -> UINT in
            return PackAdapterInstance.GetPacketAdapter(s).GetNextPacket(s, pack)
        }
        pa.PutPacket = { (s:UnsafeMutablePointer<SESSION>?, pack: UnsafeMutableRawPointer?, size: UINT) -> UINT in
            return PackAdapterInstance.GetPacketAdapter(s).PutPacket(s, pack, size)
        }
        pa.Free = { (s:UnsafeMutablePointer<SESSION>?) in
            return PackAdapterInstance.GetPacketAdapter(s).SFree(s)
        }
        pa.Param = UnsafeMutableRawPointer(ToOpaque(self))
        }
        self.pa.pointee = pa
        
        var s1:UnsafeMutablePointer<SOCK>! // Client (IPC)
        var s2:UnsafeMutablePointer<SOCK>! // Server (PA)
        withUnsafeMutablePointer(to: &s1) { (s1Ptr) in
        withUnsafeMutablePointer(to: &s2) { (s2Ptr) in
            NewSocketPair(s1Ptr, s2Ptr, nil, 0, nil, 0)
        }}
        sockPtr = s1
        PackAdapterInstance.TmpSock = s2
        cancel.cond = cond
        
        name = "PacketAdapterThread"
    }
    
    static func GetPacketAdapter(_ s:UnsafeMutablePointer<SESSION>!)->PackAdapterInstance!{
        return GetOpaque(s.pointee.PacketAdapter.pointee.Param)
    }
    
    func Init(_ s:UnsafeMutablePointer<SESSION>?) ->  UInt32{
        DispatchQueue.global(qos: .default).async {
            var sync = IPC_ASYNC()
            
            sync.Cedar = s?.pointee.Cedar
            sync.Param.IsL3Mode = 1
            
            withUnsafeMutablePointer(to: &sync.Param.ClientHostname) { chPtr in
                let ptr = UnsafeMutableRawPointer(chPtr).assumingMemoryBound(to: Int8.self)
                StrCpy(ptr, UINT(MAX_SIZE), sync.Cedar.pointee.MachineName)
            }
            
            self.state = .beforeRunning
            withUnsafeMutablePointer(to: &sync) { (ptr) in
                IPCAsyncThreadProc(ToOpaque(self), ptr)
            }
            
            self.ipc = sync.Ipc
            
            
            // Got IP form DHCP
            let pt = PacketTunnelProvider.instance
            let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: s!.pointee.ServerIP.toString())
            
            settings.ipv4Settings = NEIPv4Settings(
                addresses: [self.ipc.pointee.ClientIPAddress.toString()],
                subnetMasks: [self.ipc.pointee.SubnetMask.toString()])
            
            settings.ipv4Settings?.includedRoutes = [NEIPv4Route(destinationAddress: "0.0.0.0", subnetMask: "0.0.0.0")]
            
            settings.mtu = 1500
            
            pt!.setTunnelNetworkSettings(settings, completionHandler: { (err) in
                if let e = err{
                    self.state = .canceled
                    self.SFree(s)
                }
            })
            
            self.recvPacket()
            self.state = .running
            super.start()
        }
        return 1
    }
    
    @_silgen_name("NewIPCByParam")
    static func SNewIPCByParam(_ cedar: UnsafeMutablePointer<CEDAR>!, _ param: UnsafeMutablePointer<IPC_PARAM>!, _ error_code: UnsafeMutablePointer<UINT>!) -> UnsafeMutablePointer<IPC>!{
        var ipc = IPC()
        ipc.Cedar = cedar
        ipc.ClientHostname = param.pointee.ClientHostname
        ipc.ArpTable = NewList(IPCCmpArpTable)
        ipc.Interrupt = NewInterruptManager()
        ipc.FlushList = NewTubeFlushList()
        ipc.IPv4ReceivedQueue = NewQueue()
        withUnsafeMutablePointer(to: &ipc.MacAddress) { (ptr) in
            GenMacAddress(UnsafeMutableRawPointer(ptr).assumingMemoryBound(to: UCHAR.self))
        }
        
        ipc.Sock = TmpSock
        
        
        let ptr = salloc(IPC.self)
        ptr.pointee = ipc
        return ptr
    }
    
    func GetCancel(_ s:UnsafeMutablePointer<SESSION>?)->UnsafeMutablePointer<CANCEL>?{
        return ToOpaque(cancel)
    }
    
    // IPC(RecvTube) -> PA -> Client
    func GetNextPacket(_ s: UnsafeMutablePointer<SESSION>!, _ pack: UnsafeMutablePointer<UnsafeMutableRawPointer?>!) -> UINT{
        guard let d = TubeRecvAsync(sock.RecvTube) else{
            return state == .canceled ? INFINITE : 0
        }
        let size = d.pointee.DataSize
        NSLog("Got Packet size:%d, que_size: %d\n",size,sock.RecvTube.pointee.Queue.pointee.num_item)
        pack.pointee = Clone(d.pointee.Data, size)
        Free(d.pointee.Header)
        Free(d)
        return size
    }
    
    // Client -> PA -> IPC(SendTube)
    func PutPacket(_ s:UnsafeMutablePointer<SESSION>?, _ data: UnsafeMutableRawPointer?, _ size: UINT)->UINT{
        TubeSendEx(sock.SendTube, data, size, nil, 1)
        
        // Signal Read
        cond.lock()
        cond.broadcast()
        cond.name = "put"
        cond.unlock()
        return 1
    }
    
    
    // L3 -> L2
    // iOS -> PA
    var dataIOS:[Data]?
    var ipIOS:[NSNumber]?
    func recvPacket(){
        if state == .canceled {
            return
        }
        packetFlow.readPackets { (data, ipvs) in
            var i = 0
            for d in data{
                NSLog("read")
                d.withUnsafeBytes({ (ptr) in
                    PrintBin(UnsafeMutableRawPointer(mutating: ptr), UINT(d.count))
                })
                if ipvs[i] != NSNumber(value: AF_INET){
                    continue
                }
                d.withUnsafeBytes({ (ptr:UnsafePointer<UInt8>) in
                    IPCSendIPv4(self.ipc, UnsafeMutableRawPointer(mutating: ptr), UINT(d.count))
                })
                i+=1
            }
            self.recvPacket()
        }
    }
    
    func SFree(_ s:UnsafeMutablePointer<SESSION>?){
        state = .canceled
        cond.broadcast()
        Unmanaged<Cancel>.passUnretained(cancel).release()
    }
    
    static let Timeout = 30 // TODO
    
    
    // L2 -> L3
    override func main() {
        while(state == .running){
            IPCProcessL3Events(ipc)
            var datas = [Data]()
            var nums = [NSNumber]()
            while let bR = GetNext(ipc.pointee.IPv4ReceivedQueue){
                let bP = bR.assumingMemoryBound(to: BLOCK.self)
                let b = bP.pointee
                datas.append(Data(bytes: b.Buf, count: Int(b.Size)))
                nums.append(NSNumber(value: AF_INET))
                FreeBlock(bP)
            }
            if datas.count > 0{
                packetFlow.writePackets(datas, withProtocols: nums)
            }
            cond.lock()
            while cond.name == nil {
                cond.wait(until: timeoutDate(PackAdapterInstance.Timeout))
                cond.name = nil
            }
            cond.unlock()
        }
    }
}

extension IP{
    mutating func toString() -> String {
        let ptr = UnsafeMutablePointer<Int8>.allocate(capacity: 128)
        
        withUnsafeMutablePointer(to: &self) { ipPtr in
            IPToStr(ptr, 128, ipPtr)
        }
        
        let rtn = String(cString: ptr)
        ptr.deallocate()
        return rtn
    }
}

@_silgen_name("FlushTubeFlushList")
func SFlushTubeFlushList(_ f: UnsafeMutablePointer<TUBE_FLUSH_LIST>!){
    
}

@_silgen_name("IPCDhcpSetConditionalUserClass")
func SIPCDhcpSetConditionalUserClass(_ ipc:UnsafeMutablePointer<IPC>,_ req:UnsafeMutablePointer<DHCP_OPTION_LIST>){
    
}

@_silgen_name("AddInterrupt")
func SAddInterrupt(_ m: UnsafeMutablePointer<INTERRUPT_MANAGER>!, _ tick: UINT64){
    
}
/**
 class PackAdapterInstance{
 let packetFlow:NEPacketTunnelFlow
 let pa = salloc(PACKET_ADAPTER.self)
 var ipc:UnsafeMutablePointer<IPC>?
 struct Block {
 let data:UnsafeMutableRawPointer
 let size:UINT
 var next:UnsafeMutablePointer<Block>?
 }
 var inQueHead:UnsafeMutablePointer<Block>? //IPC -> PA
 var inQueTail:UnsafeMutablePointer<Block>?
 var outQueHead:UnsafeMutablePointer<Block>? // PA -> IPC
 var outQueTail:UnsafeMutablePointer<Block>?
 static var Instance:PackAdapterInstance!
 init(_ tun:PacketTunnelProvider) {
 packetFlow=tun.packetFlow
 PackAdapterInstance.Instance=self
 // PA struct
 var pa = PACKET_ADAPTER()
 do {
 pa.Init = { (s:UnsafeMutablePointer<SESSION>?) -> UINT in
 return PackAdapterInstance.Instance.Init(s)
 }
 pa.GetCancel = { (s:UnsafeMutablePointer<SESSION>?) -> UnsafeMutablePointer<CANCEL>? in
 return PackAdapterInstance.Instance.GetCancel(s)
 }
 pa.GetNextPacket = { (s:UnsafeMutablePointer<SESSION>?, pack: UnsafeMutablePointer<UnsafeMutableRawPointer?>?) -> UINT in
 return PackAdapterInstance.Instance.GetNextPacket(s, pack)
 }
 pa.PutPacket = { (s:UnsafeMutablePointer<SESSION>?, pack: UnsafeMutableRawPointer?, size: UINT) -> UINT in
 return PackAdapterInstance.Instance.PutPacket(s, pack, size)
 }
 pa.Free = { (s:UnsafeMutablePointer<SESSION>?) in
 return PackAdapterInstance.Instance.SFree(s)
 }
 pa.Param = nil
 }
 self.pa.pointee = pa
 
 }
 /*
 IPCSendL2 -> GetNextPacket -> Server
 
 */
 
 
 func Init(_ s:UnsafeMutablePointer<SESSION>?) ->  UInt32{
 DispatchQueue.global(qos: .default).async {
 let param = CreateIPC_PARAM(s)
 IPCAsyncThreadProc(ToOpaque(self),param)
 Free(param)
 self.recvPacket()
 }
 return 1
 }
 
 @_silgen_name("NewIPCByParam")
 static func SNewIPCByParam(_ cedar: UnsafeMutablePointer<CEDAR>!, _ param: UnsafeMutablePointer<IPC_PARAM>!, _ error_code: UnsafeMutablePointer<UINT>!) -> UnsafeMutablePointer<IPC>!{
 var ipc = IPC()
 ipc.Cedar = cedar
 ipc.ClientHostname = param.pointee.ClientHostname
 ipc.ArpTable = NewList(IPCCmpArpTable)
 ipc.Interrupt = NewInterruptManager();
 
 let ptr = salloc(IPC.self)
 ptr.pointee = ipc
 return ptr
 }
 
 func GetCancel(_ s:UnsafeMutablePointer<SESSION>?)->UnsafeMutablePointer<CANCEL>?{
 return nil
 }
 
 // IPC -> PA (Client Send)
 @_silgen_name("IPCSendL2")
 static func SIPCSendL2(_ ipc: UnsafeMutablePointer<IPC>!, _ data: UnsafeMutableRawPointer!, _ size: UINT){
 let ptr = UnsafeMutablePointer<Block>.allocate(capacity: 1)
 ptr.pointee = Block(data: Clone(data, size), size: size, next: nil)
 if let tail = Instance.inQueTail{
 tail.pointee.next = ptr
 }else{
 Instance.inQueHead = ptr
 }
 Instance.inQueTail = ptr
 }
 
 // PA (Client Send) -> Client
 func GetNextPacket(_ s: UnsafeMutablePointer<SESSION>!, _ pack: UnsafeMutablePointer<UnsafeMutableRawPointer?>!) -> UINT{
 if let ptr = inQueHead{
 let current = ptr.pointee
 let size = current.size
 pack.pointee = current.data
 inQueHead = current.next
 if ptr == inQueTail{
 inQueTail = nil
 }
 ptr.deallocate()
 return size
 }
 return 0
 }
 
 // PA (Client Recv) -> IPC
 @_silgen_name("IPCRecvL2")
 static func SIPCRecvL2(_ ipc: UnsafeMutablePointer<IPC>!) -> UnsafeMutablePointer<BLOCK>!{
 if let ptr = Instance.inQueHead{
 let current = ptr.pointee
 let b = NewBlock(current.data, current.size, 0)
 Instance.inQueHead = current.next
 if ptr == Instance.inQueTail{
 Instance.inQueTail = nil
 }
 ptr.deallocate()
 return b
 }
 return nil
 }
 
 // Client -> PA (Client Recv)
 func PutPacket(_ s:UnsafeMutablePointer<SESSION>?, _ data: UnsafeMutableRawPointer?, _ size: UINT)->UINT{
 if data == nil {
 return 1
 }
 
 let ptr = UnsafeMutablePointer<Block>.allocate(capacity: 1)
 ptr.pointee = Block(data: Clone(data, size), size: size, next: nil)
 if let tail = outQueTail{
 tail.pointee.next = ptr
 }else{
 outQueHead = ptr
 }
 outQueTail = ptr
 IPCProcessL3Events(ipc)
 return 1
 }
 
 // iOS -> PA
 var dataIOS:[Data]?
 var ipIOS:[NSNumber]?
 func recvPacket(){
 packetFlow.readPackets { (data, ipvs) in
 for i in 0...data.count{
 if ipvs[i] != 4{
 continue
 }
 data[i].withUnsafeBytes({ (ptr:UnsafePointer<UInt8>) in
 IPCSendIPv4(self.ipc, UnsafeMutableRawPointer(mutating: ptr), UINT(data[i].count))
 })
 }
 self.recvPacket()
 }
 }
 
 // PA -> iOS
 @_silgen_name("SendIOS")
 static func SSendIOS(_ data: UnsafeMutableRawPointer!, _ size: UINT){
 Instance.packetFlow.writePackets([Data(bytes: data, count: Int(size))], withProtocols: [5])
 }
 
 func SFree(_ s:UnsafeMutablePointer<SESSION>?){
 
 }
 
 
 }
 **/
