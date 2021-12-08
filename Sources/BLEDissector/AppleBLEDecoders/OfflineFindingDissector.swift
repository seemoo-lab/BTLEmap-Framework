//
//  File.swift
//  
//
//  Created by Alex - SEEMOO on 01.07.20.
//

import Foundation


struct OfflineFindingDissector {
    
    enum BatteryState: UInt8 {
        case full = 0
        case medium = 1
        case low = 2
        case criticallyLow = 3
    }
    
    static func dissect(data: Data) -> DissectedEntry {
        let range = data.startIndex...data.endIndex-1
        var entry = DissectedEntry(name: "Offline Finding", value: data, data: data, byteRange: range, subEntries: [], explanatoryText: "The advertising address contains the first 5 bytes of the public key")
        
        let statusByteRange = data.startIndex...data.startIndex
        guard data.endIndex > statusByteRange.upperBound else { return entry }
        
        let statusByte = data[data.startIndex]
        // 00 00 00 00
        let batteryStateByte = statusByte << 6
        
        let batteryEntry = DissectedEntry(name: "Battery state", value: BatteryState(rawValue: batteryStateByte) ?? batteryStateByte, data: Data([batteryStateByte]), byteRange: statusByteRange, subEntries: [])
        entry.subEntries.append(batteryEntry)
        
        let statusByteEntry = DissectedEntry(name: "Status byte", value: statusByte, data: Data([statusByte]), byteRange: statusByteRange, subEntries: [batteryEntry])
        entry.subEntries.append(statusByteEntry)
        
        let publicKeyRange = data.startIndex+1...data.startIndex+22
        guard data.endIndex > publicKeyRange.upperBound else { return entry }
        let publicKeyEntry = DissectedEntry(name: "Public Key", value: data[publicKeyRange], data: data[publicKeyRange], byteRange: publicKeyRange, subEntries: [])
        entry.subEntries.append(publicKeyEntry)
        
        let publicKeyBitsRange = data.startIndex+23...data.startIndex+23
        guard data.endIndex > publicKeyBitsRange.upperBound else { return entry }
        let publicKeyBitsEntry = DissectedEntry(name: "Bits 0–1: Public key", value: data[publicKeyBitsRange], data: data[publicKeyBitsRange], byteRange: publicKeyBitsRange, subEntries: [], explanatoryText: "Bits 6–7 of byte 0 of the public key")
        entry.subEntries.append(publicKeyBitsEntry)
        
        let hintByteRange = data.startIndex+24...data.startIndex+24
        guard data.endIndex > hintByteRange.upperBound else { return entry }
        let hintEntry = DissectedEntry(name: "Hint", value: data[hintByteRange], data: data[hintByteRange], byteRange: hintByteRange, subEntries: [], explanatoryText: "Byte 5 of the Bluetooth address of the current primary key")
        entry.subEntries.append(hintEntry)
        
        
        return entry
        
    }
}
