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
    
    
    /// 公钥字节
    public var publicKey: Data = Data() {
        didSet {
            //同时设置是否压缩
            if self.publicKey.count == BTCKey.compressedPublicKeyLength {
                self.publicKeyCompressed = true
            } else {
                self.publicKeyCompressed = false
            }
        }
    }
    
    //MARK: - 私有变量
    
    
    /// 私钥数据
    fileprivate var seckey: Data?
    
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
    public init?(privateKey: Data, compressed: Bool = false) {
        guard self.setPrivateKey(key: privateKey) else {
            return nil
        }
        self.publicKeyCompressed = compressed
        guard self.generatePublickey(privateKeyData: privateKey) else {
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
    
    /// 使用消息签名和消息（hash）还原公钥
    public init?(compactSig: Data, message: String) {
        
        let msghash = message.formatMessageForBitcoinSigning().sha256().sha256()
        
        guard compactSig.count == 65 else {
            return nil
        }
        
        //头字节计算 - 27 大于 4 代表为压缩公钥
        self.publicKeyCompressed = compactSig.bytes[0] - 27 >= 4 ? true : false
        
        var len = self.publicKeyLength
        var recid: Int32 = Int32((compactSig.bytes[0] - 27) % 4)
        
        //输出目标，len个字节长度
        var pubkey = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        var pk = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
        var s = UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>.allocate(capacity: 1)
        
        //记得释放内存
        defer {
            pk.deinitialize(count: 1)
            pk.deallocate(capacity: 1)
            
            s.deinitialize(count: 1)
            s.deallocate(capacity: 1)
            
            pubkey.deinitialize(count: len)
            pubkey.deallocate(capacity: len)
        }
        
        let secp256k1_ec_compressed = self.publicKeyCompressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED
        
        //解码出签名结构体，compactSig向前移一位，跳过recid字节
        guard secp256k1_ecdsa_recoverable_signature_parse_compact(self.ctx, s, compactSig.advanced(by: 1).u8, recid) > 0 else {
            return nil
        }
        
        //通过消息签名和消息原文双hash恢复公钥结构
        guard secp256k1_ecdsa_recover(self.ctx, pk, s, msghash.u8) > 0 else {
            return nil
        }
        //print("pk = \(pk.pointee.data)")
        //编码公钥
        guard secp256k1_ec_pubkey_serialize(self.ctx, pubkey, &len, pk, UInt32(secp256k1_ec_compressed)) > 0 else {
            return nil
        }
        
        self.publicKey = Data(bytes: pubkey, count: len)
        
    }
    
    
    //MARK: - 私有方法
    
    
    /// 设置私钥
    ///
    /// - Parameter key: 私钥 32字节
    /// - Returns: 是否设置成功
    fileprivate func setPrivateKey(key: Data) -> Bool {
        //检查私钥字节是否符合256位
        guard secp256k1_ec_seckey_verify(self.ctx, key.u8) > 0 else {
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
        let flag = secp256k1_ec_pubkey_parse(self.ctx, pk, key.u8, key.count)
        
        if flag > 0 {
            
            self.publicKey = key
            
            return true
        } else {
            return false
        }
    }
    
    
    /// 生成公钥
    ///
    /// - Parameter privateKeyData: 私钥数据
    fileprivate func generatePublickey(privateKeyData: Data) -> Bool {
        
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
        guard secp256k1_ec_pubkey_create(self.ctx, pk, privateKeyData.u8) > 0 else {
            return false
        }
        
        
        //print(pk.pointee.data)
        
        let secp256k1_ec_compressed = self.publicKeyCompressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED
        
        //导出公钥字节压缩，结果1就代表成功
        guard secp256k1_ec_pubkey_serialize(self.ctx, data, &len, pk, UInt32(secp256k1_ec_compressed)) > 0 else {
            return false
        }
        
        //检查长度是否符合
        guard self.publicKeyLength == len else {
            return false
        }
        
        //print("len = \(len)")
        
        self.publicKey = Data(bytes: data, count: len)
        
        return true
    }
    
}


// MARK: - 公开方法
extension BTCKey {
    
    
    /// 清除内存，针对Secp256k1库使用的内存
    public func clear() {
        self.seckey = nil
        self.publicKeyCompressed = false
    }
    
    
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
        guard let address = self.privateKeyAddress else {
            return ""
        }
    
        return address.string
    }
    
    
    
    /// 私钥字节
    public var privateKey: Data? {
        return self.seckey
    }
    
    
    
    /// 地址，公钥的地址对象
    public var address: BTCPublickeyAddress? {
        let hash160 = self.publicKey.sha256().ripemd160()
        let address = try? BTCPublickeyAddress(data: hash160)
        return address
    }
    
    
    /// 地址，公钥的地址对象，address一样
    public var publicKeyAddress: BTCPublickeyAddress? {
        return self.address    //直接返回address
    }
    
    
    /// 私钥对象
    public var privateKeyAddress: BTCPrivateKeyAddress? {
        guard let data = self.seckey else {
            return nil
        }
        
        let address = try? BTCPrivateKeyAddress(data: data, compressed: self.publicKeyCompressed)
        return address
    }
    
    
    
    public func signature(for bytes: Data) -> Data? {
        return nil
    }
    
    
    /// 生成消息认证签名
    ///
    /// - Parameter message: 消息
    /// - Returns: 消息签名字节
    public func signature(for message: String) -> Data? {
        let hash = message.formatMessageForBitcoinSigning().sha256().sha256()
        let signature = self.compactSignature(for: hash)
        return signature
    }
    
    
    /// 比特币消息认证签名算法
    ///
    /// 通过私钥生成消息的签名，可以通过”地址“ + ”消息原文“ + ”消息签名“ 校验是否一致
    /// The format is one header byte, followed by two times 32 bytes for the serialized r and s values.
    /// The header byte: 0x1B = first key with even y, 0x1C = first key with odd y,
    ///                  0x1D = second key with even y, 0x1E = second key with odd y,
    ///                  add 0x04 for compressed keys.
    /// - Parameter hash: 消息的256位hash，32字节
    /// - Returns: 返回一个65字节压缩的消息签名字节
    public func compactSignature(for hash: Data) -> Data? {
        //print("hash = \(hash.hex)")
        var signature: Data?
        
        guard let key = self.seckey else {
            return nil
        }
        
        var len = 65
        var sig = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        sig.initialize(to: 0, count: len)    //初始全为0
        var s = UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>.allocate(capacity: 1)
        var recid: Int32 = 0
        
        //记得释放内存
        defer {
            s.deinitialize(count: 1)
            s.deallocate(capacity: 1)
            
            sig.deinitialize(count: len)
            sig.deallocate(capacity: len)
        }
        
        //生成签名
        guard secp256k1_ecdsa_sign_recoverable(self.ctx, s, hash.u8, key.u8, secp256k1_nonce_function_rfc6979, nil) > 0 else {
            return nil
        }
        //编码签名字节
        guard secp256k1_ecdsa_recoverable_signature_serialize_compact(self.ctx, sig.advanced(by: 1), &recid, s) > 0 else {
            return nil
        }
        
        //第一个字节记录ID
        sig.pointee = UInt8(27 + Int(recid) + (self.publicKeyCompressed ? 4 : 0))
        signature = Data(bytes: sig, count: len)

        return signature
        
    }

    
    /// 验证 签名 与 消息 是否一致
    /// 一致则返回一个公钥对象
    /// - Parameters:
    ///   - signature: 签名字节
    ///   - message: 消息原文
    /// - Returns: 签名私钥导出的公钥
    public class func verify(signature: Data, message: String) -> BTCKey? {
        let key = BTCKey(compactSig: signature, message: message)
        return key
    }
    
    
    /// 验证消息签名和消息原文的一致性
    ///
    /// - Parameters:
    ///   - signature: 签名字节
    ///   - message: 消息原文
    /// - Returns: 验证结果
    public func isValid(signature: Data, message: String) -> Bool {
        let key = BTCKey(compactSig: signature, message: message)
        return key?.publicKey == self.publicKey ? true : false
    }
    
    public func sign(data: Data) -> Data? {
        
        var signature: Data?
        
        guard let key = self.seckey else {
            return nil
        }
        
        var len = 72
        var sig = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        var s = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        
        //记得释放内存
        defer {
            s.deinitialize(count: 1)
            s.deallocate(capacity: 1)
            
            sig.deinitialize(count: len)
            sig.deallocate(capacity: len)
        }
        
        //签名
        guard secp256k1_ecdsa_sign(self.ctx, s, data.u8, key.u8, secp256k1_nonce_function_rfc6979, nil) > 0 else {
            return nil
        }
        
        //编码
        guard secp256k1_ecdsa_signature_serialize_der(self.ctx, sig, &len, s) > 0 else {
            return nil
        }
        
        signature = Data(bytes: sig, count: len)
        
        return signature
    }
    

    public func isValid(signature: Data, hash: Data) -> Bool {
        
        var pk = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
        var s = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        
        //记得释放内存
        defer {
            pk.deinitialize(count: 1)
            pk.deallocate(capacity: 1)
            
            s.deinitialize(count: 1)
            s.deallocate(capacity: 1)
            
        }
        
        guard secp256k1_ec_pubkey_parse(self.ctx, pk, self.publicKey.u8, self.publicKey.count) > 0 else {
            return false
        }
        
        guard secp256k1_ecdsa_signature_parse_der(self.ctx, s, signature.u8, signature.count) > 0 else {
            return false
        }
        
        guard secp256k1_ecdsa_verify(self.ctx, s, hash.u8, pk) > 0 else {
            return false
        }
        
        return true
        
    }
    
}
