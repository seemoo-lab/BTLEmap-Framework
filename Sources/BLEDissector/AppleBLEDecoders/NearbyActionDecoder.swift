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
            let actionTypeDecoded = ActionType(rawValue: actionType)
            describingDict["actionType"] = DecodedEntry(value: actionTypeDecoded, byteRange: i...i)
//            describingDict["actionTypeFlag"] = DecodedEntry(value: actionType, byteRange: 2...2)
            i += 1
            
            //Auth tag 3 bytes 2...4
            let authTag = data[i..<i+3]
            describingDict["authTag"] = DecodedEntry(value: authTag, byteRange: i...i+2)
            i += 3
            
            guard data.endIndex > i else {return describingDict}
            
            let actionParameters = data[i..<data.endIndex]
            describingDict["actionParameters"] = DecodedEntry(value: actionParameters, byteRange: i...i)
            
            if actionType == ActionType.wifiPassword.byteValue && data.count >= 14 {
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
        
        public enum ActionType: CaseIterable {
            public static var allCases: [AppleBLEDecoding.NearbyActionDecoder.ActionType] = [.answeredCall, .applePay, .appleTVPairing, .appleTVSetup,  .companionLinkProximity, .ddPing, .ddPong, .developerToolsPairingRequest, .endedCall, .homeAudioSetup,  .interntRelay, .iosSetup, .mobileBackup, .remoteAutofillPong, .remoteDisplay, .remoteManagement, .repair, .speakerSetup, .watchSetup, .wifiPassword]
            
            public typealias AllCases = [ActionType]
            
            
            public init(rawValue: UInt8) {
                for c in ActionType.allCases {
                    if c.byteValue == rawValue {
                        self = c
                    }
                }
                
                self = ActionType.unknown(type: rawValue)
            }
            
            var byteValue: UInt8 {
                switch self {
                case .unknown(type: let type):
                    return type
                case .appleTVSetup:
                    return 0x01
                case .mobileBackup:
                    return 0x02
                case .watchSetup:
                    return 5
                case .appleTVPairing:
                    return 6
                case .interntRelay:
                    return 7
                case .wifiPassword:
                    return 8
                case .iosSetup:
                    return 9
                case .repair:
                    return 0x0a
                case .speakerSetup:
                    return 0x0b
                case .applePay:
                    return 0x0c
                case .homeAudioSetup:
                    return 0x0d
                case .developerToolsPairingRequest:
                    return 0x0e
                case .answeredCall:
                    return 0x0f
                case .endedCall:
                    return 0x10
                case .ddPing:
                    return 0x11
                case .ddPong:
                    return 0x12
                case .companionLinkProximity:
                    return 0x14
                case .remoteManagement:
                    return 0x15
                case .remoteAutofillPong:
                    return 0x16
                case .remoteDisplay:
                    return 0x17
                }
            }
            
            case unknown(type: UInt8)
            case appleTVSetup
            case mobileBackup
            case watchSetup
            case appleTVPairing
            case interntRelay
            case wifiPassword
            case iosSetup
            case repair
            case speakerSetup
            case applePay
            case homeAudioSetup
            case developerToolsPairingRequest
            case answeredCall
            case endedCall
            case ddPing
            case ddPong
            case companionLinkProximity
            case remoteManagement
            case remoteAutofillPong
            case remoteDisplay
        }
        
    }
}
