//
//  File.swift
//  
//
//  Created by Alex - SEEMOO on 10.07.20.
//

import Foundation

public struct MicrosoftDissector: DataDissector {
    public static func dissect(data: Data) -> [DissectedEntry] {
        //Parsing Connected devices platform https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-cdp/77b446d0-8cea-4821-ad21-fabdf4d9a569
        var entries = [DissectedEntry]()
        
        //Needs to be 24 bytes
        guard data.count == 24 else {return [] }
        
        var i = data.startIndex
        let scenarioType = data[i]
        i+=1
        //Needs to be set to 1
        guard scenarioType == 1 else {
            return []
        }
        
        var microsoftConnectedDevices = DissectedEntry(name: "Microsoft Connected Devices Platform", value: nil, data: data, byteRange: data.startIndex...data.endIndex-1, subEntries: [])
        
        let versionAndDevice = data[i]
        let version = versionAndDevice >> 6
        microsoftConnectedDevices.subEntries.append(DissectedEntry(name: "Version", value: version, data: Data([version]), byteRange: i...i, subEntries: []))
        
        let deviceTypeByte = (versionAndDevice << 2) >> 2
        let deviceType = DeviceType(rawValue: deviceTypeByte)
        microsoftConnectedDevices.subEntries.append(DissectedEntry(name: "Device Type", value: deviceType ?? deviceTypeByte, data: Data([deviceTypeByte]), byteRange: i...i, subEntries: []))
        i+=1
        
        let versionAndFlags = data[i]
        microsoftConnectedDevices.subEntries.append(DissectedEntry(name: "Version and Flags", value: versionAndFlags, data: Data([versionAndFlags]), byteRange: i...i, subEntries: []))
        i+=1
        
        let reserved = data[i]
        microsoftConnectedDevices.subEntries.append(DissectedEntry(name: "Reserved Byte", value: reserved, data: Data([reserved]), byteRange: i...i, subEntries: []))
        i+=1
        
        let salt = data[i...i+3]
        microsoftConnectedDevices.subEntries.append(DissectedEntry(name: "Salt", value: salt, data: salt, byteRange: i...i+3, subEntries: []))
        i+=4
        
        let deviceHash = data[i...i+15]
        microsoftConnectedDevices.subEntries.append(DissectedEntry(name: "Device Hash", value: deviceHash, data: deviceHash, byteRange: i...i+15, subEntries: []))
        i+=16
        
        entries.append(microsoftConnectedDevices)
        
        return entries
    }
    
    enum DeviceType: UInt8 {
        case xboxOne = 0x1
        case iPhone = 6
        case iPad = 7
        case android = 8
        case windowsDesktop = 9
        case windowsPhone = 11
        case linux = 12
        case windowsIOT = 13
        case surfaceHub = 14
    }
}
