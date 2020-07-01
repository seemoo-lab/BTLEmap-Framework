//
//  File.swift
//  
//
//  Created by Alex - SEEMOO on 01.07.20.
//

import Foundation

enum AppleAdvertisementType: UInt, CaseIterable {
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
        
        case offlineFinding = 0x12
        
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
            case .offlineFinding:
                return "Offline Finding"
            case .unknown:
                return "Unknown"
            }
        }
        
    }
