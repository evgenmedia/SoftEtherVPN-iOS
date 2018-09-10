//
//  Util.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/27.
//

import Foundation

extension String{
    func setPtr( _ ptr:UnsafeMutableRawPointer){
        if var data = self.data(using: String.Encoding.utf8){
            data.append(0)
            data.withUnsafeBytes { (byt) in
                ptr.copyMemory(from: byt, byteCount: self.count+1)
            }
        }
    }
}

func toSWString(_ of:UnsafeMutableRawPointer ) -> String{
    return String(cString: of.bindMemory(to: UInt8.self, capacity: 256))
    }

public func salloc<T>(_ type: T.Type)->UnsafeMutablePointer<T>{
    let ptr = ZeroMalloc(MemoryLayout<T>.size)
    NSLog("alloc \(T.self) @ \(ptr)")
    return ptr.assumingMemoryBound(to: T.self)
}

@_silgen_name("ZeroMalloc")
public func CZeroMalloc(_ size: UINT) -> UnsafeMutableRawPointer!{
    return ZeroMalloc(Int(size))
}

@_silgen_name("Zero")
public func CZero(_ addr: UnsafeMutableRawPointer!, _ size: UINT){
    addr.initializeMemory(as: UInt8.self, repeating: 0, count: Int(size))
}

@_silgen_name("Malloc")
public func Malloc(_ size: UINT) -> UnsafeMutableRawPointer!{
    return UnsafeMutableRawPointer.allocate(byteCount: Int(size), alignment: 0)
}

func ZeroMalloc(_ size: Int) -> UnsafeMutableRawPointer{
    let ptr = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 0)
    ptr.initializeMemory(as: UInt8.self, repeating: 0, count: size)
    return ptr
}

@_silgen_name("Copy")
public func Copy(_ dst: UnsafeMutableRawPointer!, _ src: UnsafeMutableRawPointer!, _ size: UINT){
    dst.copyMemory(from: src, byteCount: Int(size))
}

@_silgen_name("Free")
public func Free(_ addr: UnsafeMutableRawPointer!){
    addr.deallocate()
}
