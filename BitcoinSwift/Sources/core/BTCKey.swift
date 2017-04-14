//
//  BTCKey.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/8.
//
//

import Foundation
import Libsecp256k1

public class BTCKey {
    
    //MARK: - 成员变量
    
    /// 私钥字节长度
    public static let privateKeyLength = 32
    
    /// 公钥字节长度（压缩）
    public static let compressedPublicKeyLength = 33
    
    /// 公钥字节长度（未压缩）
    public static let uncompressedPublicKeyLength = 65
    
    
    /// 是否压缩公钥
    public var publicKeyCompressed: Bool = false
    
    
    /// 公钥的实际长度
    public var publicKeyLength: Int {
        if self.publicKeyCompressed {
            return BTCKey.compressedPublicKeyLength
        } else {
            return BTCKey.uncompressedPublicKeyLength
        }
    }
    
    
    ///WIF格式编码私钥（钱包导入格式——WIF，Wallet Import Format），如果key不是私钥则返回空串
    public var wif: String {
        guard let key = self.seckey else {
            return ""
        }
        
        var d = Data(capacity: 34)
        let version: UInt8 = 128
        d.append(version)
        d.append(key)
        if self.publicKeyCompressed {
            d.append(0x01)
        }
        
        let checksum = d.sha256().sha256()
        d.append(checksum.bytes, count: 4)
        
        
        return d.base58
    }
    
    
    
    /// 私钥字节
    public var privateKey: Data? {
        return self.seckey
    }
    
    /// 公钥字节
    public var publicKey: Data? {
        
        guard let pubkeyData = self.pubkey else {
            //如果没有公钥数据，尝试使用私钥导出一个
            guard let privateKeyData = self.seckey else {
                //没有私钥数据
                return nil
            }
            
            /********** 生成公钥 **********/
            
            //公钥长度根据是否压缩确定
            var len = self.publicKeyLength
            //输出目标，len个字节长度
            var data = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
            //secp256k1公钥，1个指针变量
            var pk = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
            
            //记得释放内存
            defer {
                pk.deinitialize(count: 1)
                pk.deallocate(capacity: 1)
                
                data.deinitialize(count: len)
                data.deallocate(capacity: len)
            }
            
            
            //创建公钥，结果1就代表成功
            guard secp256k1_ec_pubkey_create(self.ctx, pk, privateKeyData.bytes) > 0 else {
                return nil
            }
            
            
            //print(pk.pointee.data)
            
            let secp256k1_ec_compressed = self.publicKeyCompressed ? (SECP256K1_FLAGS_TYPE_COMPRESSION | SECP256K1_FLAGS_BIT_COMPRESSION) : SECP256K1_FLAGS_TYPE_COMPRESSION
            
            //导出公钥字节压缩，结果1就代表成功
            guard secp256k1_ec_pubkey_serialize(self.ctx, data, &len, pk, UInt32(secp256k1_ec_compressed)) > 0 else {
                return nil
            }
            
            //检查长度是否符合
            guard self.publicKeyLength == len else {
                return nil
            }
            
            //print("len = \(len)")
            
            self.pubkey = Data(bytes: data, count: len)
            
            return self.pubkey
        }
        
        return pubkeyData
        
    }
    
    //MARK: - 私有变量
    
    
    /// 私钥数据
    fileprivate var seckey: Data?
    
    /// 公钥
    fileprivate var pubkey: Data? {
        didSet {
            //同时设置是否压缩
            if pubkey?.count == BTCKey.compressedPublicKeyLength {
                self.publicKeyCompressed = true
            } else {
                self.publicKeyCompressed = false
            }
        }
    }
    
    
    /// 加密工具上下文指针，一个可以签名和验证的指针对象
    fileprivate var ctx: OpaquePointer = {
       let _ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))
        return _ctx!
    }()
    
    deinit {
        self.seckey = nil   //释放私钥
    }
    
    //MARK: - 初始化方法
    
    
    public convenience init?() {
        //随机创建256位私钥，则长度32字节
        let buffer = Data.randomBytes(BTCKey.privateKeyLength)
        self.init(privateKey: buffer)
    }
    
    
    /// 使用私钥初始化对象
    /// 私钥初始的对象拥有所有功能，签名，校验，生产公钥等等
    /// - Parameter privateKey: 私钥字节
    public init?(privateKey: Data) {
        guard self.setPrivateKey(key: privateKey) else {
            return nil
        }
    }
    
    /// 使用公钥初始化对象
    /// 只具备公钥功能，不能签名
    /// - Parameter privateKey: 私钥字节
    public init?(publicKey: Data) {
        guard self.setPublicKey(key: publicKey) else {
            return nil
        }
    }
    
    
    //MARK: - 私有方法
    
    
    /// 设置私钥
    ///
    /// - Parameter key: 私钥 32字节
    /// - Returns: 是否设置成功
    fileprivate func setPrivateKey(key: Data) -> Bool {
        //检查私钥字节是否符合256位
        guard secp256k1_ec_seckey_verify(self.ctx, key.bytes) > 0 else {
            return false
        }
        self.seckey = key
        return true
    }
    
    
    /// 设置公钥
    ///
    /// - Parameter key: 公钥 分 压缩和未压缩两类
    /// - Returns: 是否设置成功
    fileprivate func setPublicKey(key: Data) -> Bool {
        //检查公钥是否符合规范
        guard key.count == BTCKey.compressedPublicKeyLength ||
            key.count == BTCKey.uncompressedPublicKeyLength else {
            return false
        }
        
        let pk = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
        
        //记得释放内存
        defer {
            pk.deinitialize(count: 1)
            pk.deallocate(capacity: 1)
        }
        
        
        /// 使用secp256k1校验公钥，成功pk会得到复制
        let flag = secp256k1_ec_pubkey_parse(self.ctx, pk, key.bytes, key.count)
        
        if flag > 0 {
            
            self.pubkey = key
            
            return true
        } else {
            return false
        }
    }
    
}


// MARK: - 公开方法
extension BTCKey {
    
    
    /// 清除内存，针对Secp256k1库使用的内存
    public func clear() {
        
    }
    
}
