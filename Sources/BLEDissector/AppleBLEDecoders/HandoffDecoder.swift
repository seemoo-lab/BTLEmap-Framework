//
//  HandoffDecoder.swift
//  Apple-BLE-Decoder
//
//  Created by Alex - SEEMOO on 09.03.20.
//

import Foundation

public extension AppleBLEDecoding {
    struct HandoffDecoder: AppleBLEDecoder {
        public var decodableType: UInt8 {0x0c}
        
        public func decode(_ data: Data) throws -> [String : DecodedEntry] {
            guard data.count >= 5 else {throw Error.incorrectLength}
            
            var i = data.startIndex
            var describingDict = [String: DecodedEntry]()
            
            let clipboardStatus = data[i]
            let publicClipboard = PublicClipboardStatus(rawValue: clipboardStatus) ?? PublicClipboardStatus.unknown
            describingDict["clipboardStatus"] = DecodedEntry(value: publicClipboard, byteRange: i...i)
//            describingDict["clipboardStatusRaw"] = DecodedEntry(value: clipboardStatus, byteRange: i...i)
            i+=1
            
            let iv = data[i..<i+2]
//            describingDict["ivData"] = DecodedEntry(value: iv, dataRange: i...i+1, data: data)
            describingDict["iv"] = DecodedEntry(value: iv.toUInt16(littleEndian: true), dataRange: i...i+1, data: data)
            i+=2
            
            let authTag = data[i]
            describingDict["authTag"] = DecodedEntry(value: authTag, byteRange:i...i)
            i+=1
            
            let authenticatedData = data[i]
            describingDict["authenticatedData"] = DecodedEntry(value: authenticatedData, byteRange: i...i)
            i+=1
            
            let encryptedData = data[i..<data.endIndex]
            describingDict["encryptedData"] = DecodedEntry(value: encryptedData, byteRange: i...data.endIndex-1)
            
            return describingDict
        }
        
        public enum PublicClipboardStatus:UInt8 {
            case clipboardEmpty = 0x00
            case clipboardFull = 0x08
            case unknown = 0xff
        }
        
    }
}
