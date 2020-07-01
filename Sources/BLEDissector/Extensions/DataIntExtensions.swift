//
//  DataExtensions.swift
//
//  Created by Boris Polania on 2/16/18.
//

import Foundation

extension Data {
    
    var uint8: UInt8 {
        get {
            return self[self.startIndex]
        }
    }
    
    var uint16: UInt16 {
        get {
            var value: UInt16 = 0
            _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
            return value
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
    
    func toUInt8(littleEndian:Bool=true) -> UInt8 {
        let d = Data(self)
        return d[0]
    }
    
    func toUInt16(littleEndian:Bool=true) -> UInt16 {
        let d = Data(self)
        
        let uint = UInt16(littleEndian: unsafeBitCast((d[0], d[1]), to: UInt16.self))
        if !littleEndian {
            return UInt16(bigEndian: uint)
        }
        return uint
    }
    
    func toUInt32(littleEndian:Bool=true) -> UInt32 {
        let d = Data(self)
        
        let uint = UInt32(littleEndian: unsafeBitCast((d[0], d[1], d[2], d[3]), to: UInt32.self))
        if !littleEndian {
            return UInt32(bigEndian: uint)
        }
        return uint
    }
    
    func toUInt64(littleEndian:Bool=true) -> UInt64 {
        let d = Data(self)
        
        let uint = UInt64(littleEndian: unsafeBitCast((d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7]), to: UInt64.self))
        if !littleEndian {
            return UInt64(bigEndian: uint)
        }
        return uint
    }

    
//    var uint16_bigEndian: UInt16 {
//        return UInt16(bigEndian: self.uint16)
//    }
    
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
    
    func byteRangeToEnd(from index: Data.Index) -> ClosedRange<UInt> {
        //End index is not part of the accessible bytes. It's last + 1
        UInt(self.startIndex.distance(to: index))...UInt(startIndex.distance(to: self.endIndex)-1)
    }
    
    func byteRange(from index: Data.Index, to toIndex: Data.Index) -> ClosedRange<UInt> {
        UInt(self.startIndex.distance(to: index))...UInt(startIndex.distance(to: toIndex))
    }
    
    func singleByteRange(with index: Data.Index) -> ClosedRange<UInt> {
        UInt(self.startIndex.distance(to: index))...UInt(startIndex.distance(to: index))
    }
    
}
