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
    
    var privateKeyVer: UInt8 {
        switch self {
        case .main:
            return 128
        case .test:
            return 239
        }
    }
}

public struct BTCEnvConfig {
    
    static var network = BTCEnv.main
    
}
