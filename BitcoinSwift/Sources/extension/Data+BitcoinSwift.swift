//
//  Data+BitcoinSwift.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/11.
//
//

#if os(Linux) || os(Android) || os(FreeBSD)
    import Glibc
#else
    import Darwin
#endif
import Foundation


// MARK: - 扩展Data用于处理bitcoin
public extension Data {
    
    
    /// 转为Hex，已经在CryptoSwift实现了
    public var hex: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    
    /// 翻转hex
    public var reversedBytes: Data {
        return Data(self.reversed())
    }
    
    
    /// 转为8位数组指针，字节数组，已经在CryptoSwift实现了bytes
    public var u8: Array<UInt8> {
        return Array(self)
    }
    
    
    /// 字节base58编码
    public var base58: String {
        if self.isEmpty {
            return ""
        }
        
        return BTCBase58.encode(with: self)
    }
    
    
    /// 添加完整性校验
    ///
    /// - Parameter length: 用于校验完整性的长度，默认4字节
    public mutating func addChecksum(length: Int = 4) {
        if self.isEmpty {
            return
        }
        
        //添加4字节hash数据到最后位，用于校验地址完整性
        let checksum = self.sha256().sha256()   //两次hash256
        self.append(checksum.bytes, count: 4)

    }
    
    
    /// RIPEMD160哈希
    ///
    /// - Returns: 哈希后的摘要数据
    public func ripemd160() -> Data {
        return RIPEMD.digest(self)
    }
 
    /*
     添加比特币协议的变长整数
     Variable length integer (变长整数)
     整数可以根据表达的值进行编码以节省空间。变长整数总是在可变长度数据类型的数组/向量之前出现。
     
     值          存储长度          格式
     < 0xfd         1               uint8_t
     <= 0xffff      3               0xfd + uint16_t
     <= 0xffffffff	5               0xfe + uint32_t
     -              9               0xff + uint64_t
     
     */
    public mutating func appendVarInt(value: Int) {
        //数值必须为正整数
        if value < 0 {
            return
        }
        
        if value < 0xfd {
            self.append(UInt8(value))
        } else if value <= 0xffff {
            self.append(0xfd)
            var compactValue: UInt16 = CFSwapInt16HostToLittle(UInt16(value))
            let compactData = Data(bytes: &compactValue, count: MemoryLayout<UInt16>.stride)
            self.append(compactData)
        } else if value <= 0xffffffff {
            self.append(0xfe)
            var compactValue: UInt32 = CFSwapInt32HostToLittle(UInt32(value))
            let compactData = Data(bytes: &compactValue, count: MemoryLayout<UInt32>.stride)
            self.append(compactData)
        } else {
            self.append(0xff)
            var compactValue: UInt64 = CFSwapInt64HostToLittle(UInt64(value))
            let compactData = Data(bytes: &compactValue, count: MemoryLayout<UInt64>.stride)
            self.append(compactData)
        }
        
    }
    
    
    /// 添加可变字符串
    ///
    //    Variable length string (变长字符串)
    //    一个变长整数后接字符串构成变长字符串。
    //    
    //    字段尺寸	描述         数据类型         说明
    //    ?         length      var_int         字符串长度
    //    ?         string      char[]          字符串本身(可为空)
    //
    /// - Parameter value:
    public mutating func appendVarString(value: String) {
        
        let strData = value.data(using: String.Encoding.utf8) ?? Data()
        self.appendVarInt(value: strData.count)
        self.append(strData)

    }
}


// MARK: - 全局方法
public extension Data {
    
    /// 指针变量转为swift数组结构
    ///
    /// - Parameters:
    ///   - length: 指针字节长度
    ///   - data: 指针对象
    ///   - _: 需要转成的swift类
    /// - Returns: 返回一个转换后的新数组
    public static func convert<T>(length: Int, data: UnsafePointer<UInt8>, _: T.Type) -> [T] {
        let numItems = length/MemoryLayout<T>.stride
        let buffer = data.withMemoryRebound(to: T.self, capacity: numItems) {
            UnsafeBufferPointer(start: $0, count: numItems)
        }
        return Array(buffer)
    }
    
    
    /// 随机固定长度字节
    ///
    /// - Parameter blockSize: 长度
    /// - Returns: 字节
    public static func randomBytes(_ blockSize: Int) -> Data {
        var randomIV: Array<UInt8> = Array<UInt8>()
        randomIV.reserveCapacity(blockSize)
        for randomByte in RandomBytesSequence(size: blockSize) {
            randomIV.append(randomByte)
        }
        return Data(bytes: randomIV)
    }
    
}
