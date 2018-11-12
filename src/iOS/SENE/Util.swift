//
//  Util.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/27.
//

import Foundation
//import UIKit

extension String{
    func setPtr( _ ptr:UnsafeMutableRawPointer){
        withCString { (str) in
            ptr.copyMemory(from: str, byteCount: self.count+1)
        }
//        if var data = self.data(using: String.Encoding.utf8){
//            data.append(0)
//
//            data.withUnsafeBytes { (byt) in
//                ptr.copyMemory(from: byt, byteCount: self.count+1)
//            }
//        }
    }
    
    func newPtr()->UnsafeMutableRawPointer{
        let rtn = Malloc(UINT((self.count+2)*MemoryLayout<UInt8>.size))!
        setPtr(rtn)
        return rtn
    }
}

//func toSWString(_ of:UnsafeMutableRawPointer ) -> String{
//    return String(cString: of)
//}



@_silgen_name("CNSLog")
func SNSLog(_ pipe: UnsafeMutablePointer<UInt8>, _ msg: UnsafeMutablePointer<UInt8>){
    let str = String(cString: msg)
    let pi = String(cString: pipe)
    NSLog("%@: %@",pi,str)
}

var os_info:UnsafeMutablePointer<OS_INFO>?

@_silgen_name("GetOsInfo")
func SGetOsInfo() -> UnsafeMutablePointer<OS_INFO>!{
    if let os = os_info{
        return os
    }
    var info = OS_INFO()
    info.OsProductName = "iOS".newPtr().assumingMemoryBound(to: Int8.self)
//    info.OsVersion = String(UIDevice.current.systemVersion).newPtr().assumingMemoryBound(to: Int8.self)
    os_info = salloc(OS_INFO.self)
    os_info?.pointee = info
    return os_info
}

@_silgen_name("OSGetProductId")
func SOSGetProductId() -> UnsafeMutablePointer<Int8>!{
    return "--".newPtr().assumingMemoryBound(to: Int8.self)
}

@_silgen_name("UINT64ToSystem")
func SUINT64ToSystem(_ st: UnsafeMutablePointer<SYSTEMTIME>!, _ sec64: UINT64){
    let date = Date.init(timeIntervalSince1970: TimeInterval(sec64/1000))
    var time = SYSTEMTIME()
    let calendar = Calendar.current
    time.wDay = WORD(calendar.component(.day, from: date))
    time.wHour = WORD(calendar.component(.hour, from: date))
    time.wYear = WORD(calendar.component(.year, from: date))
    time.wMonth = WORD(calendar.component(.month, from: date))
    time.wDayOfWeek = WORD(calendar.component(.weekday, from: date))
    time.wMilliseconds = WORD(calendar.component(.nanosecond, from: date)*1000)
    time.wMinute = WORD(calendar.component(.minute, from: date))
    time.wSecond = WORD(calendar.component(.second, from: date))
    st.pointee = time
    
}

@_silgen_name("SystemTime64")
func CSystemTime64() -> UINT64{
    return UINT64(Date().timeIntervalSince1970*1000)
}



@_silgen_name("Tick64")
func CTick64() -> UINT64{
    struct TickStart{
        // first evluated when used, it on the right of - in return, it will be smaller than now()
        static var value = DispatchTime.now().uptimeNanoseconds/1000000 - 50001
    }
    return DispatchTime.now().uptimeNanoseconds/1000000 - TickStart.value
}

@_silgen_name("TickHighres64")
func CTickHighres64() -> UINT64{
    return Tick64()
}

@_silgen_name("GetGlobalServerFlag")
func GetGlobalServerFlag(_ index: UINT) -> UINT{
    if index == GSF_DISABLE_SESSION_RECONNECT{
        return 0
    }
    return 1
}



class NamedThread: Thread {
    let mainFunc:THREAD_PROC
    var exitFunc: (()->())?
    let param:UnsafeMutableRawPointer?
    var ptr:UnsafeMutablePointer<THREAD>?
    let lock = NSCondition()
    var hasInit = false
    
    
    init(_ thread_proc: @escaping THREAD_PROC, _ param: UnsafeMutableRawPointer!,_ name: String,_ exit: (()->())? = nil) {
        mainFunc=thread_proc
        self.param=param
        exitFunc=exit
        super.init()
        
        super.name=name
        ptr = ToOpaque(self)
        
        super.start()
    }
    
    override func main() {
        mainFunc(ptr!,param)
        NSLog("Exiting %@...", name ?? "unnamed")
        if let exit = exitFunc{
            exit()
        }
    }
    
    @_silgen_name("NewThreadNamed")
    static func SNewThreadNamed(_ thread_proc: @escaping @convention(c) (UnsafeMutablePointer<THREAD>?, UnsafeMutableRawPointer?) -> Void, _ param:  UnsafeMutableRawPointer, _ name: UnsafeMutablePointer<Int8>!) -> UnsafeMutablePointer<THREAD>!{
        return NamedThread(thread_proc,param,String(cString: name)).ptr!
    }
    
    @_silgen_name("WaitThreadInit")
    static func SWaitThreadInit(_ t: UnsafeMutablePointer<THREAD>!){
        guard let nt:NamedThread = GetOpaque(t) else{
            return
        }
        while(!nt.hasInit){
            nt.lock.wait()
        }
    }
    
    @_silgen_name("ReleaseThread")
    static func SReleaseThread(_ t: UnsafeMutablePointer<THREAD>!){
        //ReleaseOpaque(t)
    }
    
    @_silgen_name("NoticeThreadInit")
    static func SNoticeThreadInit(_ t: UnsafeMutablePointer<THREAD>!){
        guard let nt:NamedThread = GetOpaque(t) else{
            return
        }
        nt.hasInit=true
        nt.lock.broadcast()
    }
}

func GetOpaque<T:AnyObject>(_ ptr: UnsafeRawPointer?)->T?{
    guard let p = ptr else {
        return nil
    }
    let opq = Unmanaged<T>.fromOpaque(p)
    return opq.takeUnretainedValue()
}

func ToOpaque<T:AnyObject,S>(_ obj: T)->UnsafeMutablePointer<S>{
    let i = Unmanaged<T>.passRetained(obj)
    i.retain()
    return i.toOpaque().assumingMemoryBound(to: S.self)
}

func ReleaseOpaque(_ ptr: UnsafeRawPointer?){
    guard let p = ptr else {
        return
    }
    Unmanaged<AnyObject>.fromOpaque(p).release()
}

func timeoutDate(_ time: UINT) -> Date {
    return timeoutDate(Double(time))
}

func timeoutDate(_ time: Int) -> Date {
    return timeoutDate(Double(time))
}

func timeoutDate(_ time: Double) -> Date {
    return Date().addingTimeInterval(TimeInterval(time))
}

func DispatchTimeout(_ miliseconds: UInt32)->DispatchTime{
    return DispatchTimeout(UInt64(miliseconds)*1000000)
}
func DispatchTimeout(_ nanoseconds: UInt64)->DispatchTime{
    return DispatchTime(uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds + nanoseconds)
}

// true on success
@discardableResult
func SemaphoreWait(_ ds: DispatchSemaphore, _ miliseconds: UInt32)->Bool{
    return ds.wait(timeout: DispatchTimeout(miliseconds)) == .success
}

@discardableResult
func SemaphoreWait(_ ds: DispatchSemaphore, until miliseconds: UInt32)->Bool{
    return ds.wait(timeout: DispatchTime(uptimeNanoseconds: UInt64(miliseconds)*1000000)) == .success
}
