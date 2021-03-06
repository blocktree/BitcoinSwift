//
//  String+BitcoinSwift.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/12.
//
//

#if os(Linux) || os(Android) || os(FreeBSD)
    import Glibc
#else
    import Darwin
#endif
import Foundation


extension String {
    
    /// 字符串长度
    var length: Int {
        return self.characters.count;
    }
    
    
    /// 16进制的字节
    var hexData: Data? {
        
        //排除单数字节序列
        if self.length % 2 > 0 {
            return nil
        }
        
        var d = Data(capacity: self.length / 2)
        
        var b: UInt8 = 0
        for (i, c) in self.characters.enumerated() {
            switch c {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                b = b + UInt8(c.toInt() - Character("0").toInt())
            case "A", "B", "C", "D", "E", "F":
                b = b + UInt8(c.toInt() + 10 - Character("A").toInt())
            case "a", "b", "c", "d", "e", "f":
                b = b + UInt8(c.toInt() + 10 - Character("a").toInt())
            default:
                //无法解析的字母，超过16进制，结束
                return nil
            }
            
            
            if i % 2 > 0 {
                d.append(b)
                b = 0
            } else {
                b *= 16
            }
            
        }
        
        return d
    }
    
    
    /// base58的编码数据
    public var base58: Data? {
        if self.isEmpty {
            return nil
        }
        
        return BTCBase58.decode(with: self)
    }
    
    /// RIPEMD160哈希
    ///
    /// - Returns: 哈希后的摘要数据
    public func ripemd160() -> String {
        let data = Data(bytes: self.utf8.lazy.map({ $0 as UInt8 }))
        return RIPEMD.digest(data).hex
    }
    
    
    /// 格式化为比特币消息认证格式
    ///
    /// - Returns: 以 "Bitcoin Signed Message:\n" 协议开头的变长字节结构
    public func formatMessageForBitcoinSigning() -> Data {
        var data = Data()
        data.appendVarString(value: BTCNodeConfig.shared.network.signedMessageHeader)
        data.appendVarString(value: self)
        return data
    }
    
    
    
}


// MARK: - 字母类扩展
public extension Character {

    
    /// 字母转为Unicode的数值
    ///
    /// - Returns: Unicode的数值
    public func toInt() -> Int {
        var intFromCharacter:Int = 0
        for scalar in String(self).unicodeScalars {
            intFromCharacter = Int(scalar.value)
        }
        return intFromCharacter
    }
}
