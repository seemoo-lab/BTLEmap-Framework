//
//  NearbyDecoder].swift
//  Apple-BLE-Decoder
//
//  Created by Alex - SEEMOO on 09.03.20.
//

import Foundation

public extension AppleBLEDecoding {
    struct NearbyDecoder: AppleBLEDecoder {
        public var decodableType: UInt8 {
            return 0x10
        }
        
        public func decode(_ data: Data) throws -> [String : DecodedEntry] {
            var i = data.startIndex
            var describingDict = [String: DecodedEntry]()
            guard data.count >= 2 else {throw Error.incorrectLength}
            
            //Flags & action code 1 byte 1
            let flagsRange = (UInt(1)...UInt(1))
            
            let flags = data[i]
            let statusFlags = flags >> 4
            describingDict["statusFlags"] = DecodedEntry(value: StatusFlags.match(with: statusFlags), byteRange: flagsRange)
            let actionCode = (flags << 4) >> 4
            let actionCodeDecoded = ActionCode(rawValue: actionCode) ?? ActionCode.activityLevelUnknown
            describingDict["actionCode"] = DecodedEntry(value: actionCodeDecoded, byteRange: flagsRange)
            i = i.advanced(by: 1)
            
            // wifiState 1 byte 2
            let iOSDependent = data[i]
            let wifiFlagRange = UInt(2)...UInt(2)
            let wifiFlags = DeviceFlags(rawValue: iOSDependent) ?? DeviceFlags.unknown
            describingDict["wiFiState"] = DecodedEntry(value: wifiFlags, byteRange: wifiFlagRange)
            describingDict["wiFiStateFlag"] = DecodedEntry(value: iOSDependent, byteRange: wifiFlagRange)
            i += 1
            
            if data.count >= i+3 {
                //Authentication tag 3 bytes. 3...5
                let authTag = data[i..<i+3]
                describingDict["authTag"] = DecodedEntry(value:  authTag, byteRange:UInt(i.distance(to: data.startIndex))...UInt(i.distance(to: data.startIndex)+3))
                i += 3
            }
            
            //Additional not revered data
            
            if data.count > i+1 {
                let range = UInt(i.distance(to: data.startIndex))...UInt(i.distance(to: data.endIndex))
                let missingData = data[i..<data.endIndex]
                describingDict["notParsed"] = DecodedEntry(value:  missingData, byteRange: range)
            }
            
            
            return describingDict
        }
        
        
        public enum StatusFlags: UInt8, CaseIterable {
            case primaryICloudAccountDevice = 0x01
            case unknown = 0x02
            case airDropReceivingOn = 0x04
            case unused = 0x08
            
            static func match(with flagInt: UInt8) -> [Self] {
                var flags = [Self]()
                for c in self.allCases {
                    if flagInt & c.rawValue != 0 {
                        flags.append(c)
                    }
                }
                
                return flags
            }
        }
        
        public enum ActionCode: UInt8, CaseIterable {
            case activityLevelUnknown = 0x00
            case activityReportingDisabled = 0x01
            case idleUser = 0x03
            case audioPlayingWhileScreenLocked = 0x05
            case activeUserScreenOn = 0x07
            case screenOnVideoPlayinh = 0x09
            case watchOnWristAndUnlocked = 0xA
            case recentUserInteraction = 0x0B
            case userDrivingVehicle = 0x0D
            case phoneOrFacetimeCall = 0x0E
            
        }
        
        public enum DeviceFlags: UInt8, CaseIterable {
            case iOS10 = 0x00
            case iOS11 = 0x10
            case iOS12OrIPadOS13WiFiOn = 0x0c
            case iOS12WiFiOn = 0x18
//            case iOS12OrMacOSWifiOff = 0x18
            
            case iOS12WiFiOff = 0x01
            case iOS12OrMacOSWifiOn = 0x1c
            case iOS13WiFiOn = 0x1e
            case iOS13WiFiOff = 0x1a
            case iOS13WifiOn2 = 0x04
            case macOSWiFiUnknown = 0x09
            case macOSWiFiOn = 0x14
            case watchWiFiUnknown = 0x98
            case unknown = 0xff
            
//            static func match(with flagInt: UInt8) -> [Self] {
//                var flags = [Self]()
//                for c in self.allCases {
//                    if flagInt & c.rawValue != 0 {
//                        flags.append(c)
//                    }
//                }
//
//                return flags
//            }
        }
        
    }
}
