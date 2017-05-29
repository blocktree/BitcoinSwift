//
//  BTCProtocolSerialization.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/19.
//
//

import Foundation


/// 比特币协议定义
public protocol BTCProtocol {
    
    /// 网络环境
    var network: BTCNetwork {set get}
    
    /// 网络版本号
    var protocolVersion: UInt32 {set get}
    
    /// 提供的节点服务能力
    var enableServices: UInt64 {set get}
    
    /// 签名
    var signedMessageHeader: String {get}
    
}


// MARK: - 比特币默认协议
public extension BTCProtocol {

    var signedMessageHeader: String {
        return "Bitcoin Signed Message:\n"
    }
    
}



/// 比特币环境变量
///
/// - main: 生产环境
/// - test: 测试环境
public enum BTCNetwork {
    
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
    var standardPort: UInt16 {
        switch self {
        case .main:
            return 8333
        case .test:
            return 18333
        }
    }
    
    
    /// 用于识别消息的来源网络，当流状态位置时，它还用于寻找下一条消息
    var magic: UInt32 {
        
        var value: UInt32 = 0
        switch self {
        case .main:
            value = 0xf9beb4d9
        case .test:
            value = 0xfabfb5da
        }
        
        //绝大多数整数都都使用little endian编码，只有IP地址或端口号使用big endian编码。
        //先判断系统是否littleEndian，如果是则要把字节序翻转初始一个新值
        if Int.isLittleEndian {
            return UInt32(value.byteSwapped)
        } else {
            return value
        }
    }
    
}

/// 比特币节点服务类型
///
/// - node_network: 全节点
/// - node_getutxo: 未花节点
/// - node_bloom: SPV节点
public enum BTCNodeServices: UInt64 {
    
    case node_network = 1        //bit:1,This node can be asked for full blocks instead of just headers.
    case node_getutxo = 2        //bit:10,See BIP 0064,https://github.com/bitcoin/bips/blob/master/bip-0064.mediawiki
    case node_bloom = 4          //bit:100,See BIP 0111,https://github.com/bitcoin/bips/blob/master/bip-0111.mediawiki
    
}
