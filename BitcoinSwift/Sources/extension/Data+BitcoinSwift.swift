//
//  Data+BitcoinSwift.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/11.
//
//

import Foundation


// MARK: - 扩展Data用于处理bitcoin
public extension Data {
    
    
    /// 转为Hex
    public var hex: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    
    /// 翻转hex
    public var reversedBytes: Data {
        return Data(self.reversed())
    }
    
    
    /// 转为8位数组指针，字节数组
    public var u8: [UInt8] {
        let array = [UInt8](self)
        return array
    }
    
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
