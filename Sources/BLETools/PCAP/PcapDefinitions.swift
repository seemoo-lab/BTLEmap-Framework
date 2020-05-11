//
//  PcapDefinitions.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 11.05.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation

struct PcapPacketHeader {
    var timestampSeconds: UInt32 = 1588951154
    var timestampMicroseconds: UInt32 = 0
    var packetLength: UInt32
    var originalPacketLength: UInt32
    
    init(timestampSeconds: UInt32, timestampMicroseconds: UInt32, packetLength: UInt32, originalPacketLength: UInt32) {
        self.timestampSeconds = timestampSeconds
        self.timestampMicroseconds = timestampMicroseconds
        self.packetLength = packetLength
        self.originalPacketLength = originalPacketLength
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
    var magicNumber: UInt32 = 0xA1B2C3D4
    var majorVersion = UInt16(2)
    var minorVersion = UInt16(4)
    var timeZone = UInt32(0)
    var accuracy = UInt32(0)
    var snaplen = UInt32(65535)
    //LINKTYPE_BLUETOOTH_HCI_H4 (HCI Commands/Events as specified by the Bluetooth Core Spec)
    var networkType = UInt32(187)
    
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
}
