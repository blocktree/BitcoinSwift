//
//  BTCOpcode.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/26.
//
//

import Foundation

//MARK: 脚本语言指令集
//https://en.bitcoin.it/wiki/Script#Constants
public enum BTCOpcode: UInt8 {
    
    // 1. Operators pushing data on stack.
    
    // Push 1 byte 0x00 on the stack
    case OP_0 = 0x00
    //case OP_FALSE = 0x00
    
    // Any opcode with value < PUSHDATA1 is a length of the string to be pushed on the stack.
    // So opcode 0x01 is followed by 1 byte of data, 0x09 by 9 bytes and so on up to 0x4b (75 bytes)
    
    // PUSHDATA<N> opcode is followed by N-byte length of the string that follows.
    case OP_PUSHDATA1 = 0x4c // followed by a 1-byte length of the string to push (allows pushing 0..255 bytes).
    case OP_PUSHDATA2 = 0x4d // followed by a 2-byte length of the string to push (allows pushing 0..65535 bytes).
    case OP_PUSHDATA4 = 0x4e // followed by a 4-byte length of the string to push (allows pushing 0..4294967295 bytes).
    case OP_1NEGATE   = 0x4f // pushes -1 number on the stack
    case OP_RESERVED  = 0x50 // Not assigned. If executed, transaction is invalid.
    
    // OP_<N> pushes number <N> on the stack
    case OP_1  = 0x51
    //case OP_TRUE = 0x51
    case OP_2  = 0x52
    case OP_3  = 0x53
    case OP_4  = 0x54
    case OP_5  = 0x55
    case OP_6  = 0x56
    case OP_7  = 0x57
    case OP_8  = 0x58
    case OP_9  = 0x59
    case OP_10 = 0x5a
    case OP_11 = 0x5b
    case OP_12 = 0x5c
    case OP_13 = 0x5d
    case OP_14 = 0x5e
    case OP_15 = 0x5f
    case OP_16 = 0x60
    
    // 2. Control flow operators
    
    case OP_NOP      = 0x61 // Does nothing
    case OP_VER      = 0x62 // Not assigned. If executed, transaction is invalid.
    
    // BitcoinQT executes all operators from OP_IF to OP_ENDIF even inside "non-executed" branch (to keep track of nesting).
    // Since OP_VERIF and OP_VERNOTIF are not assigned, even inside a non-executed branch they will fall in "default:" switch case
    // and cause the script to fail. Some other ops like OP_VER can be present inside non-executed branch because they'll be skipped.
    case OP_IF       = 0x63 // If the top stack value is not 0, the statements are executed. The top stack value is removed.
    case OP_NOTIF    = 0x64 // If the top stack value is 0, the statements are executed. The top stack value is removed.
    case OP_VERIF    = 0x65 // Not assigned. Script is invalid with that opcode (even if inside non-executed branch).
    case OP_VERNOTIF = 0x66 // Not assigned. Script is invalid with that opcode (even if inside non-executed branch).
    case OP_ELSE     = 0x67 // Executes code if the previous OP_IF or OP_NOTIF was not executed.
    case OP_ENDIF    = 0x68 // Finishes if/else block
    
    case OP_VERIFY   = 0x69 // Removes item from the stack if it's not 0x00 or 0x80 (negative zero). Otherwise, marks script as invalid.
    case OP_RETURN   = 0x6a // Marks transaction as invalid.
    
    // Stack ops
    case OP_TOALTSTACK   = 0x6b // Moves item from the stack to altstack
    case OP_FROMALTSTACK = 0x6c // Moves item from the altstack to stack
    case OP_2DROP = 0x6d
    case OP_2DUP  = 0x6e
    case OP_3DUP  = 0x6f
    case OP_2OVER = 0x70
    case OP_2ROT  = 0x71
    case OP_2SWAP = 0x72
    case OP_IFDUP = 0x73
    case OP_DEPTH = 0x74
    case OP_DROP  = 0x75
    case OP_DUP   = 0x76
    case OP_NIP   = 0x77
    case OP_OVER  = 0x78
    case OP_PICK  = 0x79
    case OP_ROLL  = 0x7a
    case OP_ROT   = 0x7b
    case OP_SWAP  = 0x7c
    case OP_TUCK  = 0x7d
    
    // Splice ops
    case OP_CAT    = 0x7e // Disabled opcode. If executed, transaction is invalid.
    case OP_SUBSTR = 0x7f // Disabled opcode. If executed, transaction is invalid.
    case OP_LEFT   = 0x80 // Disabled opcode. If executed, transaction is invalid.
    case OP_RIGHT  = 0x81 // Disabled opcode. If executed, transaction is invalid.
    case OP_SIZE   = 0x82
    
    // Bit logic
    case OP_INVERT = 0x83 // Disabled opcode. If executed, transaction is invalid.
    case OP_AND    = 0x84 // Disabled opcode. If executed, transaction is invalid.
    case OP_OR     = 0x85 // Disabled opcode. If executed, transaction is invalid.
    case OP_XOR    = 0x86 // Disabled opcode. If executed, transaction is invalid.
    
    case OP_EQUAL = 0x87        // Last two items are removed from the stack and compared. Result (true or false) is pushed to the stack.
    case OP_EQUALVERIFY = 0x88  // Same as OP_EQUAL, but removes the result from the stack if it's true or marks script as invalid.
    
    case OP_RESERVED1 = 0x89 // Disabled opcode. If executed, transaction is invalid.
    case OP_RESERVED2 = 0x8a // Disabled opcode. If executed, transaction is invalid.
    
    // Numeric
    case OP_1ADD      = 0x8b  // adds 1 to last item, pops it from stack and pushes result.
    case OP_1SUB      = 0x8c  // substracts 1 to last item, pops it from stack and pushes result.
    case OP_2MUL      = 0x8d  // Disabled opcode. If executed, transaction is invalid.
    case OP_2DIV      = 0x8e  // Disabled opcode. If executed, transaction is invalid.
    case OP_NEGATE    = 0x8f  // negates the number, pops it from stack and pushes result.
    case OP_ABS       = 0x90  // replaces number with its absolute value
    case OP_NOT       = 0x91  // replaces number with True if it's zero, False otherwise.
    case OP_0NOTEQUAL = 0x92  // replaces number with True if it's not zero, False otherwise.
    
    case OP_ADD    = 0x93  // (x y -- x+y)
    case OP_SUB    = 0x94  // (x y -- x-y)
    case OP_MUL    = 0x95  // Disabled opcode. If executed, transaction is invalid.
    case OP_DIV    = 0x96  // Disabled opcode. If executed, transaction is invalid.
    case OP_MOD    = 0x97  // Disabled opcode. If executed, transaction is invalid.
    case OP_LSHIFT = 0x98  // Disabled opcode. If executed, transaction is invalid.
    case OP_RSHIFT = 0x99  // Disabled opcode. If executed, transaction is invalid.
    
    case OP_BOOLAND            = 0x9a
    case OP_BOOLOR             = 0x9b
    case OP_NUMEQUAL           = 0x9c
    case OP_NUMEQUALVERIFY     = 0x9d
    case OP_NUMNOTEQUAL        = 0x9e
    case OP_LESSTHAN           = 0x9f
    case OP_GREATERTHAN        = 0xa0
    case OP_LESSTHANOREQUAL    = 0xa1
    case OP_GREATERTHANOREQUAL = 0xa2
    case OP_MIN                = 0xa3
    case OP_MAX                = 0xa4
    
    case OP_WITHIN = 0xa5
    
    // Crypto
    case OP_RIPEMD160      = 0xa6
    case OP_SHA1           = 0xa7
    case OP_SHA256         = 0xa8
    case OP_HASH160        = 0xa9
    case OP_HASH256        = 0xaa
    case OP_CODESEPARATOR  = 0xab // This opcode is rarely used because it's useless, but we need to support it anyway.
    case OP_CHECKSIG       = 0xac
    case OP_CHECKSIGVERIFY = 0xad
    case OP_CHECKMULTISIG  = 0xae
    case OP_CHECKMULTISIGVERIFY = 0xaf
    
    // Expansion
    case OP_NOP1  = 0xb0
    case OP_NOP2  = 0xb1
    case OP_NOP3  = 0xb2
    case OP_NOP4  = 0xb3
    case OP_NOP5  = 0xb4
    case OP_NOP6  = 0xb5
    case OP_NOP7  = 0xb6
    case OP_NOP8  = 0xb7
    case OP_NOP9  = 0xb8
    case OP_NOP10 = 0xb9
    
    case OP_INVALIDOPCODE = 0xff
    
    ///同值指令，使用静态常量定义
    static let OP_FALSE = BTCOpcode.OP_0
    static let OP_TRUE = BTCOpcode.OP_1
    
    
    /// 命名字典
    static let names: [String: BTCOpcode] = [
        "OP_0":                   BTCOpcode.OP_0,
        "OP_FALSE":               BTCOpcode.OP_FALSE,
        "OP_PUSHDATA1":           BTCOpcode.OP_PUSHDATA1,
        "OP_PUSHDATA2":           BTCOpcode.OP_PUSHDATA2,
        "OP_PUSHDATA4":           BTCOpcode.OP_PUSHDATA4,
        "OP_1NEGATE":             BTCOpcode.OP_1NEGATE,
        "OP_RESERVED":            BTCOpcode.OP_RESERVED,
        "OP_1":                   BTCOpcode.OP_1,
        "OP_TRUE":                BTCOpcode.OP_TRUE,
        "OP_2":                   BTCOpcode.OP_2,
        "OP_3":                   BTCOpcode.OP_3,
        "OP_4":                   BTCOpcode.OP_4,
        "OP_5":                   BTCOpcode.OP_5,
        "OP_6":                   BTCOpcode.OP_6,
        "OP_7":                   BTCOpcode.OP_7,
        "OP_8":                   BTCOpcode.OP_8,
        "OP_9":                   BTCOpcode.OP_9,
        "OP_10":                  BTCOpcode.OP_10,
        "OP_11":                  BTCOpcode.OP_11,
        "OP_12":                  BTCOpcode.OP_12,
        "OP_13":                  BTCOpcode.OP_13,
        "OP_14":                  BTCOpcode.OP_14,
        "OP_15":                  BTCOpcode.OP_15,
        "OP_16":                  BTCOpcode.OP_16,
        "OP_NOP":                 BTCOpcode.OP_NOP,
        "OP_VER":                 BTCOpcode.OP_VER,
        "OP_IF":                  BTCOpcode.OP_IF,
        "OP_NOTIF":               BTCOpcode.OP_NOTIF,
        "OP_VERIF":               BTCOpcode.OP_VERIF,
        "OP_VERNOTIF":            BTCOpcode.OP_VERNOTIF,
        "OP_ELSE":                BTCOpcode.OP_ELSE,
        "OP_ENDIF":               BTCOpcode.OP_ENDIF,
        "OP_VERIFY":              BTCOpcode.OP_VERIFY,
        "OP_RETURN":              BTCOpcode.OP_RETURN,
        "OP_TOALTSTACK":          BTCOpcode.OP_TOALTSTACK,
        "OP_FROMALTSTACK":        BTCOpcode.OP_FROMALTSTACK,
        "OP_2DROP":               BTCOpcode.OP_2DROP,
        "OP_2DUP":                BTCOpcode.OP_2DUP,
        "OP_3DUP":                BTCOpcode.OP_3DUP,
        "OP_2OVER":               BTCOpcode.OP_2OVER,
        "OP_2ROT":                BTCOpcode.OP_2ROT,
        "OP_2SWAP":               BTCOpcode.OP_2SWAP,
        "OP_IFDUP":               BTCOpcode.OP_IFDUP,
        "OP_DEPTH":               BTCOpcode.OP_DEPTH,
        "OP_DROP":                BTCOpcode.OP_DROP,
        "OP_DUP":                 BTCOpcode.OP_DUP,
        "OP_NIP":                 BTCOpcode.OP_NIP,
        "OP_OVER":                BTCOpcode.OP_OVER,
        "OP_PICK":                BTCOpcode.OP_PICK,
        "OP_ROLL":                BTCOpcode.OP_ROLL,
        "OP_ROT":                 BTCOpcode.OP_ROT,
        "OP_SWAP":                BTCOpcode.OP_SWAP,
        "OP_TUCK":                BTCOpcode.OP_TUCK,
        "OP_CAT":                 BTCOpcode.OP_CAT,
        "OP_SUBSTR":              BTCOpcode.OP_SUBSTR,
        "OP_LEFT":                BTCOpcode.OP_LEFT,
        "OP_RIGHT":               BTCOpcode.OP_RIGHT,
        "OP_SIZE":                BTCOpcode.OP_SIZE,
        "OP_INVERT":              BTCOpcode.OP_INVERT,
        "OP_AND":                 BTCOpcode.OP_AND,
        "OP_OR":                  BTCOpcode.OP_OR,
        "OP_XOR":                 BTCOpcode.OP_XOR,
        "OP_EQUAL":               BTCOpcode.OP_EQUAL,
        "OP_EQUALVERIFY":         BTCOpcode.OP_EQUALVERIFY,
        "OP_RESERVED1":           BTCOpcode.OP_RESERVED1,
        "OP_RESERVED2":           BTCOpcode.OP_RESERVED2,
        "OP_1ADD":                BTCOpcode.OP_1ADD,
        "OP_1SUB":                BTCOpcode.OP_1SUB,
        "OP_2MUL":                BTCOpcode.OP_2MUL,
        "OP_2DIV":                BTCOpcode.OP_2DIV,
        "OP_NEGATE":              BTCOpcode.OP_NEGATE,
        "OP_ABS":                 BTCOpcode.OP_ABS,
        "OP_NOT":                 BTCOpcode.OP_NOT,
        "OP_0NOTEQUAL":           BTCOpcode.OP_0NOTEQUAL,
        "OP_ADD":                 BTCOpcode.OP_ADD,
        "OP_SUB":                 BTCOpcode.OP_SUB,
        "OP_MUL":                 BTCOpcode.OP_MUL,
        "OP_DIV":                 BTCOpcode.OP_DIV,
        "OP_MOD":                 BTCOpcode.OP_MOD,
        "OP_LSHIFT":              BTCOpcode.OP_LSHIFT,
        "OP_RSHIFT":              BTCOpcode.OP_RSHIFT,
        "OP_BOOLAND":             BTCOpcode.OP_BOOLAND,
        "OP_BOOLOR":              BTCOpcode.OP_BOOLOR,
        "OP_NUMEQUAL":            BTCOpcode.OP_NUMEQUAL,
        "OP_NUMEQUALVERIFY":      BTCOpcode.OP_NUMEQUALVERIFY,
        "OP_NUMNOTEQUAL":         BTCOpcode.OP_NUMNOTEQUAL,
        "OP_LESSTHAN":            BTCOpcode.OP_LESSTHAN,
        "OP_GREATERTHAN":         BTCOpcode.OP_GREATERTHAN,
        "OP_LESSTHANOREQUAL":     BTCOpcode.OP_LESSTHANOREQUAL,
        "OP_GREATERTHANOREQUAL":  BTCOpcode.OP_GREATERTHANOREQUAL,
        "OP_MIN":                 BTCOpcode.OP_MIN,
        "OP_MAX":                 BTCOpcode.OP_MAX,
        "OP_WITHIN":              BTCOpcode.OP_WITHIN,
        "OP_RIPEMD160":           BTCOpcode.OP_RIPEMD160,
        "OP_SHA1":                BTCOpcode.OP_SHA1,
        "OP_SHA256":              BTCOpcode.OP_SHA256,
        "OP_HASH160":             BTCOpcode.OP_HASH160,
        "OP_HASH256":             BTCOpcode.OP_HASH256,
        "OP_CODESEPARATOR":       BTCOpcode.OP_CODESEPARATOR,
        "OP_CHECKSIG":            BTCOpcode.OP_CHECKSIG,
        "OP_CHECKSIGVERIFY":      BTCOpcode.OP_CHECKSIGVERIFY,
        "OP_CHECKMULTISIG":       BTCOpcode.OP_CHECKMULTISIG,
        "OP_CHECKMULTISIGVERIFY": BTCOpcode.OP_CHECKMULTISIGVERIFY,
        "OP_NOP1":                BTCOpcode.OP_NOP1,
        "OP_NOP2":                BTCOpcode.OP_NOP2,
        "OP_NOP3":                BTCOpcode.OP_NOP3,
        "OP_NOP4":                BTCOpcode.OP_NOP4,
        "OP_NOP5":                BTCOpcode.OP_NOP5,
        "OP_NOP6":                BTCOpcode.OP_NOP6,
        "OP_NOP7":                BTCOpcode.OP_NOP7,
        "OP_NOP8":                BTCOpcode.OP_NOP8,
        "OP_NOP9":                BTCOpcode.OP_NOP9,
        "OP_NOP10":               BTCOpcode.OP_NOP10,
        "OP_INVALIDOPCODE":       BTCOpcode.OP_INVALIDOPCODE,
    ]
    
    
    /// 通过命名查找指令定义
    ///
    /// - Parameter name: 指令名字
    /// - Returns: 指令定义
    public static func opcode(for name: String) -> BTCOpcode {
        return BTCOpcode.names[name] ?? .OP_INVALIDOPCODE
    }
    
    
    /// 指令名字
    public var name: String {
        var name = "OP_UNKNOWN"
        for (key, value) in BTCOpcode.names {
            if value == self {
                name = key
                break
            }
        }
        return name
    }
}
