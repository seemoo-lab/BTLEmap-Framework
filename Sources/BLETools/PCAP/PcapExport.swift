//
//  PcapExport.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 11.05.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation

public struct PcapExport {
    
    /// Export a list of BLE advertisements to a pcap  file format. The pcap will not be saved, but returned as data
    /// - Parameter advertisements: An array of `BLEAdvertisements`
    /// - Returns: Pcap formatted data. That can be imported by Wireshark for further analysis
    public static func export(advertisements: [BLEAdvertisment]) -> Data {
        
        let pcapHeader = GeneralPcapHeader()
        
        //Generate pcap data
        let pcapPackets =  advertisements.compactMap { advertisement in
            self.advertisementToPcapPacket(advertisement)
        }
        
        let packetsData = pcapPackets.reduce(Data(), +)
        
        return pcapHeader.bytes + packetsData
    }
    
    static func advertisementToPcapPacket(_ advertisement: BLEAdvertisment) -> Data?  {
        var advertisementParts = [AdvDataStructure]()
        
        if let manufacturerData = advertisement.manufacturerData {
            advertisementParts.append( AdvDataStructure(adType: .manufacturerData, data: manufacturerData) )
        }
        
        if let txPower = advertisement.txPowerLevels.last {
            var txPower8 = Int8(txPower)
            let txPowerData = Data(bytes: &txPower8, count: MemoryLayout.size(ofValue: txPower8))
            advertisementParts.append(AdvDataStructure(adType: .txPowerLevel, data: txPowerData))
        }
        
        if let deviceName = advertisement.deviceName,
            let nameData = deviceName.data(using: .ascii) {
            advertisementParts.append(AdvDataStructure(adType: .completeLocalName, data: nameData))
        }
        
        if let services = advertisement.serviceUUIDs {
            var serviceUUIDs16Bit = [Data]()
            var serviceUUIDs32Bit = [Data]()
            var serviceUUIDs128Bit = [Data]()
            
            //We need to reverse the bytes, because of the byte order in a pcap file
            services.forEach { (uuid) in
                let data = Data(uuid.data.reversed())
                if uuid.data.count == 2 {
                    //16 bit
                    serviceUUIDs16Bit.append(data)
                }else if uuid.data.count == 4 {
                    //32 bit
                    serviceUUIDs32Bit.append(data)
                }else if uuid.data.count == 16 {
                    //128 bit
                    serviceUUIDs128Bit.append(data)
                }
            }
            
            
            if serviceUUIDs16Bit.count > 0 {
                advertisementParts.append(AdvDataStructure(adType: .completeServiceUUIDs16Bit, data: serviceUUIDs16Bit.reduce(Data(), +)))
            }
            
            if serviceUUIDs32Bit.count > 0 {
                advertisementParts.append(AdvDataStructure(adType: .completeServiceUUIDs16Bit, data: serviceUUIDs32Bit.reduce(Data(), +)))
            }
            
            if serviceUUIDs128Bit.count > 0 {
                advertisementParts.append(AdvDataStructure(adType: .completeServiceUUIDs16Bit, data: serviceUUIDs128Bit.reduce(Data(), +)))
            }
        }
        
        let timestamp: UInt32 = {
            if let timestamp = advertisement.timestamp {
                return UInt32(timestamp)
            }
            if let date = advertisement.receptionDates.last {
                return UInt32(date.timeIntervalSince1970)
            }
            
            return UInt32(Date().timeIntervalSince1970)
        }()
        
        let advertisementData = AdvertisingData(content: advertisementParts).bytes
        
        let eventType: AdvertisementType = {
            if advertisement.connectable {
                return .ADV_IND
            }
            
            return .ADV_NONCONN_IND
        }()
        
        let addressType: BLE_AddressType = {
            if advertisement.macAddress?.addressType == BLEMACAddress.BLEAddressType.public {
                return .public
            }else if advertisement.macAddress?.addressType == BLEMACAddress.BLEAddressType.random {
                return .random
            }
            
            return .random
        }()
        
        let hciPacket: HCI_EventAdvertisementResponse? = {
            
            if var macAddress = advertisement.macAddress {
                return HCI_EventAdvertisementResponse(eventType: eventType, addressType: addressType, address: macAddress.addressData, data: advertisementData, rssi: advertisement.rssi.last!.int8Value)
            }else if let peripheralUUID = advertisement.peripheralUUID {
                
                return HCI_EventAdvertisementResponse(eventType: eventType, addressType: addressType, addressUUID: peripheralUUID, data: advertisementData, rssi: advertisement.rssi.last!.int8Value)
            }
            
            return nil
            }()
    
        
        guard let hciData = hciPacket?.bytes else {return nil }
        
        let uartData = UART_HCI_Packet(hciPacketType: .event, hciPacket: hciData)
        
        let packetHeader = PcapPacketHeader(timestampSeconds: timestamp, timestampMicroseconds: 0, packetLength: UInt32(uartData.bytes.count), originalPacketLength: UInt32(uartData.bytes.count))
        
        return packetHeader.bytes + uartData.bytes
    }
}
