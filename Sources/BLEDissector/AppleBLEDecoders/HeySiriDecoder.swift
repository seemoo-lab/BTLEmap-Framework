//
//  HeySiriDecoder.swift
//  Apple-BLE-Decoder
//
//  Created by Alex - SEEMOO on 09.03.20.
//

import Foundation

public extension AppleBLEDecoding {
    struct HeySiriDecoder: AppleBLEDecoder {
        public var decodableType: UInt8 {0x08}
        
        public func decode(_ data: Data) throws -> [String : DecodedEntry] {
            guard data.count >= 6 else {throw Error.incorrectLength}
            
            var i = data.startIndex
            var describingDict = [String: DecodedEntry]()
            
            let perceptualHash = data[i..<i+2]
            describingDict["perceptualHashHex"] = DecodedEntry(value: perceptualHash.hexadecimal, byteRange: i...i+2)
            i+=2
            
            let snr = data[i]
            describingDict["SNR"] = DecodedEntry(value: snr, byteRange: i...i)
            i+=1
            
            let confidence = data[i]
            describingDict["confidence"] = DecodedEntry(value: confidence, byteRange: i...i)
            i+=1
            
            let deviceClass = data[i..<i+2]
//            describingDict["deviceClassData"] = DecodedEntry(value: deviceClass.hexadecimal, byteRange: i...i+1)
            let deviceClassD = DeviceClass(rawValue: deviceClass.toUInt16(littleEndian: false))  ?? DeviceClass.unknown
            describingDict["deviceClass"] = DecodedEntry(value: deviceClassD, byteRange: i...i+1)
            
            
            return describingDict
        }
        
        
        public enum DeviceClass: UInt16 {
            case iPhone = 0x0002
            case iPad = 0x0003
            //Missing 4-8
            case mac = 0x0009
            case watch = 0x000a
            case unknown = 0x0000
        }
        
    }
}
