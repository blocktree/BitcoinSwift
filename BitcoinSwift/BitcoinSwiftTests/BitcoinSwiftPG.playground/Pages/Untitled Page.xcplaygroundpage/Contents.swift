//: Playground - noun: a place where people can play

#if os(Linux) || os(Android) || os(FreeBSD)
    import Glibc
#else
    import Darwin
#endif

import Foundation
import BitcoinSwift

var str = "Hello, playground"

let data = str.data(using: String.Encoding.utf8)!
let u8: [UInt8] = [UInt8](data)
let newData = Data(bytes: u8)
let newStr = String(data: newData, encoding: String.Encoding.utf8)
let size = MemoryLayout<UInt64>.size

do {
    let key = try BTCKey()
    let keyData = key.privateKey!
} catch {
    
}

