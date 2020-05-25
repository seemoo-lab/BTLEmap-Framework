//
//  AirPodsBLEDecoder.swift
//  Apple-BLE-Decoder
//
//  Created by Alex - SEEMOO on 06.03.20.
//

import Foundation

public extension AppleBLEDecoding {
struct AirPodsBLEDecoder: AppleBLEDecoder {
    public var decodableType: UInt8 = 0x07
    
    public func decode(_ data: Data) throws -> [String : DecodedEntry] {
        guard data.count >= 8 else {throw Error.incorrectLength}
        var describingDict = [String: DecodedEntry]()
        
        
        var sI = data.startIndex
        let fixedNumber = data[sI] //Should 0x01 for AirPods and 0x03 for Apple Pencil
        sI = sI.advanced(by: 1)
        
        guard fixedNumber == 0x01 else {throw Error.incorrectType}
        
        //2 bytes are the device model 1...2
        let deviceModel = data[sI..<sI.advanced(by: 2)]
//        describingDict["deviceModelHex"] = DecodedEntry(value:deviceModel.hexadecimal, byteRange:1...2)
        let deviceTypeModelName = DeviceType(rawValue: deviceModel.toUInt16(littleEndian: false))?.name ?? DeviceType.unknown.name
        describingDict["deviceModel"] = DecodedEntry(value: deviceTypeModelName, byteRange: 1...2)
        sI = sI.advanced(by: 2)
        
        // 1 byte status (3)
        let status = data[sI]
        describingDict["status"] = DecodedEntry(value: status, byteRange: 3...3)
        sI = sI.advanced(by: 1)
        
        // 1 byte battery level (4)
        let battery = data[sI]
        let leftBattery = (battery << 4) >> 4
        let rightBattery = battery >> 4
        
        describingDict["leftBattery"] = DecodedEntry(value: leftBattery, byteRange: 4...4)
        describingDict["rightBattery"] = DecodedEntry(value: rightBattery, byteRange: 4...4)
        sI = sI.advanced(by: 1)
        
        // 1 byte case state (5)
        let caseBatteryAndCharging = data[sI]
        describingDict["caseBattery"] = DecodedEntry(value: (caseBatteryAndCharging << 4) >> 4, byteRange: 5...5)
        describingDict["caseCharging"] = DecodedEntry(value: caseBatteryAndCharging & 0b0100_0000 > 0, byteRange: 5...5)
        describingDict["rightCharging"] = DecodedEntry(value: caseBatteryAndCharging & 0b0010_0000 > 0, byteRange: 5...5)
        describingDict["leftCharging"] = DecodedEntry(value: caseBatteryAndCharging & 0b0001_0000 > 0, byteRange: 5...5)
        sI = sI.advanced(by: 1)
        
        // 1 byte lid open counter (6)
        let lidOpenCounter = data[sI] //Maybe used for encryption?
        describingDict["lidOpenCounter"] = DecodedEntry(value: lidOpenCounter, byteRange: 6...6)
        sI = sI.advanced(by: 1)
        
        // 1 byte for device color (7)
        let deciceColorByte = data[sI]
        let deviceColor = DeviceColor(rawValue: deciceColorByte) ?? DeviceColor.unknownColor
        describingDict["deviceColor"] = DecodedEntry(value: deviceColor, byteRange: 7...7)
        sI = sI.advanced(by: 1)
        
        // Fixed Zero (8)
        let fixedZero = data[sI] //Should be 0x00
        sI = sI.advanced(by: 1)
        
        //Encrypted message until the end (9...)
        let encryptedMessage = data[sI...]
        let encryptedRange = 9...UInt(sI.distance(to: data.endIndex)+9)
            describingDict["encrypted"] = DecodedEntry(value: encryptedMessage, byteRange:encryptedRange)
        
        //TODO: Ask Jiska if we have AirPods in da house
        
        return describingDict
    }
    
    
    public enum DeviceColor: UInt8 {
        case white = 0x00
        case  black = 0x01
        case red = 0x02
        case blue = 0x03
        case pink = 0x04
        case gray = 0x05
        case silver = 0x06
        case gold = 0x07
        case roseGold = 0x08
        case spaceGray = 0x09
        case darkBlue = 0x0a
        case lightBlue = 0x0b
        case yellow = 0x0c
        case unknownColor = 0xff
    }
    
    public enum DeviceType: UInt16 {
        case AirPods = 0x0220
        //        case AirPods_2 = 0x0320
        case Powerbeats_3 = 0x0320
        //        case PowerbeatsPro =
        case BeatsX = 0x0520
        case BeatsSolo_3 = 0x0620
        case AirPods_2 = 0x0f20
        case AirPodsPro = 0x0e20
        case unknown = 0x0000
        
        var name: String {
            switch self {
            case .AirPods:
                return "AirPods Gen 1"
            case .AirPods_2:
                return "AirPods Gen 2"
            case .AirPodsPro:
                return "AirPods Pro"
            case .BeatsX:
                return "Beats X"
            case .BeatsSolo_3:
                return "Beats Solo 3"
            case .Powerbeats_3:
                return "Powerbeats 3"
            default:
                return "\(String(describing: self))"
            }
        }
    }
    }

}
