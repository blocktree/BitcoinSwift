//
//  BTCEnv.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/13.
//
//

import Foundation


/// 比特币环境变量
///
/// - main: 生产环境
/// - test: 测试环境
public enum BTCEnv {
    
    case main       //生产环境
    case test       //测试环境
    
    
    /// 私钥地址头字节类型
    var privateKeyVer: UInt8 {
        switch self {
        case .main:
            return 0x80
        case .test:
            return 0xef
        }
    }
    
    /// 公钥地址头字节类型
    var publicKeyVer: UInt8 {
        switch self {
        case .main:
            return 0x00
        case .test:
            return 0x6f
        }
    }
    
    
    /// 公钥的字节长度
    var publicKeyLength: Int {
        return 20
    }
    
    
    /// 私钥的字节长度
    var privateKeyLength: Int {
        return 32
    }
    
    
    /// 比特币签名消息头
    var signedMessageHeader: String {
        return "Bitcoin Signed Message:\n"
    }
    
    
    /// 比特币网络标准端口
    var bitcoinStandardPort: UInt16 {
        switch self {
        case .main:
            return 8333
        case .test:
            return 18333
        }
    }
    
}


/// 环境配置
public struct BTCEnvConfig {
    
    
    /// 网络环境
    static var network = BTCEnv.main
    
    
}
