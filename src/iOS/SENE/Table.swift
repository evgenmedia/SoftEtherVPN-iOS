//
//  Table.swift
//  SENE
//
//  Created by Shuyi Dong on 2018-10-07.
//

import Foundation


extension NSError : LocalizedError{
    public var errorDescription: String? { return NSLocalizedString("ERR_\(self.code)", comment: "") }
}


var resUni: [String:UnsafeMutablePointer<wchar_t>] = [:]
var res: [String:UnsafeMutableRawPointer] = [:]

@_silgen_name("GetTableUniStr")
public func GetTableUniStr(_ name: UnsafeMutablePointer<UInt8>)->UnsafeMutablePointer<wchar_t>{
    let key = toSWString(name)
    var value = resUni[key]
    if value == nil {
        let strPtr = GetTableStr(name)
        let strl = strlen(UnsafeMutableRawPointer(strPtr).assumingMemoryBound(to: Int8.self))
        value = SMalloc((strl+2)*MemoryLayout<wchar_t>.size).assumingMemoryBound(to: wchar_t.self)
        UnixStrToUni(value,UINT((strl+2)*MemoryLayout<wchar_t>.size),
                      res[key]?.assumingMemoryBound(to: Int8.self))
        resUni[key] = value
    }
    return value!
}

@_silgen_name("GetTableStr")
public func GetTableStr(_ name: UnsafeMutablePointer<UInt8>)->UnsafeMutablePointer<UInt8>{
    let key = toSWString(name)
    var value = res[key]
    if value == nil {
        let str = NSLocalizedString(key, comment: "")
        if str == key{
            value = "".newPtr()
        }else{
            value = str.newPtr()
        }
        res[key] = value
    }
    return value!.assumingMemoryBound(to: UInt8.self)
}

