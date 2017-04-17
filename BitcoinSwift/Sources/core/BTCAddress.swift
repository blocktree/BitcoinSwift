//
//  BTCAddress.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/13.
//
//

import Foundation


/// 地址协议
public protocol BTCAddress {
    
    
    /// 地址类型前序
    var versionPrefix: UInt8 {get}
    
    /// 地址负载长度
    var length: Int {get}
    
    /// 地址负载字节
    var data: Data? {set get}
    
    /// base58字符
    var string: String {get}
    
    /// 环境
    var network: BTCEnv {get}
    
    /// 通过地址转为地址对象
    ///
    /// - Parameter string:
    mutating func address(string: String)
    
    /// 通过字节编码地址
    ///
    /// - Parameter data: 字节
    mutating func address(data: Data)
    
    
    /// 清空数据
    mutating func clear()
    
    
}


// MARK: - 扩展实现默认方法
extension BTCAddress {
    
    
    /// 网络环境
    public var network: BTCEnv {
        return BTCEnvConfig.network
    }
    
    /// 输出base58编码格式地址
    public var string: String {
        guard let payload = self.data else {
            return ""
        }
        
        var data = Data()
        data.append(self.versionPrefix)     //添加地址类型
        data.append(payload)              //添加数据负载
        data.addChecksum()                  //添加完整性校验
        let base58 = data.base58
        data.removeAll()                    //清除以防内存溢出
        
        return base58
    }
    
    
    /// 地址base58编码格式初始化对象
    ///
    /// - Parameter string: base58编码格式地址
    public mutating func address(string: String) {
        
        guard let base58data = string.base58 else {
            self.clear()
            return
        }
        
        let bytes = base58data.u8
        let checksumLen = 4
        
        //检查最少长度
        if bytes.count < checksumLen {
            self.clear()
            return
        }
        
        //检查地址类型是否符合
        let version = bytes[0]
        if version != self.versionPrefix {
            self.clear()
            return
        }
        
        
        let payload = Array(bytes.prefix(bytes.count - 4))
        let checksum = Array(bytes.suffix(4))
        
        //检查地址是否符合规范的长度，version占1字节
        if payload.count != self.length + 1 {
            self.clear()
            return
        }
        
        //检查地址完整性
        let payloadhash4bytes = Array(payload.sha256().sha256().prefix(4))
        if checksum != payloadhash4bytes {
            self.clear()
            return
        }
        
        self.data = Data(bytes: payload.suffix(from: 1))
    }
    
    
    /// 字节数据生产地址
    ///
    /// - Parameter data: 只需要负载数据，不带version，check
    public mutating func address(data: Data) {
        self.data = data
    }

    
    /// 清除数据
    public mutating func clear() {
        self.data = nil
    }
}


/// 公钥地址
public struct BTCPublickeyAddress: BTCAddress {
    
    /// 公钥地址长度
    public var length: Int {
        return 20
    }

    /// 地址版本前缀，正式0x00，测试0x6f
    public var versionPrefix: UInt8 {
        return self.network == .main ? 0x00 : 0x6f
    }

    public var data: Data?
    
    /// 使用base58编码格式初始化地址
    init(string: String) throws {
        self.address(string: string)
        if self.data == nil {
            throw BTCError.initError("data is nil")
        }
        
    }
    
    /// 使用字节流初始化地址
    init(data: Data) throws {
        
        if data.isEmpty {
            throw BTCError.initError("data is nil")
        }
        self.address(data: data)
    }
    
}


public struct BTCPrivateKeyAddress: BTCAddress {
    
    
    /// 公钥压缩，比特币公钥支持压缩
    public var compressed: Bool =  false
    
    public var network: BTCEnv {
        return BTCEnvConfig.network
    }
    
    
    /// 公钥地址长度
    public var length: Int {
        return 32
    }
    
    /// 地址版本前缀，正式0x00，测试0x6f
    public var versionPrefix: UInt8 {
        return self.network == .main ? 0x80 : 0xef
    }
    
    public var data: Data?
    
    /// 使用base58编码格式初始化地址
    init(string: String) throws {
        self.address(string: string)
        if self.data == nil {
            throw BTCError.initError("data is nil")
        }
        
        //如果负载数据长度被标准长2字节，就是压缩格式(前序类型占1字节，后续压缩占1字节)
        if self.data?.count == self.length + 2 {
            self.compressed = true      //记录为压缩类型
            self.data?.removeLast()     //丢弃最后压缩字节
        }
        
    }
    
    /// 使用字节流初始化地址
    init(data: Data, compressed: Bool = false) throws {
        
        if data.isEmpty {
            throw BTCError.initError("data is nil")
        }
        
        self.address(data: data)
        
        self.compressed = compressed
    }
    
}
//
//public struct BTCScriptHashAddress: BTCAddress {
//    
//}
