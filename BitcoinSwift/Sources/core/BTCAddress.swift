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
    var data: Data {set get}
    
    /// base58字符
    var string: String {get}
    
    /// 环境
    var network: BTCEnv {get}
    
    /// 通过地址转为地址对象
    ///
    /// - Parameter string:
    func address(string: String)
    
    /// 通过字节编码地址
    ///
    /// - Parameter data: 字节
    func address(data: Data)
    
    
    /// 清空数据
    func clear()
    
    
}

extension BTCAddress {
    
    func address(string: String) {
        
    }
}

public struct BTCPublickeyAddress: BTCAddress {
    
    
    public var network: BTCEnv {
        return BTCEnvConfig.network
    }
    
    
    /// 公钥地址长度
    public var length: Int {
        return 20
    }

    /// 地址版本前缀，正式0x00，测试0x6f
    public var versionPrefix: UInt8 {
        return self.network == .main ? 0x00 : 0x6f
    }

    public var string: String {
        return ""
    }
    
    public var data: Data = Data()
    
    init(string: String) {
        self.address(string: string)
        
    }
    
    init(data: Data) {
        self.address(data: data)
        self.data = data
    }
    
    public func address(string: String) {
        
    }
    
    public func address(data: Data) {
        
    }
    
    public func clear() {
        
    }
}


//public struct BTCPrivateKeyAddress: BTCAddress {
//    
//    
//    /// 公钥
//    var publicKey: BTCPublickeyAddress {get}
//    
//}
//
//public struct BTCScriptHashAddress: BTCAddress {
//    
//}
