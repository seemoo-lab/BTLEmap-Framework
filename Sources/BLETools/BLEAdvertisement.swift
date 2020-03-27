//
//  AppleBLEAdvertisement.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 17.02.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

import Combine

public class BLEAdvertisment: CustomDebugStringConvertible, Identifiable, ObservableObject {
    /// The id here is the reception date of the advertisement 
    public let id: Int = Int(arc4random())
    
    /// The **MAC address** of the device that sent the advertisement to the time of sending
    @Published public private(set) var macAddress: BLEMACAddress?
    
    /// An array of all advertisement types that are contained in this advertisement
    @Published public var advertisementTypes = [AppleAdvertisementType]()
    
    /// All advertisement messages. Keys are the advertisement Type raw value and the advertisement data as value
    /// E.g. 0x0c: Data for Handoff
    public var advertisementTLV: TLV.TLVBox?
    
    /// Manufacturer Data of the advertisement
    public private(set) var manufacturerData: Data?
    
    /// True if the device marked itself as connectable
    @Published public var connectable: Bool = false
    
    @Published public var appleMfgData: [String: Any]?
    
    /// The channel over which this advertisement has been sent
    public var channel: Int?
    
    /// All RSSI values of the advetisements
    @Published public var rssi = [NSNumber]()
    /// All reception dates when this advertisement has been received
    @Published public var receptionDates = [Date]()
    
    /// Advertisements are sent out more oftern than once. This value counts how often an advertisement has been received
    @Published public var numberOfTimesReceived = 1
    
    /// The company identifier that is sent in the front of all manufacturer data
    public private(set) var companyIdentifier: Data?
    
    /// The Manufacturer of the device that sent the advertisement, according to the company identifier.
    /// Many companies do not follow that rule! E.g. iBeacons use Apple identifiers (Nuki lock), UE uses IBM identifier
    public var manufacturer: BLEManufacturer = .unknown
    
    /// Optional device name that can be part of an advertisement
    public private(set) var deviceName: String?
    
    /// Initialize an advertisement sent by Apple devices and parse it's TLV content
    /// - Parameter manufacturerData: BLE manufacturer Data that has been received
    public init(manufacturerData: Data, id: Int) throws {
        //Parse the advertisement
        
        self.manufacturerData = manufacturerData
        self.intializeManufacturer()
        if self.manufacturer == .apple {
            try self.intitializeTLVForApple()
        }
        
        self.receptionDates.append(Date())
    }
    
    
    /// Initialize an advertisement like it has been received by a device from CoreBluetooth
    /// - Parameters:
    ///   - advertisementData: Dictionary with advertisement data containing keys: `"kCBAdvDataChannel"`, `"kCBAdvDataIsConnectable"`, `"kCBAdvDataAppleMfgData"`, `"kCBAdvDataManufacturerData"`, `"kCBAdvDataTxPowerLevel"`
    ///   - rssi: RSSI in decibels
    public init(advertisementData: [String: Any], rssi: NSNumber) throws {
        
        self.channel = advertisementData["kCBAdvDataChannel"] as? Int
        self.connectable = advertisementData["kCBAdvDataIsConnectable"] as? Bool ?? false
        self.appleMfgData = advertisementData["kCBAdvDataAppleMfgData"] as? [String : Any]
        
        if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            self.manufacturerData = manufacturerData
            
            self.intializeManufacturer()
            
            if  manufacturer == .apple {
                try self.intitializeTLVForApple()
            }
        }else {
            manufacturer = .unknown
            self.advertisementTLV = nil
        }
        
        self.receptionDates.append(Date())
        self.rssi.append(rssi)
        
    }
    
    /// Intialize the BLE advertisement with the data of a relayed advertisement
    /// - Parameter relayedAdvertisement: Relayed advertisements are received by external sources, like a raspberry pi
    init(relayedAdvertisement: BLERelayedAdvertisement) throws {
        self.manufacturerData = relayedAdvertisement.manufacturerDataHex.hexadecimal
        self.rssi.append(NSNumber(value: relayedAdvertisement.rssi))
        self.deviceName = relayedAdvertisement.name
        self.macAddress = BLEMACAddress(addressString: relayedAdvertisement.macAddress, addressType: BLEMACAddress.BLEAddressType(rawValue: relayedAdvertisement.addressType) ?? .random)
        self.connectable = relayedAdvertisement.connectable
        
        self.intializeManufacturer()
        
        if  manufacturer == .apple {
            try self.intitializeTLVForApple()
        }
        
        self.receptionDates.append(Date())
    }
    
    func intializeManufacturer() {
        guard let manufacturerData = self.manufacturerData, manufacturerData.count >= 2 else {return}
        
        let companyID = manufacturerData[manufacturerData.startIndex..<manufacturerData.startIndex.advanced(by: 2)]
        self.companyIdentifier = companyID
        
        self.manufacturer = BLEManufacturer.fromCompanyId(companyID)
    }
    
    func intitializeTLVForApple() throws {
        guard let manufacturerData = self.manufacturerData, manufacturerData.count >= 2 else {return}
        
        self.advertisementTLV = try TLV.TLVBox.deserialize(fromData: manufacturerData, withSize: .tlv8)
        
        self.advertisementTLV!.getTypes().forEach { (advTypeRaw) in
            if let advType = AppleAdvertisementType(rawValue: advTypeRaw) {
                advertisementTypes.append(advType)
            }else {
                advertisementTypes.append(.unknown)
            }
        }
    }
    
    
    /// Update the advertisement with a newly received advertisment that is equal to the current advertisement
    /// - Parameters:
    ///   - advertisementData: advertisement data as received from Core Bluetooth
    ///   - rssi: current RSSI in decibels
    func update(with advertisementData: [String: Any], rssi: NSNumber) {
        self.rssi.append(rssi)
        self.receptionDates.append(Date())
        
        self.numberOfTimesReceived += 1
    }
    
    
    ///  Update the advertisement with a newly received advertisment that is equal to the current advertisement
    /// - Parameter advertisment: newly received advertisement
    func update(with advertisment: BLEAdvertisment) {
        self.rssi.append(advertisment.rssi[0])
        self.receptionDates.append(Date())
        self.numberOfTimesReceived += 1
    }
    
    
    /// Hex encoded attributed string for displaying manufacturer data sent in advertisements
    public lazy var dataAttributedString: NSAttributedString? = {
        guard let advertisementTLV = self.advertisementTLV else {
            return nil
        }
        
        let attributedString = NSMutableAttributedString()
        
        let fontSize: CGFloat = 13.0
        
        let typeAttributes: [NSAttributedString.Key : Any] = {
            #if os(macOS)
            return [
                NSAttributedString.Key.font : NSFont.monospacedSystemFont(ofSize: fontSize, weight: .heavy),
                NSAttributedString.Key.foregroundColor: NSColor(calibratedRed: 0.165, green: 0.427, blue: 0.620, alpha: 1.00)
            ] as [NSAttributedString.Key : Any]
            #else
            return [
                NSAttributedString.Key.font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .bold),
                NSAttributedString.Key.foregroundColor: UIColor(red: 0.165, green: 0.427, blue: 0.620, alpha: 1.00)
                ] as [NSAttributedString.Key : Any]
            #endif
        }()
        
        let lengthAttributes: [NSAttributedString.Key : Any] = {
            #if os(macOS)
            return [
                NSAttributedString.Key.font : NSFont.monospacedSystemFont(ofSize: fontSize, weight: .heavy),
            ] as [NSAttributedString.Key : Any]
            #else
            return [
                NSAttributedString.Key.font : UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
                ] as [NSAttributedString.Key : Any]
            #endif
        }()
        
        let dataAttributes: [NSAttributedString.Key : Any] = {
            #if os(macOS)
            return [
                NSAttributedString.Key.font : NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
                ] as [NSAttributedString.Key : Any]
            #else
            return [
                NSAttributedString.Key.font : UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
                ] as [NSAttributedString.Key : Any]
            #endif
        }()
        
        advertisementTLV.getTypes().forEach { (rawType) in
            let appleType = AppleAdvertisementType(rawValue: rawType) ?? .unknown
            
            let typeString = NSAttributedString(string: String(format: "%@ (0x%02x) ", appleType.description, UInt8(rawType)), attributes: typeAttributes)
            
            attributedString.append(typeString)
            
            if let data = advertisementTLV.getValue(forType: rawType) {
                let lengthString =  NSAttributedString(string: String(format: "%02x: ", UInt8(data.count)), attributes: lengthAttributes)
                attributedString.append(lengthString)
                
                
                let dataString: String = data.hexadecimal.separate(every: 8, with: " ")
                
                let attributedDataString = NSAttributedString(string: dataString, attributes: dataAttributes)
                
                attributedString.append(attributedDataString)
                attributedString.append(NSAttributedString(string: "\n"))
                
            }else {
                attributedString.append(NSAttributedString(string: "00", attributes: lengthAttributes))
            }
            
        }
        
        return attributedString
    }()
    
    
    public var debugDescription: String {
        let string: String = {
            self.dataAttributedString?.string ?? self.manufacturerData?.hexadecimal.separate(every: 8, with: " ") ?? "Empty"
        }()
        
        return string
    }
    
    
    public enum AppleAdvertisementType: UInt, CaseIterable {
        case handoff = 0x0c
        case wifiSettings = 0x0d
        case instantHotspot = 0x0e
        case wifiPasswordSharing = 0xf
        case nearby = 0x10
        case proximityPairing = 0x07
        case airDrop = 0x05
        case airplaySource = 0x0A
        case airplayTarget = 0x09
        case airprint = 0x03
        case heySiri = 0x08
        case homeKit = 0x06
        case magicSwitch = 0x0B // Apple watch lost connection
//        case nearbyAction = 0x0f // Change of device state e.g. joining wiFi
        
        case unknownApple = 0x12
        
        case unknown = 0x00
        
        public var description: String {
            switch self {
            case .proximityPairing:
                return "Proximity Pairing"
            case .handoff:
                return "Handoff / UC"
            case .instantHotspot:
                return "Instant Hotspot"
            case .nearby:
                return "Nearby"
            case .wifiPasswordSharing:
                return "Wi-Fi Password sharing"
            case .wifiSettings:
                return "Wi-Fi Settings"
            case .airDrop:
                return "AirDrop"
            case .airplaySource:
                return "AirPlay Source"
            case .airplayTarget:
                return "AirPlay Target"
            case .airprint:
                return "AirPrint"
            case .heySiri:
                return "Hey Siri"
            case .homeKit:
                return "HomeKit"
            case .magicSwitch:
                return "Apple Watch Pairing"
            case .unknownApple:
                return "Unknown Apple"
            case .unknown:
                return "Unknown"
            }
        }
        
    }
}
