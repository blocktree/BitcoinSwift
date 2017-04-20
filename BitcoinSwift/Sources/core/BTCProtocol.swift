//
//  BTCProtocolSerialization.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/19.
//
//

import Foundation


/// 比特币协议定义
protocol BTCProtocol {
    
    
    /// 签名
    var signedMessageHeader: String {get}

    
}


// MARK: - 比特币默认协议
extension BTCProtocol {

    var signedMessageHeader: String {
        return "Bitcoin Signed Message:\n"
    }
    
}
