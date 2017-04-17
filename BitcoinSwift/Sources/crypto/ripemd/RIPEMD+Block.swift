//
//  RIPEMD+Block.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/11.
//
//
//  Originally taken from CryptoCoinSwift by Sjors (https://github.com/CryptoCoinSwift/RIPEMD-Swift/ )
//


extension RIPEMD {
  internal struct Block {
    internal init() {}
    
    var message: [UInt32] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    // Initial values
    var h₀: UInt32 = 0x67452301
    var h₁: UInt32 = 0xEFCDAB89
    var h₂: UInt32 = 0x98BADCFE
    var h₃: UInt32 = 0x10325476
    var h₄: UInt32 = 0xC3D2E1F0
    
    internal var hash: [UInt32] {
      return [h₀, h₁, h₂, h₃, h₄]
    }
    
    internal mutating func compress (_ message: [UInt32]) -> () {
      assert(message.count == 16, "Wrong message size")
      
      var Aᴸ = h₀
      var Bᴸ = h₁
      var Cᴸ = h₂
      var Dᴸ = h₃
      var Eᴸ = h₄
      
      var Aᴿ = h₀
      var Bᴿ = h₁
      var Cᴿ = h₂
      var Dᴿ = h₃
      var Eᴿ = h₄
      
      for j in 0...79 {
        // Left side
        let wordᴸ = message[r.left[j]]
        let functionᴸ = f(j)
        
        let Tᴸ: UInt32 = ((Aᴸ &+ functionᴸ(Bᴸ,Cᴸ,Dᴸ) &+ wordᴸ &+ K.left[j]) ~<< s.left[j]) &+ Eᴸ
        
        Aᴸ = Eᴸ
        Eᴸ = Dᴸ
        Dᴸ = Cᴸ ~<< 10
        Cᴸ = Bᴸ
        Bᴸ = Tᴸ
        
        // Right side
        let wordᴿ = message[r.right[j]]
        let functionᴿ = f(79 - j)
        
        let Tᴿ: UInt32 = ((Aᴿ &+ functionᴿ(Bᴿ,Cᴿ,Dᴿ) &+ wordᴿ &+ K.right[j]) ~<< s.right[j]) &+ Eᴿ
        
        Aᴿ = Eᴿ
        Eᴿ = Dᴿ
        Dᴿ = Cᴿ ~<< 10
        Cᴿ = Bᴿ
        Bᴿ = Tᴿ
      }
      
      let T = h₁ &+ Cᴸ &+ Dᴿ
      h₁ = h₂ &+ Dᴸ &+ Eᴿ
      h₂ = h₃ &+ Eᴸ &+ Aᴿ
      h₃ = h₄ &+ Aᴸ &+ Bᴿ
      h₄ = h₀ &+ Bᴸ &+ Cᴿ
      h₀ = T
    }
    
    internal func f (_ j: Int) -> ((UInt32, UInt32, UInt32) -> UInt32) {
      switch j {
      case 0..<16:
        return {(x, y, z) in  x ^ y ^ z }
      case 16..<32:
        return {(x, y, z) in  (x & y) | (~x & z) }
      case 32..<48:
        return {(x, y, z) in  (x | ~y) ^ z }
      case 48..<64:
        return {(x, y, z) in  (x & z) | (y & ~z) }
      case 64..<80:
        return {(x, y, z) in  x ^ (y | ~z) }
      default:
        assert(false, "Invalid j")
        return {(_, _, _) in 0 }
      }
    }
    
    internal enum K {
      case left, right
      
      internal subscript(index: Int) -> UInt32 {
        switch index {
        case 0..<16:
          return self == .left ? 0x00000000 : 0x50A28BE6
        case 16..<32:
          return self == .left ? 0x5A827999 : 0x5C4DD124
        case 32..<48:
          return self == .left ? 0x6ED9EBA1 : 0x6D703EF3
        case 48..<64:
          return self == .left ? 0x8F1BBCDC : 0x7A6D76E9
        case 64..<80:
          return self == .left ? 0xA953FD4E : 0x00000000
        default:
          assert(false, "Invalid index")
          return 0
        }
      }
    }
    
    internal enum r {
      case left, right
      
      internal subscript (index: Int) -> Int {
        switch index {
        case 0..<16:
          if self == .left {
            return index
          } else {
            return [5,14,7,0,9,2,11,4,13,6,15,8,1,10,3,12][index]
          }
        case 16..<32:
          if self == .left {
            return [ 7, 4,13, 1,10, 6,15, 3,12, 0, 9, 5, 2,14,11, 8][index - 16]
          } else {
            return [ 6,11, 3, 7, 0,13, 5,10,14,15, 8,12, 4, 9, 1, 2][index - 16]
          }
        case 32..<48:
          if self == .left {
            return [3,10,14,4,9,15,8,1,2,7,0,6,13,11,5,12][index - 32]
          } else {
            return [15,5,1,3,7,14,6,9,11,8,12,2,10,0,4,13][index - 32]
          }
        case 48..<64:
          if self == .left {
            return [1,9,11,10,0,8,12,4,13,3,7,15,14,5,6,2][index - 48]
          } else {
            return [8,6,4,1,3,11,15,0,5,12,2,13,9,7,10,14][index - 48]
          }
        case 64..<80:
          if self == .left {
            return [ 4,0,5,9,7,12,2,10,14,1,3,8,11,6,15,13][index - 64]
          } else {
            return [12,15,10,4,1,5,8,7,6,2,13,14,0,3,9,11][index - 64]
          }
          
        default:
          assert(false, "Invalid index")
          return 0
        }
      }
    }
    
    internal enum s {
      case left, right
      
      internal subscript(index: Int) -> Int {
        switch index {
        case  0..<16:
          return (self == .left ? [11,14,15,12,5,8,7,9,11,13,14,15,6,7,9,8] : [8,9,9,11,13,15,15,5,7,7,8,11,14,14,12,6])[index]
        case 16..<32:
          return (self == .left ? [7,6,8,13,11,9,7,15,7,12,15,9,11,7,13,12] : [9,13,15,7,12,8,9,11,7,7,12,7,6,15,13,11])[index - 16]
        case 32..<48:
          return (self == .left ? [11,13,6,7,14,9,13,15,14,8,13,6,5,12,7,5] : [9,7,15,11,8,6,6,14,12,13,5,14,13,13,7,5])[index - 32]
        case 48..<64:
          return (self == .left ? [11,12,14,15,14,15,9,8,9,14,5,6,8,6,5,12] : [15,5,8,11,14,14,6,14,6,9,12,9,12,5,15,8])[index - 48]
        case  64..<80:
          return (self == .left ? [9,15,5,11,6,8,13,12,5,12,13,14,11,8,5,6] : [8,5,12,9,12,5,14,6,8,13,6,5,15,13,11,11])[index - 64]
        default:
          assert(false, "Invalid index")
          return 0
        }
      }      
    }
  }
    
}

// Circular left shift: http://en.wikipedia.org/wiki/Circular_shift
// Precedence should be the same as <<
infix operator  ~<< : BitwiseShiftPrecedence

internal func ~<< (lhs: UInt32, rhs: Int) -> UInt32 {
    return (lhs << UInt32(rhs)) | (lhs >> UInt32(32 - rhs));
}

