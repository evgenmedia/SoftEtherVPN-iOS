//
//  Util.swift
//  SoftEtherNE
//
//  Created by xy on 2018/7/27.
//

import Foundation
import UIKit

extension String{
    func setPtr( _ ptr:UnsafeMutableRawPointer){
        if var data = self.data(using: String.Encoding.utf8){
            data.append(0)
            data.withUnsafeBytes { (byt) in
                ptr.copyMemory(from: byt, byteCount: self.count+1)
            }
        }
    }
    
    func newPtr()->UnsafeMutableRawPointer{
        let rtn = Malloc(UINT((self.count+2)*MemoryLayout<UInt8>.size))!
        setPtr(rtn)
        return rtn
    }
}

func toSWString(_ of:UnsafeMutableRawPointer ) -> String{
    return String(cString: of.bindMemory(to: UInt8.self, capacity: 256))
}


@_silgen_name("CNSLog")
func CNSLog(_ pipe: UnsafeMutablePointer<UInt8>, _ msg: UnsafeMutableRawPointer){
    let str = toSWString(msg)
    let pi = toSWString(pipe)
    NSLog("%@: %@",pi,str)
}

var os_info:UnsafeMutablePointer<OS_INFO>?

@_silgen_name("GetOsInfo")
func GetOsInfo() -> UnsafeMutablePointer<OS_INFO>!{
    if let os = os_info{
        return os
    }
    var info = OS_INFO()
    info.OsProductName = "iOS".newPtr().assumingMemoryBound(to: Int8.self)
    info.OsVersion = String(UIDevice.current.systemVersion).newPtr().assumingMemoryBound(to: Int8.self)
    os_info = salloc(OS_INFO.self)
    os_info?.pointee = info
    return os_info
}

@_silgen_name("OSGetProductId")
func OSGetProductId() -> UnsafeMutablePointer<Int8>!{
    return "--".newPtr().assumingMemoryBound(to: Int8.self)
}

@_silgen_name("UINT64ToSystem")
func CUINT64ToSystem(_ st: UnsafeMutablePointer<SYSTEMTIME>!, _ sec64: UINT64){
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
    struct Tick{
        static var Start = Date()
    }
    
    return UINT64(Date().timeIntervalSince(Tick.Start)*1000)
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
    let exitFunc: (()->())?
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
        ptr = Unmanaged<NamedThread>.passRetained(self).toOpaque().assumingMemoryBound(to: THREAD.self)
        
        super.start()
    }
    
    override func main() {
        mainFunc(ptr!,param)
        NSLog("Exiting %@...", name ?? "unnamed")
        if let exit = exitFunc{
            exit()
        }
    }
    
    static func GetNamedThread(_ t: UnsafeMutablePointer<THREAD>)->NamedThread{
        let obj = Unmanaged<NamedThread>.fromOpaque(UnsafeMutableRawPointer(t))
        return obj.takeUnretainedValue()
    }
    
    
    @_silgen_name("NewThreadNamed")
    func NewThreadNamed(_ thread_proc: UnsafeMutableRawPointer, _ param:  UnsafeMutableRawPointer, _ name: UnsafeMutablePointer<Int8>!) -> UnsafeMutablePointer<THREAD>!{
        return NamedThread(getThreadProc(thread_proc),param,toSWString(name)).ptr!
    }
    
    @_silgen_name("WaitThreadInit")
    static func WaitThreadInit(_ t: UnsafeMutablePointer<THREAD>!){
        let nt = GetNamedThread(t)
        while(!nt.hasInit){
            nt.lock.wait()
        }
    }
    
    @_silgen_name("ReleaseThread")
    static func ReleaseThread(_ t: UnsafeMutablePointer<THREAD>!){
        //let obj = Unmanaged<NamedThread>.fromOpaque(UnsafeMutableRawPointer(t))
        //obj.release()
        
    }
    
    @_silgen_name("NoticeThreadInit")
    static func NoticeThreadInit(_ t: UnsafeMutablePointer<THREAD>!){
        let nt = GetNamedThread(t)
        nt.hasInit=true
        nt.lock.broadcast()
    }
}
