//
//  BTCKey.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/8.
//
//

import Foundation
import Secp256k1

class BTCKey {
    
    var wif: String {
//        secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))
        print("SECP256K1_FLAGS_BIT_CONTEXT_SIGN = \(SECP256K1_FLAGS_BIT_CONTEXT_SIGN)")
        print("SECP256K1_CONTEXT_VERIFY = \(SECP256K1_CONTEXT_VERIFY)")
        return ""
    }
}
