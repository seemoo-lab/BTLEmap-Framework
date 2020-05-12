//
//  PcapDefinitions.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 11.05.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation

struct PcapPacketHeader {
    var timestampSeconds: UInt32 // 4
    var timestampMicroseconds: UInt32 // 4
    var packetLength: UInt32 // 4
    var originalPacketLength: UInt32 // 4
    
    init(timestampSeconds: UInt32, timestampMicroseconds: UInt32, packetLength: UInt32, originalPacketLength: UInt32) {
        self.timestampSeconds = timestampSeconds
        self.timestampMicroseconds = timestampMicroseconds
        self.packetLength = packetLength
        self.originalPacketLength = originalPacketLength
    }
    
    init(from data: Data) throws {
        guard data.count == 16 else {throw PcapImportError.wrongFormat(description: "Too short. Missing header")}
        
        self.timestampSeconds = data.subdata(in: 0..<4).uint32
        self.timestampMicroseconds = data.subdata(in: 4..<8).uint32
        self.packetLength = data.subdata(in: 8..<12).uint32
        self.originalPacketLength = data.subdata(in: 12..<16).uint32
    }
    
    var bytes: Data {
        var bytes = Data()
        var timestampSeconds = self.timestampSeconds
        bytes.append(Data(bytes: &timestampSeconds, count: MemoryLayout.size(ofValue: timestampSeconds)))
        var timestampMicroseconds = self.timestampMicroseconds
        bytes.append(Data(bytes: &timestampMicroseconds, count: MemoryLayout.size(ofValue: timestampMicroseconds)))
        var packetLength = self.packetLength
        bytes.append(Data(bytes: &packetLength, count: MemoryLayout.size(ofValue: packetLength)))
        var originalPacketLength = self.originalPacketLength
        bytes.append(Data(bytes: &originalPacketLength, count: MemoryLayout.size(ofValue: originalPacketLength)))
        
        return bytes
    }
}

struct GeneralPcapHeader {
    var magicNumber: UInt32 = 0xA1B2C3D4 // 4 byte
    var majorVersion = UInt16(2) // 2 bytes
    var minorVersion = UInt16(4) // 2
    var timeZone = UInt32(0) // 4
    var accuracy = UInt32(0) // 4
    var snaplen = UInt32(65535) // 4
    //LINKTYPE_BLUETOOTH_HCI_H4 (HCI Commands/Events as specified by the Bluetooth Core Spec)
    var networkType = UInt32(187) // 4
    
    var isLittleEndian = true
    
    var bytes: Data {
        var bytes = Data()
        var magicNumber = self.magicNumber
        bytes.append(Data(bytes: &magicNumber, count: MemoryLayout.size(ofValue: magicNumber)))
        var majorVersion = self.majorVersion
        bytes.append(Data(bytes: &majorVersion, count: MemoryLayout.size(ofValue: majorVersion)))
        var minorVersion = self.minorVersion
        bytes.append(Data(bytes: &minorVersion, count: MemoryLayout.size(ofValue: minorVersion)))
        var timeZone = self.timeZone
        bytes.append(Data(bytes: &timeZone, count: MemoryLayout.size(ofValue: timeZone)))
        var accuracy = self.accuracy
        bytes.append(Data(bytes: &accuracy, count: MemoryLayout.size(ofValue: accuracy)))
        var snaplen = self.snaplen
        bytes.append(Data(bytes: &snaplen, count: MemoryLayout.size(ofValue: snaplen)))
        var networkType = self.networkType
        bytes.append(Data(bytes: &networkType, count: MemoryLayout.size(ofValue: networkType)))
        
        return bytes
    }
    
    init() {}
    
    init(from data: Data) throws {
        guard data.count == 24 else {throw PcapImportError.wrongFormat(description: "Too short. Missing header")}
        
        let magicNumber = data.subdata(in: 0..<4).uint32
        guard magicNumber == 0xA1B2C3D4 else {
            throw PcapImportError.wrongEndianess
        }
        
        self.majorVersion = data.subdata(in: 4..<6).uint16
        self.minorVersion = data.subdata(in: 6..<8).uint16
        
        guard majorVersion == 2 && minorVersion >= 4 else {
            throw PcapImportError.wrongVersion
        }
        
        self.timeZone = data.subdata(in: 8..<12).uint32
        self.accuracy = data.subdata(in: 12..<16).uint32
        self.snaplen = data.subdata(in: 16..<20).uint32
        self.networkType = data.subdata(in: 20..<24).uint32
        
        guard networkType == 187 else {throw PcapImportError.wrongFormat(description: "Only supports HCI logs of Network type 187")}
    }
}


