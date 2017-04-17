//
//  RIPEMD.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/11.
//
//
//  Originally taken from CryptoCoinSwift by Sjors (https://github.com/CryptoCoinSwift/RIPEMD-Swift/ )
//



import Foundation

public struct RIPEMD {
  public static func digest (_ input : Data, bitlength:Int = 160) -> Data {
    assert(bitlength == 160, "Only RIPEMD-160 is implemented")
    
    let paddedData = pad(input)
    
    var block = RIPEMD.Block()
    
    for i in 0 ..< paddedData.count / 64 {
      let part = getWordsInSection(paddedData, i)
      block.compress(part)
    }
    
    return encodeWords(block.hash)
  }
  
  // Pads the input to a multiple 64 bytes. First it adds 0x80 followed by zeros.
  // It then needs 8 bytes at the end where it writes the length (in bits, little endian).
  // If this doesn't fit it will add another block of 64 bytes.
  
  private static func pad(_ data: Data) -> Data {
    let paddedData = (data as NSData).mutableCopy() as! NSMutableData
    
    // Put 0x80 after the last character:
    let stop: [UInt8] = [UInt8(0x80)] // 2^8
    paddedData.append(stop, length: 1)
    
    // Pad with zeros until there are 64 * k - 8 bytes.
    var numberOfZerosToPad: Int;
    if paddedData.length % 64 == 56 {
      // No padding needed
      numberOfZerosToPad = 0
    } else if paddedData.length % 64 < 56 {
      numberOfZerosToPad = 56 - (paddedData.length % 64)
    } else {
      // Add an extra round
      numberOfZerosToPad = 56 + (64 - paddedData.length % 64)
    }
    
    let zeroBytes = [UInt8](repeating: 0, count: numberOfZerosToPad)
    paddedData.append(zeroBytes, length: numberOfZerosToPad)
    
    // Append length of message:
    let length: UInt32 = UInt32(data.count) * 8
    let lengthBytes: [UInt32] = [length, UInt32(0x00_00_00_00)]
    paddedData.append(lengthBytes, length: 8)
    
    return paddedData as Data
  }
  
  // Takes an NSData object of length k * 64 bytes and returns an array of UInt32
  // representing 1 word (4 bytes) each. Each word is in little endian,
  // so "abcdefgh" is now "dcbahgfe".
  private static func getWordsInSection(_ data: Data, _ section: Int) -> [UInt32] {
    let offset = section * 64
    
    assert(data.count >= Int(offset + 64), "Data too short")
    
    var words: [UInt32] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    (data as NSData).getBytes(&words, range: NSMakeRange(offset, 64))
    
    
    return words
  }
  
  private static func encodeWords(_ input: [UInt32]) -> Data {
    let data = NSMutableData(bytes: input, length: 20)
    return data as Data
  }
}
