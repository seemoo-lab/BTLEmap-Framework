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
    
    /// An array of all advertisement types that are contained in this advertisement
    @Published public var advertisementTypes = [AppleAdvertisementType]()
    
    /// All advertisement messages. Keys are the advertisement Type raw value and the advertisement data as value
    /// E.g. 0x0c: Data for Handoff
    public var advertisementTLV: TLV.TLVBox?
    internal private(set) var manufacturerData: Data?
    
    public var manufacturer: BLEManufacturer
    
    @Published public var connectable: Bool = false
    
    @Published public var appleMfgData: [String: Any]?
    
    public var channel: Int?
    
    @Published public var rssi = [NSNumber]()
    @Published public var receptionDates = [Date]()
    
    /// Advertisements are sent out more oftern than once. This value counts how often an advertisement has been received
    @Published public var numberOfTimesReceived = 1
    
    /// Initialize an advertisement sent by Apple devices and parse it's TLV content
    /// - Parameter manufacturerData: BLE manufacturer Data that has been received
    public init(manufacturerData: Data, id: Int) throws {
        //Parse the advertisement
        self.advertisementTLV = try TLV.TLVBox.deserialize(fromData: manufacturerData, withSize: .tlv8)
        
        let manufacturerInt = manufacturerData[0]
        self.manufacturer = BLEManufacturer(rawValue: manufacturerInt) ?? .unknown
        self.manufacturerData = manufacturerData
        
        self.advertisementTLV!.getTypes().forEach { (advTypeRaw) in
            if let advType = AppleAdvertisementType(rawValue: advTypeRaw) {
                advertisementTypes.append(advType)
            }else {
                advertisementTypes.append(.unknown)
            }
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
            let manufacturerInt = manufacturerData[0]
            self.manufacturer = BLEManufacturer(rawValue: manufacturerInt) ?? .unknown
            self.manufacturerData = manufacturerData
            
            if  manufacturer == .apple {
                
                self.advertisementTLV = try TLV.TLVBox.deserialize(fromData: manufacturerData, withSize: .tlv8)
                
                self.advertisementTLV!.getTypes().forEach { (advTypeRaw) in
                    if let advType = AppleAdvertisementType(rawValue: advTypeRaw) {
                        advertisementTypes.append(advType)
                    }else {
                        advertisementTypes.append(.unknown)
                    }
                }
            }
        }else {
            manufacturer = .unknown
            self.advertisementTLV = nil
        }
        
        self.receptionDates.append(Date())
        self.rssi.append(rssi)
        
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
    public lazy var dataAttributedString: NSAttributedString = {
        guard let advertisementTLV = self.advertisementTLV else {
            return NSAttributedString(string: "Empty")
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
        return(
        """
        \(self.dataAttributedString.string)
        """
        )
    }
    
    
    public enum AppleAdvertisementType: UInt {
        case handoff = 0x0c
        case wifiSettings = 0x0d
        case instantHotspot = 0x0e
        case wifiPasswordSharing = 0xf
        case nearby = 0x10
        case airpodsOrPencil = 0x07
        case apple = 0x4c
        
        case unknown = 0x00
        
        var description: String {
            switch self {
            case .airpodsOrPencil:
                return "AirPodsOrPencil"
            case .handoff:
                return "Handoff / UC"
            case .instantHotspot:
                return "Instant Hotspot"
            case .nearby:
                return "Nearby"
            case .wifiPasswordSharing:
                return "Wi-Fi Password sharing"
            case .wifiSettings:
                return "Wi-Fi Settings open"
            case .apple:
                return "Apple"
            case .unknown:
                return "Unknown"
            }
        }
        
    }
}
