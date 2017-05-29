//: Playground - noun: a place where people can play

#if os(Linux) || os(Android) || os(FreeBSD)
    import Glibc
#else
    import Darwin
#endif

import Foundation
import BitcoinSwift
import Libsecp256k1

var str = "Hello, playground"

let data = str.data(using: String.Encoding.utf8)!
//let u32: [UInt32] = data.get(at: 0, UInt32.self)!
let subdata = Data(data.prefix(4))
let u8: [UInt8] = [UInt8](data)
let newData = Data(bytes: u8)
let newStr = String(data: newData, encoding: String.Encoding.utf8)
let size = MemoryLayout<Int8>.stride

let nextnew = data.advanced(by: 1).u8

let base58 = "11111234ff43fhghbr4toblsjpqitigvonort"
let base58Data = BTCBase58.decode(with: base58)


let num: [UInt8] = [5,6,7,8,9]
let num2: [UInt8] = [7,5,6,8,9]

print(num == num2)

let type_com = SECP256K1_FLAGS_TYPE_COMPRESSION
let bit_com = SECP256K1_FLAGS_BIT_COMPRESSION
let compression = (SECP256K1_FLAGS_TYPE_COMPRESSION | SECP256K1_FLAGS_BIT_COMPRESSION)

let uncompression = SECP256K1_FLAGS_TYPE_COMPRESSION

let com = SECP256K1_EC_COMPRESSED
let uncom = SECP256K1_EC_UNCOMPRESSED

let rro = 123443.556456546.rounded()

let compactValue: UInt16 = CFSwapInt16HostToBig(UInt16(2345))

let compactValue2: Int16 = Int16(2345).bigEndian

var decodeData = str.data(using: String.Encoding.utf8)!
print(decodeData.hex)
decodeData.count = 0

print(decodeData.hex)

/////地址
let port: Int32 = 8333
let host: String = "::ffff:7f00:0001"
//    let host: String = "73.243.216.34"
var info: UnsafeMutablePointer<addrinfo>?
// Retrieve the info on our target...
var status: Int32 = getaddrinfo(host, String(port), nil, &info)

// Defer cleanup of our target info...
defer {
    
    if info != nil {
        freeaddrinfo(info)
    }
}
var addressdata = Data()
addressdata.append(info!.pointee.ai_addr)
print("addressdata = \(addressdata.hex)")

let u64 = UInt64(bigEndian: 0x1122334455667788)
let left8 = u64 >> 8
let uin8 = left8 & UInt64(0xff)
let uinn = UInt8(uin8)
