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

public struct AppleBLEAdvertisment: CustomDebugStringConvertible {
    /// An array of all advertisement types that are contained in this advertisement
    public var advertisementTypes = [AdvertisementType]()
    
    /// All advertisement messages. Keys are the advertisement Type raw value and the advertisement data as value
    /// E.g. 0x0c: Data for Handoff
    public var advertisementTLV: TLV.TLVBox
    
    
    /// Initialize an advertisement sent by Apple devices and parse it's TLV content
    /// - Parameter manufacturerData: BLE manufacturer Data that has been received
    public init(manufacturerData: Data) throws {
        //Parse the advertisement
        self.advertisementTLV = try TLV.TLVBox.deserialize(fromData: manufacturerData, withSize: .tlv8)
        
        self.advertisementTLV.getTypes().forEach { (advTypeRaw) in
            if let advType = AdvertisementType(rawValue: advTypeRaw) {
                advertisementTypes.append(advType)
            }else {
                advertisementTypes.append(.unknown)
            }
        }
    }
    
    
    /// Hex encoded attributed string for displaying manufacturer data sent in advertisements
    public var dataAttributedString: NSAttributedString {
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
            let typeString = NSAttributedString(string: String(format: "0x%02x ", UInt8(rawType)), attributes: typeAttributes)
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
    }
    
    public var debugDescription: String {
        return(
        """
        \(self.dataAttributedString.string)
        """
        )
    }
    
    
    public enum AdvertisementType: UInt {
        case handoff = 0x0c
        case wifiSettings = 0x0d
        case instantHotspot = 0x0e
        case wifiPasswordSharing = 0xf
        case nearby = 0x10

        case unknown = 0x00
        
    }
}
