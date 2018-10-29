//
//  Memory.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/30.
//

import Foundation
import os.signpost

public func salloc<T>(_ type: T.Type)->UnsafeMutablePointer<T>{
    let ptr = ZeroMalloc(UINT(MemoryLayout<T>.size))!
//    NSLog("alloc \(T.self) @ \(ptr)")
    return ptr.assumingMemoryBound(to: T.self)
}

public func salloc<T>()->UnsafeMutablePointer<T>{
    return salloc(T.self)
}

//@_silgen_name("ZeroMalloc")
//public func CZeroMalloc(_ size: UINT) -> UnsafeMutableRawPointer!{
//    return SZeroMalloc(Int(size))
//}

@_silgen_name("Zero")
public func CZero(_ addr: UnsafeMutableRawPointer!, _ size: UINT){
    addr.initializeMemory(as: UInt8.self, repeating: 0, count: Int(size))
}
let memlock = NSCondition()
var memlist = [UnsafeMutableRawPointer:String]()

@_silgen_name("ZeroMallocEx")
func SZeroMallocEx(_ size: UINT, _ zero_clear_when_free: bool) -> UnsafeMutableRawPointer!{
    let ptr = CMalloc(size)
    CZero(ptr, size)
    return ptr
}

@_silgen_name("MallocEx")
func SMallocEx(_ size: UINT, _ zero_clear_when_free: bool) -> UnsafeMutableRawPointer!{
    return CMalloc(size)
}

//@_silgen_name("InternalMalloc")
@_silgen_name("Malloc")
public func CMalloc(_ size: UINT) -> UnsafeMutableRawPointer!{
    let ptr = UnsafeMutableRawPointer.allocate(byteCount: Int(size), alignment: 0)
//    let ptr = malloc(Int(size))!
    if doLog {
        var log = true
        var str = ""
        var i = 0
        memlock.lock()
        for symbol in Thread.callStackSymbols {
            if symbol.contains("Malloc"){
                continue
            }
            if symbol.contains("ARP"){
                log = false
                break
            }
            let index = symbol.index(str.startIndex, offsetBy: 59)
            let a = symbol.substring(from: index)
            let end = a.firstIndex(of: " ")
            
            str.append(a.substring(to: end!))
            str.append(" <- ")
            i+=1
            if i>7{
                break
            }
        }
//        NSLog("Malloc \(ptr):\n\(str)")
        if log{
            memlist[ptr]=str
        }
        memlock.unlock()
        
    }
    let diff = ptr.distance(to: UnsafeMutableRawPointer(bitPattern: 0x0000000200000000)!)
    if diff <= 0{
        return nil
    }
    return ptr
}

func getMEM(){
    for m in memlist{
        NSLog("Pointer: \(m)")
    }
}

//public func SMalloc(_ size: Int) -> UnsafeMutableRawPointer{
//    return
//}
//
//func SZeroMalloc(_ size: Int) -> UnsafeMutableRawPointer{
//    let ptr = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 0)
//    ptr.initializeMemory(as: UInt8.self, repeating: 0, count: size)
//    return ptr
//}

@_silgen_name("Copy")
public func SCopy(_ dst: UnsafeMutableRawPointer!, _ src: UnsafeMutableRawPointer!, _ size: UINT){
    dst.copyMemory(from: src, byteCount: Int(size))
}
var freeOnly = [UnsafeMutableRawPointer]()

var doLog = false
// p doLog = true
//@_silgen_name("InternalFree")
@_silgen_name("Free")
public func CFree(_ addr: UnsafeMutableRawPointer?){
    guard let addr = addr else {
        return
    }
    if doLog{
        let diff = addr.distance(to: UnsafeMutableRawPointer(bitPattern: 0x0000000200000000)!)
        if diff <= 0{
            return
        }
        memlock.lock()
        if memlist.removeValue(forKey: addr) == nil {
            freeOnly.append(addr)
        }
        memlock.unlock()
    }
    
    // Deallocate is some how not thread safe
//    freeQue.sync {
    addr.deallocate()
//    }
}
//let freeLock = NSCondition()
let freeQue = DispatchQueue.init(label: "FreeQueue")
//@_silgen_name("InternalReAlloc")
@_silgen_name("ReAlloc")
func InternalReAlloc(_ addr: UnsafeMutableRawPointer!, _ size: UINT) -> UnsafeMutableRawPointer!{
    let ptr = realloc(addr,Int(size))
    if ptr!.distance(to: UnsafeMutableRawPointer(bitPattern: 0x0000000200000000)!) <= 0{
        return nil
    }
    return ptr
}



let QueueLog:OSLog = .disabled //OSLog(subsystem:"tech.nsyd.se.SENE", category:"Queue")
class QueueHandle<T> {
    var head:UnsafeMutablePointer<QLink>?
    var tail:UnsafeMutablePointer<QLink>?
    var queEvent:((T)->Void)?
    var size:UINT {
        get{
            return que.pointee.num_item
        }
        set{
            que.pointee.num_item = newValue
        }
    }
    let sync = DispatchQueue(label:"Queue")
    let que:UnsafeMutablePointer<QUEUE> = salloc()
    
    init() {
        que.pointee.ref = ToOpaque(self)
    }
    
    func enqueue(_ data:T){
        if let event = queEvent{
            while size>0, let d = dequeue(){
                event(d)
            }
            event(data)
            return
        }
        sync.sync {
            self.size += 1
            let q = QLink(data: data, track: OSSignpostID(log: QueueLog), next: nil)
            let ptr = UnsafeMutablePointer<QLink>.allocate(capacity: 1)
            ptr.initialize(to: q)
            if head == nil{
                tail = ptr
                head = ptr
            }else{
                tail?.pointee.next = ptr
                tail = ptr
            }
            
            os_signpost(.begin, log: QueueLog, name: "Obj", signpostID: q.track)
        }
    }
    
    func dequeue() -> (T)? {
        return sync.sync {
            guard let head = head else{
                return nil
            }
            self.size -= 1
            self.head = head.pointee.next
            
            let data = head.pointee.data
            
            os_signpost(.end, log: QueueLog, name: "Obj", signpostID: head.pointee.track)
            
            head.deallocate()
            
            return data
        }
    }
    
    struct QLink {
        let data:T
        var track:OSSignpostID
        var next:UnsafeMutablePointer<QLink>?
        
    }
    deinit {
        que.deallocate()
    }
    
    
}

func GetQueue(_ q: UnsafeMutablePointer<QUEUE>!) -> QueueHandle<UnsafeMutableRawPointer>?{
    guard let q = q else {
        return nil
    }
    return GetOpaque(q.pointee.ref)
}

@_silgen_name("NewQueueFast")
func SNewQueueFast() -> UnsafeMutablePointer<QUEUE>!{
    return SNewQueue()
}

@_silgen_name("NewQueue")
func SNewQueue() -> UnsafeMutablePointer<QUEUE>!{
    return QueueHandle<UnsafeMutableRawPointer>().que
}

@_silgen_name("GetNext")
func SGetNext(_ q: UnsafeMutablePointer<QUEUE>!) -> UnsafeMutableRawPointer!{
    guard let que = GetQueue(q) else{
        return nil
    }
    return que.dequeue()
}

@_silgen_name("GetQueueNum")
func SGetQueueNum(_ q: UnsafeMutablePointer<QUEUE>!) -> UINT{
    guard let que = GetQueue(q) else{
        return 0
    }
    return que.size
}


@_silgen_name("InsertQueueWithLock")
func SInsertQueueWithLock(_ q: UnsafeMutablePointer<QUEUE>!, _ p: UnsafeMutableRawPointer!){
    guard let que = GetQueue(q) else{
        return
    }
    que.enqueue(p)
}

@_silgen_name("InsertQueue")
func SInsertQueue(_ q: UnsafeMutablePointer<QUEUE>!, _ p: UnsafeMutableRawPointer!){
    SInsertQueueWithLock(q,p)
}

@_silgen_name("ReleaseQueue")
func SReleaseQueue(_ q: UnsafeMutablePointer<QUEUE>!){
    guard let q = q else {
        return
    }
    ReleaseOpaque(q.pointee.ref)
}
