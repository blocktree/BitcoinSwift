//
//  UInt+BitcoinSwift.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/5/2.
//
//

import Foundation


// MARK: - 扩展Int方法
public extension Int {
    
    /// 系统的整数型是否使用little-endian方式编码
    /// swift默认使用littlt-endian字节序
    public static var isLittleEndian: Bool {
        return Int(littleEndian: 42) == 42
    }
    
}

/// 128位无符号整型大数
/// 通过UInt8,UInt16,UInt32,UInt64等数组创建
/// 使用big-endian字节序存储
public struct UInt128 {
    
    
    /// UInt128的字节数
    public static var bytesSize: Int {
        return 16       //bytes
    }
    
    
    /// UInt128的位数
    public static var bitsSize: Int {
        return 128       //bytes
    }
    
    //最终数值以字节组保存
    public var bytes: [UInt8] = [UInt8](repeating: 0, count: UInt128.bytesSize)    //默认以0填充
    
    
    /// 初始对象
    /// values是一个以big-endian编码的数组
    /// - Parameter values: 通过UInt8,UInt16,UInt32,UInt64等数组创建
    public init<T: UnsignedInteger & Comparable & Equatable>(_ values: [T]) {
        self.saveBytes(values)
    }
    
    
    /// 保存数值为字节组
    ///
    /// - Parameter values:
    fileprivate mutating func saveBytes<T: UnsignedInteger & Comparable & Equatable>(_ values: [T]) {
        /// 类型元素的空间长度
        let elementSize = MemoryLayout<T>.size
        for i in 0 ..< Swift.min(values.count, self.bytes.count / elementSize) {   //防止数组溢出
            for n in 0 ..< elementSize {
                var shift = 0
                if Int.isLittleEndian {
                    shift = 8 * n    //以little-endian，计算移位数
                } else {
                    shift = 8 * (elementSize - 1 - n)    //以big-endian，计算移位数
                }
                //采用big-endian数序记录
                var shiftValue = numericCast(values[i]) >> UIntMax(shift)       //通过右移读取每个字节值
                shiftValue = shiftValue & 0xff      //截断取最后1个字节记录到数组中
                self.bytes[i * elementSize + n] = UInt8(shiftValue)
            }
        }
    }
    
    /// 转UInt8类型数组
    public var u8: [UInt8] {
        return self.bytes
    }
    
    /// 转UInt16类型数组
    public var u16: [UInt16] {
        let m = MemoryLayout<UInt16>.size
        let count = UInt128.bytesSize / m
        var result = [UInt16](repeating: 0, count: count)
        for i in 0 ..< count {
            //根据字节长度合并为值
            var nv: UInt16 = 0
            for j in 0 ..< m {
                let byte = UInt16(self.bytes[i * m + j])
                var shift: UInt16 = 0
                if Int.isLittleEndian {
                    shift = UInt16(8 * j)    //以little-endian，计算移位数
                } else {
                    shift = UInt16(8 * (m - 1 - j))    //以big-endian，计算移位数
                }
                nv = nv | (byte << shift)       //合并字节
            }
            result[i] = nv
        }
        return result
    }
    
    /// 转UInt32类型数组
    public var u32: [UInt32] {
        let m = MemoryLayout<UInt32>.size
        let count = UInt128.bytesSize / m
        var result = [UInt32](repeating: 0, count: count)
        for i in 0 ..< count {
            //根据字节长度合并为值
            var nv: UInt32 = 0
            for j in 0 ..< m {
                let byte = UInt32(self.bytes[i * m + j])
                var shift: UInt32 = 0
                if Int.isLittleEndian {
                    shift = UInt32(8 * j)    //以little-endian，计算移位数
                } else {
                    shift = UInt32(8 * (m - 1 - j))    //以big-endian，计算移位数
                }
                nv = nv | (byte << shift)       //合并字节
            }
            result[i] = nv
        }
        return result
    }
    
    /// 转UInt64类型数组
    public var u64: [UInt64] {
        let m = MemoryLayout<UInt64>.size
        let count = UInt128.bytesSize / m
        var result = [UInt64](repeating: 0, count: count)
        for i in 0 ..< count {
            //根据字节长度合并为值
            var nv: UInt64 = 0
            for j in 0 ..< m {
                let byte = UInt64(self.bytes[i * m + j])
                var shift: UInt64 = 0
                if Int.isLittleEndian {
                    shift = UInt64(8 * j)    //以little-endian，计算移位数
                } else {
                    shift = UInt64(8 * (m - 1 - j))    //以big-endian，计算移位数
                }
                nv = nv | (byte << shift)       //合并字节
            }
            result[i] = nv
        }
        return result
    }
    
}


