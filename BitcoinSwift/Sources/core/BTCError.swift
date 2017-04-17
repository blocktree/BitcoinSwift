//
//  BitcoinSwiftError.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/11.
//
//

enum BTCError: Error {
    
    case initError(String)
    
    var reason: String {
        switch self {
        case let .initError(reason):
            return reason
        }
    }
}

