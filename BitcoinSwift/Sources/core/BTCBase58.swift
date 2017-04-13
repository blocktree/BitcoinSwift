//
//  BTCBase58.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/13.
//
//

import Foundation

// MARK: - base58编码解码
class BTCBase58 {
    
    /// base58字母表
    public static var base58chars: [Character] {
        return [
            "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
        ]
    }
    
    
    /// base58编码
    /// 数据为空或全为0位则返回空串
    /// - Parameter data: 数据字节
    /// - Returns: base58编码后的字符串
    public static func encode(with data: Data) -> String {
        
        //空字节返回空串
        if data.isEmpty {
            return ""
        }
        
        var z: Int = 0
        let dbytes = [UInt8](data)
        
        //计算开头连续0字节数
        while z < data.count && dbytes[z] == 0 {
            z += 1
        }
        
        //全部为0，则返回空串
        if z == data.count {
            return ""
        }
        
        // Expected size increase from base58 conversion is approximately 137%
        // use 138% to be safe
        var buf: [UInt8] = [UInt8](repeating: 0, count: (dbytes.count - z) * 138 / 100 + 1)
        
        for i in z...dbytes.count - 1 {
            var carry: UInt32 = UInt32(dbytes[i])
            for j in stride(from: buf.count, to: 0, by: -1) {
                carry += UInt32(buf[j - 1]) << 8    //左移8位，并把低8位相加合并，得到32位
                buf[j - 1] = UInt8(carry % 58)             //约简求余
                carry /= 58
            }
            
            carry = 0   //重置全部0位
        }
        
        var k: Int = 0
        //计算开头连续0字节数
        while k < buf.count && buf[k] == 0 {
            k += 1
        }
        
        //把开头的0位都填充base58字母0位字母
        var s = String([Character](repeating: BTCBase58.base58chars[0], count: z))
        
        //剔除开头的0位，编码字母到输出字串中
        for i in k...buf.count - 1 {
            s.append(BTCBase58.base58chars[Int(buf[i])])
        }
        buf.removeAll()
        return s
    }
    
    
    /// 解码base58格式字符串
    ///
    /// - Parameter string: base58格式字符串
    /// - Returns: 解码后的字节
    public static func decode(with string: String) -> Data? {
    
        //空字节返回空串
        if string.isEmpty {
            return nil
        }
        
        var z: Int = 0
        let characters: [Character] = Array(string.characters)
        
        //计算开头连续0字节数
        while z < string.length && characters[z] == BTCBase58.base58chars[0] {
            z += 1
        }
        
        // log(58)/log(256), rounded up
        var buf: [UInt8] = [UInt8](repeating: 0, count: (string.length - z) * 733 / 1000 + 1)
        
        for i in z...characters.count - 1 {
            guard let cindex = BTCBase58.base58chars.index(of: characters[i]) else {
                return nil  //字母表找不，不是base58编码
            }
            
            var carry: UInt32 = UInt32(cindex)
            
            for j in stride(from: buf.count, to: 0, by: -1) {
                carry = carry + UInt32(buf[j - 1]) * 58
                buf[j - 1] = UInt8(carry & 0xff)
                carry >>= 8
            }
            
            carry = 0
        }
  
        var k: Int = 0
        //计算开头连续0字节数
        while k < buf.count && buf[k] == 0 {
            k += 1
        }
        
        var d = Data()
        d.append(contentsOf: [UInt8](repeating: 0, count: z))
        d.append(contentsOf: buf)
        buf.removeAll()
        return d
    }
    
}
