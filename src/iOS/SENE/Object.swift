//
//  Object.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/30.
//

import Foundation


class Counter{ // Author: nestserau@github
    private let lock = DispatchSemaphore(value: 1)
    private var _value: UINT
    
    public init(value initialValue: UINT = 0) {
        _value = initialValue
    }
    
    public var value: UINT {
        get {
            lock.wait()
            defer { lock.signal() }
            return _value
        }
        set {
            lock.wait()
            defer { lock.signal() }
            _value = newValue
        }
    }
    
    public func decrementAndGet() -> UINT {
        lock.wait()
        defer { lock.signal() }
        _value -= 1
        return _value
    }
    
    public func incrementAndGet() -> UINT {
        lock.wait()
        defer { lock.signal() }
        _value += 1
        return _value
    }
    
    @_silgen_name("NewCounter")
    public static func CNewCounter() -> UnsafeMutablePointer<COUNTER>!{
        let i = Unmanaged<Counter>.passRetained(Counter())
        return i.toOpaque().assumingMemoryBound(to: COUNTER.self)
    }

    @_silgen_name("DeleteCounter")
    public static func CDeleteCounter(_ c: UnsafeMutablePointer<COUNTER>!){
        let obj = Unmanaged<Counter>.fromOpaque(c)
        obj.release()
    }

    @_silgen_name("Count")
    public static func CCount(_ c: UnsafeMutablePointer<COUNTER>!) -> UINT{
        let ptr = Unmanaged<Counter>.fromOpaque(c)
        let obj = ptr.takeUnretainedValue()
        return obj.value
    }

    @_silgen_name("Inc")
    public static func CInc(_ c: UnsafeMutablePointer<COUNTER>!) -> UINT{
        let ptr = Unmanaged<Counter>.fromOpaque(c)
        let obj = ptr.takeUnretainedValue()
        return obj.incrementAndGet()
    }

    @_silgen_name("Dec")
    public static func CDec(_ c: UnsafeMutablePointer<COUNTER>!) -> UINT{
        let ptr = Unmanaged<Counter>.fromOpaque(c)
        let obj = ptr.takeUnretainedValue()
        return obj.decrementAndGet()
    }
}

class Event : NSCondition{
    private let lock = DispatchSemaphore(value: 1)
    private var _value: UInt32 = 0
    
    public var value: UInt32 {
        get {
            lock.wait()
            defer { lock.signal() }
            return _value
        }
        set {
            lock.wait()
            defer { lock.signal() }
            _value = newValue
        }
    }
    
    @_silgen_name("NewEvent")
    public static func CNewEvent() -> UnsafeMutablePointer<EVENT>!{
        let i = Unmanaged<Event>.passRetained(Event())
        return i.toOpaque().assumingMemoryBound(to: EVENT.self)
    }


    @_silgen_name("ReleaseEvent")
    public static func CReleaseEvent(_ e: UnsafeMutablePointer<EVENT>!){
        let obj = Unmanaged<Event>.fromOpaque(e)
        obj.release()
    }

    @_silgen_name("Set")
    public static func CSet(_ e: UnsafeMutablePointer<EVENT>!){
        let ptr = Unmanaged<Event>.fromOpaque(e)
        let obj = ptr.takeUnretainedValue()
        obj.value = 1
        obj.signal()
        
    }

    // return 0 on timeout
    @_silgen_name("Wait")
    public static func CWait(_ e: UnsafeMutablePointer<EVENT>!, _ timeout: UINT) -> bool{
        if e == nil {
            return 0
        }
        let ptr = Unmanaged<Event>.fromOpaque(e)
        let obj = ptr.takeUnretainedValue()
        defer {
            obj.value = 0
        }
        if timeout == INFINITE{
            while obj.value == 0 {
                obj.wait()
            }
        }else{
            let until = Date().addingTimeInterval(TimeInterval(timeout))
            while obj.value == 0 {
                return obj.wait(until: until) ? 1 : 0
            }
        }
        return 1
    }

    @_silgen_name("WaitEx")
    public static func CWaitEx(_ e: UnsafeMutablePointer<EVENT>!, _ timeout: UINT, _ cancel: UnsafeMutablePointer<bool>!) -> bool{
        return 0
    }
}


class Lock : NSRecursiveLock{
    // value = 0 => ready
    @_silgen_name("NewLock")
    public static func CNewLock() -> UnsafeMutablePointer<LOCK>!{
        let i = Unmanaged<Lock>.passRetained(Lock())
        return i.toOpaque().assumingMemoryBound(to: LOCK.self)
    }
    
    @_silgen_name("DeleteLock")
    public static func CDeleteLock(_ lock: UnsafeMutablePointer<LOCK>!){
        let obj = Unmanaged<Lock>.fromOpaque(lock)
        obj.release()
    }
    
    @_silgen_name("UnlockInner")
    public static func CUnlockInner(_ lock: UnsafeMutablePointer<LOCK>!){
        let ptr = Unmanaged<Lock>.fromOpaque(lock)
        let obj = ptr.takeUnretainedValue()
        obj.unlock()
    }
    
    @_silgen_name("LockInner")
    public static func CLockInner(_ lock: UnsafeMutablePointer<LOCK>!) -> bool{
        let ptr = Unmanaged<Lock>.fromOpaque(lock)
        let obj = ptr.takeUnretainedValue()
        return obj.try() ? 1 : 0
    }
    
    @_silgen_name("NewLockMain")
    public static func CNewLockMain() -> UnsafeMutablePointer<LOCK>!{
        return CNewLock()
    }
}


