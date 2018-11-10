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
    static var i:PackAdapterInstance!
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
            
            settings.dnsSettings = NEDNSSettings(servers: ["1.1.1.1","8.8.8.8"])
            
            settings.mtu = 1500
            
            pt!.setTunnelNetworkSettings(settings, completionHandler: { (err) in
                if let e = err{
                    self.state = .canceled
                    self.SFree(s)
                }
            })
            
            self.recvPacket()
            GetQueue(self.ipc.pointee.IPv4ReceivedQueue)!.queEvent = self.forwardIPv4
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
        withUnsafeMutablePointer(to: &ipc.MacAddress) { (ptr) in GenMacAddress(UnsafeMutableRawPointer(ptr).assumingMemoryBound(to: UCHAR.self))
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
        guard let datas = IPC2PA.dequeue() else{
            return state == .canceled ? INFINITE : 0
        }
        pack.pointee = datas.0
        return datas.1
    }
    
    // Client -> PA -> IPC(SendTube)
    func PutPacket(_ s:UnsafeMutablePointer<SESSION>?, _ data: UnsafeMutableRawPointer?, _ size: UINT)->UINT{
        guard let data = data else {
            return 1
        }
        PA2IPC.enqueue((data, size))
        
        // Signal Read -> main()
        cond.broadcast()
        return 1
    }
    
    let IPC2PA = QueueHandle<(UnsafeMutableRawPointer,UINT)>()
    let PA2IPC = QueueHandle<(UnsafeMutableRawPointer,UINT)>()
    
    //  IPC(SendTube) -> PA -> Client
    // data is stack allocated!
    @_silgen_name("IPCSendL2")
    static func SIPCSendL2(_ ipc: UnsafeMutablePointer<IPC>!, _ data: UnsafeMutableRawPointer!, _ size: UINT){
        i.IPC2PA.enqueue((Clone(data, size), size))
    }
    
    // Client -> PA -> IPC(SendTube)
    @_silgen_name("IPCRecvL2")
    static func SIPCRecvL2(_ ipc: UnsafeMutablePointer<IPC>!) -> UnsafeMutablePointer<BLOCK>!{
        guard let datas = i.PA2IPC.dequeue() else{
            return nil
        }
        return NewBlock(datas.0, datas.1, 0)
    }
    // L3 -> L2
    // iOS -> PA
    func recvPacket(){
        if state == .canceled {
            return
        }
        
        packetFlow.readPackets { (data, ipvs) in
            var i = 0
            for d in data{
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
    
    static let Timeout = TimeInterval(0.7*Double(TIMEOUT_DEFAULT/1000)) // TODO
    
    let forwardIPv4Que = DispatchQueue.init(label: "forwardIPv4Que")
    
    //Ipv4 -> packetFlow
    func forwardIPv4(_ block: UnsafeMutableRawPointer) {
        forwardIPv4Que.async {
            let block = block.assumingMemoryBound(to: BLOCK.self)
            let data = Data(bytesNoCopy: block.pointee.Buf, count: Int(block.pointee.Size), deallocator: .free)
            self.packetFlow.writePackets([data], withProtocols: [NSNumber(value: AF_INET)])
            Free(block)
        }
    }
    
    // L2 -> L3
    override func main() {
        while(state == .running){
            IPCProcessL3Events(ipc)
            cond.wait(until: Date().addingTimeInterval(PackAdapterInstance.Timeout))
        }
    }
    
    @_silgen_name("SendPacketv4")
    func SSendPacketv4(_ data: UnsafeMutableRawPointer!, _ size: UINT){
        PackAdapterInstance.i?.packetFlow.writePackets([Data(bytes: data, count: Int(size))], withProtocols: [NSNumber(value: AF_INET)])
    }
}

//class DataQueueHandle:QueueHandle<(UnsafeMutableRawPointer,UINT)> {
//    func enqueue(_ data:UnsafeMutableRawPointer,_ size:UINT){
//        super.enqueue((data, size))
//    }
//
//    override func dequeue() -> (UnsafeMutableRawPointer,UINT)? {
//        guard let data = super.dequeue() else{
//            return nil
//        }
//        return (data.0,data.1)
//    }
//}

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
