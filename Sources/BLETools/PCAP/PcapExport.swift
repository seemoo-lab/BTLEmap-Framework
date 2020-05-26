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
        var pcapPackets =  advertisements.flatMap { advertisement in
            self.advertisementToPcapPacket(advertisement)
        }
        
        //Sort by date
        pcapPackets.sort { (lfs, rfs) -> Bool in
            lfs.0 < rfs.0
        }
        
        let packetsData = pcapPackets.reduce(Data(), {$0 + $1.1})
        
        return pcapHeader.bytes + packetsData
    }
    
    
    // Structure defined in: https://www.bluetooth.com/specifications/bluetooth-core-specification/
    //
    // Core Specification Supplement (CSS)
    //
    static func advertisementToPcapPacket(_ advertisement: BLEAdvertisment) -> [(Date, Data)]  {
        var advertisementParts = [AdvDataStructure]()
        
        // Manufacturer Data
        
        if let manufacturerData = advertisement.manufacturerData {
            advertisementParts.append( AdvDataStructure(adType: .manufacturerData, data: manufacturerData) )
        }
        
        // TX Power Level
        
        if let txPower = advertisement.txPowerLevels.last {
            var txPower8 = Int8(txPower)
            let txPowerData = Data(bytes: &txPower8, count: MemoryLayout.size(ofValue: txPower8))
            advertisementParts.append(AdvDataStructure(adType: .txPowerLevel, data: txPowerData))
        }
        
        // Device name
        
        if let deviceName = advertisement.deviceName,
            let nameData = deviceName.data(using: .ascii) {
            advertisementParts.append(AdvDataStructure(adType: .completeLocalName, data: nameData))
        }
        
        // Services
        
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
                advertisementParts.append(AdvDataStructure(adType: .completeServiceUUIDs32Bit, data: serviceUUIDs32Bit.reduce(Data(), +)))
            }
            
            if serviceUUIDs128Bit.count > 0 {
                advertisementParts.append(AdvDataStructure(adType: .completeServiceUUIDs128Bit, data: serviceUUIDs128Bit.reduce(Data(), +)))
            }
        }
        
        //Service Data
        
        if let serviceData = advertisement.serviceData {
            for (serviceUUID, data) in serviceData {
                var adType: ADType
                switch serviceUUID.data.count {
                case 2:
                    adType = .serviceData16BitUUID
                case 4:
                    adType = .serviceData32BitUUID
                case 16:
                    adType = .serviceData128BitUUID
                default:
                    continue
                }
                
                //Create the data for the PDU
                let pduData = serviceUUID.data.reversed() + data
                let dataStructure = AdvDataStructure(adType: adType, data: pduData)
                //Add to the parts
                advertisementParts.append(dataStructure)
            }
        }
        
        // Create PDU
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
        
        // The packet might be received multiple times such that we need to generate multiple pcap entries for one BLEAdvertisement
    
        let macAddress = advertisement.macAddress?.addressData ?? HCI_EventAdvertisementResponse.uuidToMacAddress(uuid: advertisement.peripheralUUID ?? UUID())
        
        
        //Create PCAP packets
        
        var pcapPackets = Array<(Date, Data)>.init()
        for (idx, date) in advertisement.receptionDates.enumerated() {
            
            let rssi = idx < advertisement.rssi.count ?  advertisement.rssi[idx] : advertisement.rssi.last!
            
            let hciEvent = HCI_EventAdvertisementResponse(eventType: eventType, addressType: addressType, address: macAddress, data: advertisementData, rssi: rssi.int8Value)
            
            let uartPacket = UART_HCI_Packet(hciPacketType: .event, hciPacket: hciEvent.bytes)
            
            let packetHeader = PcapPacketHeader(timestampSeconds: UInt32(date.timeIntervalSince1970), timestampMicroseconds: 0, packetLength: UInt32(uartPacket.bytes.count), originalPacketLength: UInt32(uartPacket.bytes.count))
            
            pcapPackets.append((date, (packetHeader.bytes + uartPacket.bytes)))
        }

        return pcapPackets
    }
}
