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

/// 字节编码顺序
///
/// - littleEndian: 小端
/// - bigEndian: 大端
public enum Endianness {
    case littleEndian, bigEndian
}

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
    
    /// 转为16位数组指针
    public var u16: Array<UInt16> {
        let values = Data.convert(length: self.count, data: self.u8, UInt16.self)
        return values
    }
    
    /// 转为32位数组指针
    public var u32: Array<UInt32> {
        let values = Data.convert(length: self.count, data: self.u8, UInt32.self)
        return values
    }
    
    /// 转为64位数组指针
    public var u64: Array<UInt64> {
        let values = Data.convert(length: self.count, data: self.u8, UInt64.self)
        return values
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
    
    /// 把类型对象以字节编码初始化一个字节结构体
    public init<T>(_ value: T,
                     length totalBytes: Int = MemoryLayout<T>.size,
                     endianness: Endianness = .littleEndian) {
        self = Data()
        self.append(value, length: totalBytes, endianness: endianness)
    }
    
    /// 把类型对象以字节编码到字节组中最后位置
    ///
    /// var data = Data()
    /// let value: UInt32 = 12346                               //16进制值 0x303a
    /// data.append(value)                                      //小端编码  3a300000
    /// data.append(value, endianness: .bigEndian)              //大端编码  0000303a
    ///
    /// - Parameters:
    ///   - value: 类型值
    ///   - totalBytes: 编码字节长度，默认类型长度
    ///   - endianness: 编码字节序，默认小端
    public mutating func append<T>(
        _ value: T,
        length totalBytes: Int = MemoryLayout<T>.size,
        endianness: Endianness = .littleEndian) {
        
        //开1个可变指针
        let valuePointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
        valuePointer.pointee = value
        
        //记得释放指针
        defer {
            valuePointer.deinitialize()
            valuePointer.deallocate(capacity: 1)
        }
        
        //返回编码后的字节组序
        let bytes = valuePointer.withMemoryRebound(to: UInt8.self, capacity: totalBytes) {
            ptr -> Array<UInt8> in
            
            //输出结果
            var bytes = Array<UInt8>(repeating: 0, count: totalBytes)
            //自定义长度和类型长度，取最小值作为数组长度
            for j in 0 ..< Swift.min(MemoryLayout<T>.size, totalBytes) {
                switch endianness {
                case .littleEndian:         //小端编码，内存顺序为：低位值 -> 高位值
                    bytes[j] = (ptr + j).pointee
                case .bigEndian:            //大端编码，内存顺序为：高位值 -> 低位值
                    bytes[totalBytes - 1 - j] = (ptr + j).pointee
                }
            }
            return bytes
        }
        
        //字节组结果添加到Data
        self.append(contentsOf: bytes)
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
            var compactValue: UInt16 = UInt16(value).littleEndian
            let compactData = Data(bytes: &compactValue, count: MemoryLayout<UInt16>.size)
            self.append(compactData)
        } else if value <= 0xffffffff {
            self.append(0xfe)
            var compactValue: UInt32 = UInt32(value).littleEndian
            let compactData = Data(bytes: &compactValue, count: MemoryLayout<UInt32>.size)
            self.append(compactData)
        } else {
            self.append(0xff)
            var compactValue: UInt64 = UInt64(value).littleEndian
            let compactData = Data(bytes: &compactValue, count: MemoryLayout<UInt64>.size)
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
    
    
    
    /// 在字节流中读取某个指针某个位置若干个字节绑定到类型上
    ///
    /// - Parameters:
    ///   - offset: 指针起始位
    ///   - count: 读取类型的数量
    ///   - _: 类型
    /// - Returns: 转换后的类型数组
    public func get<T>(at offset: Int, count: Int = 1, _: T.Type) -> [T]? {
        
        guard offset < self.count else {
            return nil
        }
        
        let length = MemoryLayout<T>.size * count
        let ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
        //记得释放内存
        defer {
            ptr.deinitialize(count: length)
            ptr.deallocate(capacity: length)
        }
        
        let start = self.advanced(by: offset)
        
        guard length <= start.count else {
            return nil
        }
        start.copyBytes(to: ptr, count: length)
        let result = Data.convert(length: length, data: ptr, T.self)
        return result
    }
    
    /// 读取字节流中特定位置的UInt8值
    ///
    /// - Parameter offset: 特定位置
    /// - Returns: 数据类型值
    public func getUInt8(at offset: Int) -> UInt8 {
        guard let value = self.get(at: offset, UInt8.self) else {
            return 0
        }
        return value[0]
    }
    
    /// 读取字节流中特定位置的UInt16值
    ///
    /// - Parameter offset: 特定位置
    /// - Returns: 数据类型值
    public func getUInt16(at offset: Int) -> UInt16 {
        guard let value = self.get(at: offset, UInt16.self) else {
            return 0
        }
        return value[0]
    }
    
    
    /// 读取字节流中特定位置的UInt32值
    ///
    /// - Parameter offset: 特定位置
    /// - Returns: 数据类型值
    public func getUInt32(at offset: Int) -> UInt32 {
        guard let value = self.get(at: offset, UInt32.self) else {
            return 0
        }
        return value[0]
    }
    
    /// 读取字节流中特定位置的UInt64值
    ///
    /// - Parameter offset: 特定位置
    /// - Returns: 数据类型值
    public func getUInt64(at offset: Int) -> UInt64 {
        guard let value = self.get(at: offset, UInt64.self) else {
            return 0
        }
        return value[0]
    }
    
    /// 读取字节流中特定位置的String值
    /// 已特定位置开始读取连续的字节组，直到0x00截断，把字节组根据ASCII码表转换为String
    /// - Parameter offset: 特定位置
    /// - Returns: 数据类型值
    public func getString(at offset: Int) -> String {
        let value = String(cString: Array(self.u8.suffix(from: offset)))
        return value
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
