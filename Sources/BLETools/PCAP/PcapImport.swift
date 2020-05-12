//
//  PcapImport.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 12.05.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct PcapImport {
    
    public static func from(data: Data) throws -> [BLEAdvertisment] {
        //Parse general pcap header
        guard data.count > 40 else {throw PcapImportError.wrongFormat(description: "Too short")}
        let generalHeader = try GeneralPcapHeader(from: data.subdata(in: 0..<24))
        
        var index = 24
        var advertisements = [BLEAdvertisment]()
        
        //Parse the pcap packets
        while index < data.count {
            let packetHeader = try PcapPacketHeader(from: data.subdata(in: index..<index+16))
            index += 16
            //Read packet data
            let packetData = data.subdata(in: index..<index+Int(packetHeader.packetLength))
            index += Int(packetHeader.packetLength)
            
            if let advertisement = try self.parseAdvertisement(from: packetData, packetHeader: packetHeader, generalHeader: generalHeader) {
                advertisements.append(advertisement)
            }
        }
        
        return advertisements
    }
    
    static func parseAdvertisement(from packetData: Data, packetHeader: PcapPacketHeader, generalHeader: GeneralPcapHeader) throws -> BLEAdvertisment? {
        // Parse the packet data
        let uartPacketType = packetData[0]
        //only HCI Events supported
        guard UART_HCI_Packet.HCI_PacketType(rawValue: uartPacketType) == .event else {return nil}
        
        let hciPacket = try HCI_EventAdvertisementResponse(from: packetData.subdata(in: 1..<packetData.endIndex))
        let advStructures = AdvDataStructure.parse(from: hciPacket.data)
        
        //Get manufacturer data
        let manufacturerData: Data? = advStructures.first(where: {$0.adType == .manufacturerData})?.data

        //Get TX value
        let txValue: Int8?
        if let advData = advStructures.first(where: {$0.adType == .txPowerLevel}) {
            txValue = Int8(bitPattern: advData.data[0])
        }else {
            txValue = nil
        }
        
        //Get the device name
        let deviceName: String?
        if let advData = advStructures.first(where: {$0.adType == .completeLocalName}) {
            deviceName = String(data: advData.data, encoding: .utf8)
        }
        else if let advData = advStructures.first(where: {$0.adType == .shortenedLocalName}) {
            deviceName = String(data: advData.data, encoding: .utf8)
        }else {
            deviceName = nil
        }
        
        //Get the array of service uuids
        var services = [CBUUID]()
        
        if let advData = advStructures.first(where: {$0.adType == .completeServiceUUIDs16Bit}) {
            let serviceData = advData.data
            let serviceSize = 2
            var index = 0
            while index + serviceSize <= serviceData.count {
                let uuid = serviceData.subdata(in: index..<index+serviceSize)
                services.append(CBUUID(data: uuid))
                index += serviceSize
            }
        }
        
        if let advData = advStructures.first(where: {$0.adType == .completeServiceUUIDs32Bit}) {
            let serviceData = advData.data
            let serviceSize = 4
            var index = 0
            while index + serviceSize <= serviceData.count {
                let uuid = serviceData.subdata(in: index..<index+serviceSize)
                services.append(CBUUID(data: uuid))
                index += serviceSize
            }
        }
        
        if let advData = advStructures.first(where: {$0.adType == .completeServiceUUIDs128Bit}) {
            let serviceData = advData.data
            let serviceSize = 16
            var index = 0
            while index + serviceSize <= serviceData.count {
                let uuid = serviceData.subdata(in: index..<index+serviceSize)
                services.append(CBUUID(data: uuid))
                index += serviceSize
            }
        }
        
        //Currently not supported more
        //Create the advertisement
        let macAddress = BLEMACAddress(addressData: hciPacket.address, addressTypeInt: Int(hciPacket.addressType.rawValue))
        let timestamp = packetHeader.timestampSeconds + generalHeader.timeZone
        
        let packetDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        let advertisement = BLEAdvertisment(macAddress: macAddress, receptionDate: packetDate, services: services, serviceData: nil, txPowerLevel: txValue, deviceName: deviceName, manufacturerData: manufacturerData, rssi: hciPacket.rssi)
        
        return advertisement
    }

}

public enum PcapImportError: Error {
    case wrongFormat(description: String)
    case wrongEndianess
    case wrongVersion
}
