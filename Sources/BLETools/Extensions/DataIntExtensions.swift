//
//  DataExtensions.swift
//
//  Created by Boris Polania on 2/16/18.
//

import Foundation

extension Data {
    
    var uint8: UInt8 {
        get {
            return self[0]
        }
    }
    
    var uint16: UInt16 {
        get {
            return UInt16(littleEndian: unsafeBitCast((self[0], self[1]), to: UInt16.self))
//           var value: UInt16 = 0
//            _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
//            return value
        }
    }
    
    var uint32: UInt32 {
        get {
             var value: UInt32 = 0
            _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
            return value
        }
    }
    
    var uint64: UInt64 {
        get {
             var value: UInt64 = 0
            _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
            return value
        }
    }
    
    var uuid: NSUUID? {
        get {
            var bytes = [UInt8](repeating: 0, count: self.count)
            self.copyBytes(to:&bytes, count: self.count * MemoryLayout<UInt32>.size)
            return NSUUID(uuidBytes: bytes)
        }
    }
    var stringASCII: String? {
        get {
            return NSString(data: self, encoding: String.Encoding.ascii.rawValue) as String?
        }
    }
    
    var stringUTF8: String? {
        get {
            return NSString(data: self, encoding: String.Encoding.utf8.rawValue) as String?
        }
    }

    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
    
}
