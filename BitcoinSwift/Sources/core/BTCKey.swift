//
//  BTCKey.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/8.
//
//

import Foundation
import Libsecp256k1

enum MultiSigError: Error {
    case decodeError
    case encodeError
}

public class BTCKey {
    
    //MARK: - 成员变量
    
    
    /// 是否压缩公钥
    public var publicKeyCompressed: Bool = true
    
    
    ///WIF格式编码私钥（钱包导入格式——WIF，Wallet Import Format），如果key不是私钥则返回空串
    public var wif: String {
        return ""
    }
    
    
    
    /// 私钥字节
    public var privateKey: Data? {
        return self.seckey
    }
    
    //MARK: - 私有变量
    
    
    /// 私钥数据
    fileprivate var seckey: Data?
    
    
    /// 加密工具上下文指针，一个可以签名和验证的指针对象
    fileprivate var ctx: OpaquePointer = {
       let _ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))
        return _ctx!
    }()
    
    //MARK: - 初始化方法
    
    
    public convenience init() throws {
        //随机创建256位私钥，则长度32字节
        let buffer = Data.randomBytes(32)
        print(buffer)
        try self.init(privateKey: buffer)
    }
    
    
    /// 初始化私钥
    ///
    /// - Parameter privateKey: 私钥字节
    public init(privateKey: Data) throws {
        guard self.setPrivateKey(key: privateKey) else {
            throw BitcoinSwiftError.initError
        }
    }
    
    
    //MARK: - 私有方法
    
    
    fileprivate func setPrivateKey(key: Data) -> Bool {
        //检查私钥字节是否符合256位
        guard secp256k1_ec_seckey_verify(self.ctx, key.u8) > 0 else {
            return false
        }
        self.seckey = key
        return true
    }
    
}


// MARK: - 公开方法
extension BTCKey {
    
    /// 公钥字节
    public func publicKey(compressed: Bool = true) -> Data {
        return Data()
    }
    
    
    /// 清除内存，针对Secp256k1库使用的内存
    public func clear() {
        
    }
    
}
