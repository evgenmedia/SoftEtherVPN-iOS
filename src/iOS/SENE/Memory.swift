//
//  Memory.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/30.
//

import Foundation


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

@_silgen_name("InternalMalloc")
public func CMalloc(_ size: UINT) -> UnsafeMutableRawPointer!{
    return UnsafeMutableRawPointer.allocate(byteCount: Int(size), alignment: 0)
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
public func CCopy(_ dst: UnsafeMutableRawPointer!, _ src: UnsafeMutableRawPointer!, _ size: UINT){
    dst.copyMemory(from: src, byteCount: Int(size))
}

@_silgen_name("InternalFree")
public func CFree(_ addr: UnsafeMutableRawPointer!){
    addr.deallocate()
}

@_silgen_name("InternalReAlloc")
func InternalReAlloc(_ addr: UnsafeMutableRawPointer!, _ size: UINT) -> UnsafeMutableRawPointer!{
    return realloc(addr,Int(size))
}













//class List:NSObject{
//    var lock = NSLock()
//    var list = [UnsafeMutableRawPointer]()
//    var sorted = false
//    var cmp : ((UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Int32?)?
//    
//    init(_ cmp: (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Int32)!) {
//        self.cmp = cmp
//    }
//    
//    func c(_ e1:UnsafeMutableRawPointer?, _ e2:UnsafeMutableRawPointer?) -> Bool{
//        if let fn = cmp{
//            return fn(e1,e2)! > 0
//        }
//        return false
//    }
//    
//    @_silgen_name("NewListFast")
//    public static func NewListFast(_ cmp: (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Int32)!) -> UnsafeMutablePointer<LIST>!{
//        return NewList(cmp)
//    }
//    
//    @_silgen_name("NewList")
//    public static func NewList(_ cmp: (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Int32)!) -> UnsafeMutablePointer<LIST>!{
//        let i = Unmanaged<List>.passRetained(List(cmp))
//        return i.toOpaque().assumingMemoryBound(to: LIST.self)
//    }
//    
//    @_silgen_name("ToArrayEx")
//    public static func ToArrayEx(_ o: UnsafeMutablePointer<LIST>!, _ fast: bool) -> UnsafeMutableRawPointer!{
//        if o == nil { return nil }
//        return nil
//    }
//    @_silgen_name("ToArray")
//    public static func ToArray(_ o: UnsafeMutablePointer<LIST>!) -> UnsafeMutableRawPointer!{
//        if o == nil { return nil }
//        return nil
//    }
//    @_silgen_name("Insert")
//    public static func Insert(_ o: UnsafeMutablePointer<LIST>!, _ p: UnsafeMutableRawPointer!){
//        let ptr = Unmanaged<List>.fromOpaque(o)
//        let obj = ptr.takeUnretainedValue()
//        if !obj.sorted{
//            Sort(o)
//        }
//        if obj.cmp != nil{
//            if let index = obj.list.index(where: { obj.c($0 , p) }) {
//                obj.list.insert(p, at: index)
//            }
//        }else{
//            Add(o, p)
//        }
//    }
//    
//    
//    @_silgen_name("Search")
//    public static func Search(_ o: UnsafeMutablePointer<LIST>!, _ target: UnsafeMutableRawPointer!) -> UnsafeMutableRawPointer!{
//        if o == nil || target == nil { return nil }
//        let ptr = Unmanaged<List>.fromOpaque(o)
//        let obj = ptr.takeUnretainedValue()
//        if let c = obj.cmp  {
//            if let index = obj.list.index(where:{(item) -> Bool in
//                return c(item,target) == 0
//            }){
//                return obj.list[index]
//            }
//        }
//        return nil
//    }
//    @_silgen_name("Delete")
//    public static func Delete(_ o: UnsafeMutablePointer<LIST>!, _ p: UnsafeMutableRawPointer!) -> bool{
//        if o == nil || p == nil { return 0 }
//        let ptr = Unmanaged<List>.fromOpaque(o)
//        let obj = ptr.takeUnretainedValue()
//        if let pos = obj.list.firstIndex(of: p){
//            obj.list.remove(at: pos)
//            return 1
//        }
//        return 0
//    }
//    
//    @_silgen_name("DeleteAll")
//    public static func DeleteAll(_ o: UnsafeMutablePointer<LIST>!){
//        if o == nil { return }
//        let ptr = Unmanaged<List>.fromOpaque(o)
//        let obj = ptr.takeUnretainedValue()
//        obj.list.removeAll()
//    }
//    
//    @_silgen_name("Add")
//    public static func Add(_ o: UnsafeMutablePointer<LIST>!, _ p: UnsafeMutableRawPointer!){
//        if o == nil || p == nil { return }
//        let ptr = Unmanaged<List>.fromOpaque(o)
//        let obj = ptr.takeUnretainedValue()
//        obj.list.append(p)
//    }
//    
//    @_silgen_name("Sort")
//    public static func Sort(_ o: UnsafeMutablePointer<LIST>!){
//        if o == nil { return }
//        let ptr = Unmanaged<List>.fromOpaque(o)
//        let obj = ptr.takeUnretainedValue()
//        if  obj.cmp != nil{
//            obj.list.sort { obj.c($0,$1) }
//        }
//        obj.sorted = true
//    }
//    
//    @_silgen_name("LockList")
//    public static func LockList(_ o: UnsafeMutablePointer<LIST>!){
//        if o == nil { return }
//        let ptr = Unmanaged<List>.fromOpaque(o)
//        let obj = ptr.takeUnretainedValue()
//        obj.lock.lock()
//    }
//    
//    @_silgen_name("UnlockList")
//    public static func UnlockList(_ o: UnsafeMutablePointer<LIST>!){
//        if o == nil { return }
//        let ptr = Unmanaged<List>.fromOpaque(o)
//        let obj = ptr.takeUnretainedValue()
//        obj.lock.unlock()
//    }
//    
//    @_silgen_name("ReleaseList")
//    public static func ReleaseList(_ o: UnsafeMutablePointer<LIST>!){
//        if o == nil { return }
//        let obj = Unmanaged<List>.fromOpaque(o)
//        obj.release()
//    }
//}
