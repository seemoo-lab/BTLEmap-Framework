//
//  NearbyActionDecoder.swift
//  Apple-BLE-Decoder
//
//  Created by Alex - SEEMOO on 09.03.20.
//

import Foundation

public extension AppleBLEDecoding {
    struct NearbyActionDecoder: AppleBLEDecoder {
        public var decodableType: UInt8 {0x0f}
        
        public func decode(_ data: Data) throws -> [String : DecodedEntry] {
            var i = data.startIndex
            var describingDict = [String: DecodedEntry]()
            guard data.count >= 5 else {throw Error.incorrectLength}
            
            // Action flags one byte - 1
            let actionFlags = data[i]
            describingDict["actionFlags"] = DecodedEntry(value: actionFlags, byteRange: i...i)
            i += 1
            
            // Action type one byte - 2
            let actionType = data[i]
            let actionTypeDecoded = ActionType(rawValue: actionType) ?? ActionType.unknown
            describingDict["actionType"] = DecodedEntry(value: actionTypeDecoded, byteRange: i...i)
//            describingDict["actionTypeFlag"] = DecodedEntry(value: actionType, byteRange: 2...2)
            i += 1
            
            //Auth tag 3 bytes 2...4
            let authTag = data[i..<i+3]
            describingDict["authTag"] = DecodedEntry(value: authTag, byteRange: i...i+2)
            i += 3
            
            let actionParameters = data[i..<data.endIndex]
            describingDict["actionParameters"] = DecodedEntry(value: actionParameters, byteRange: i...i)
            
            if actionType == ActionType.wifiPassword.rawValue && data.count >= 14 {
                //Wi-Fi Password sharing
                let appleIDHash = data[i...i+2]
                describingDict["appleIdHash"] = DecodedEntry(value: appleIDHash, byteRange: i...i+2)
                i+=3
                let phoneNumHash = data[i...i+2]
                describingDict["phoneNumberHash"] = DecodedEntry(value: phoneNumHash, byteRange: i...i+2)
                i+=3
                let mailHash = data[i...i+2]
                describingDict["emailHash"] = DecodedEntry(value: mailHash, byteRange: i...i+2)
                i+=3
                let ssidHash = data[i...i+2]
                describingDict["wifiSSIDHash"] = DecodedEntry(value: ssidHash, byteRange: i...i+2)
                 
            }
            
            
            return describingDict
        }
        
        public enum ActionType: UInt8 {
            case unknown = 0x00
            case appleTVSetup = 0x01
            case mobileBackup = 0x02
            case watchSetup = 0x05
            case appleTVPairing = 0x06
            case interntRelay = 0x07
            case wifiPassword = 0x08
            case iosSetup = 0x09
            case repair = 0x0a
            case speakerSetup = 0x0b
            case applePay = 0x0c
            case homeAudioSetup = 0x0d
            case developerToolsPairingRequest = 0x0e
            case answeredCall = 0x0f
            case endedCall = 0x10
            case ddPing = 0x11
            case ddPong = 0x12
            case companionLinkProximity = 0x14
            case remoteManagement = 0x15
            case remoteAutofillPong = 0x16
            case remoteDisplay = 0x17
        }
        
    }
}
