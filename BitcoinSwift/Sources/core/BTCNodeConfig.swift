//
//  BTCEnv.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/13.
//
//

import Foundation

/// 节点环境配置
public struct BTCNodeConfig: BTCProtocol {
    
    
    /// 全局单例
    static let shared: BTCNodeConfig = {
        return BTCNodeConfig()
    }()
    
    /// 网络环境
    public var network = BTCNetwork.main
    
    /// 网络版本号
    public var protocolVersion: UInt32 = 70013
    
    /// 提供的节点服务能力
    public var enableServices: UInt64 = 0

    /// 消息标识符
    public var signedMessageHeader: String {
        return "Bitcoin Signed Message:\n"
    }
    
}



