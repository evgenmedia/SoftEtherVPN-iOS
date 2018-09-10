//
//  Object.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/30.
//

import Foundation


class Counter:NSObject{
    var i:UINT = 0
    var value: UINT{
        get{
            var inter:UINT = 0
            dq.async {
                inter = self.i
            }
            return inter
        }
        set(i){
            dq.async(flags: .barrier) {
                self.i=i
            }
        }
    }
    var dq = DispatchQueue(label: "tech.nsyd.se.Counter", attributes: .concurrent)
    @_silgen_name("NewCounter")
    public static func NewCounter() -> UnsafeMutablePointer<COUNTER>!{
        var c = Counter()
        withUnsafeBytes(of: &c) {
            NSLog("stack alloc \($0)")
        }
        let i = Unmanaged<Counter>.passRetained(c)
        NSLog("alloc \(i.toOpaque())")
        return i.toOpaque().assumingMemoryBound(to: COUNTER.self)
    }

    @_silgen_name("DeleteCounter")
    public static func DeleteCounter(_ c: UnsafeMutablePointer<COUNTER>!){
        let obj = Unmanaged<Counter>.fromOpaque(c)
        obj.release()
    }

    @_silgen_name("Count")
    public static func Count(_ c: UnsafeMutablePointer<COUNTER>!) -> UINT{
        let ptr = Unmanaged<Counter>.fromOpaque(c)
        let obj = ptr.takeUnretainedValue()
        return obj.value
    }

    @_silgen_name("Inc")
    public static func Inc(_ c: UnsafeMutablePointer<COUNTER>!) -> UINT{
        let ptr = Unmanaged<Counter>.fromOpaque(c)
        let obj = ptr.takeUnretainedValue()
        obj.value+=1
        return obj.value
    }

    @_silgen_name("Dec")
    public static func Dec(_ c: UnsafeMutablePointer<COUNTER>!) -> UINT{
        let ptr = Unmanaged<Counter>.fromOpaque(c)
        let obj = ptr.takeUnretainedValue()
        obj.value-=1
        return obj.value
    }
}
