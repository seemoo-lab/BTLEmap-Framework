//
//  BLETracker.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 10.03.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
import Combine
import Apple_BLE_Decoder

/// A class that can track devices over a longer period than the reassignment of the BLE address
public class BLETracker {
    let scanner: BLEScanner
    var device: BLEDevice
    /// A struct that contains all identifiers that allow for tracking
    var identifiers: TrackingIdentifiers = TrackingIdentifiers()
    
    private var subscribers = [AnyCancellable]()
    
    public private(set) var matchedDevices: [BLEDevice]
    
    init(tracking device: BLEDevice, with scanner: BLEScanner) {
        self.scanner = scanner
        self.device = device
        self.matchedDevices = [device]
        
        let scannerSubscriber = scanner.newAdvertisementSubject.sink { (event) in
            self.receive(event: event)
        }
        self.subscribers.append(scannerSubscriber)
        
        let deviceSubscriber = device.newAdvertisementSubject.sink { (advertisement) in
            self.handle(new: advertisement)
        }
        self.subscribers.append(deviceSubscriber)
    }
    
    func receive(event: BLEScanner.BLE_Event) {
        guard event.device.id != self.device.id else {return}
        
        var identifier = TrackingIdentifiers()
        identifier.update(for: event.device)
        
        if self.identifiers.matches(identifier) {
            //It's a match !
            self.matchedDevices.append(event.device)
            self.device = event.device
            self.identifiers.update(for: event.device)
        }
    }
    
    func handle(new advertisement: BLEAdvertisment) {
        
    }
    
    func initializeTrackingIdentifiers() {
        self.identifiers.update(for: self.device)
    }
    
    
    deinit {
        subscribers.forEach{$0.cancel()}
    }
    
    struct TrackingIdentifiers {
        var handoffIV: UInt16?
        var airDropHashes: [Data]?
        var airPodModel: AppleBLEDecoding.AirPodsBLEDecoder.DeviceType?
        var nearbyActionCode: AppleBLEDecoding.NearbyDecoder.ActionCode?
        var wifiState: AppleBLEDecoding.NearbyDecoder.DeviceFlags?
        var heySiriDeviceClass: AppleBLEDecoding.HeySiriDecoder.DeviceClass?
        
        mutating func update(for device: BLEDevice) {
            let advertisements = device.advertisements.sorted { (b1, b2) -> Bool in
                       b1.receptionDates.last! < b2.receptionDates.last!
                   }
                   
                   advertisements.forEach { (advertisement) in
                       guard let tlv = advertisement.advertisementTLV else {return}
                       
                       //Nearby identifiers
                       if let description = tlv.getDescription(for: .nearby) {
                           self.nearbyActionCode = description["actionCode"] as? AppleBLEDecoding.NearbyDecoder.ActionCode
                           self.wifiState = description["wiFiState"] as? AppleBLEDecoding.NearbyDecoder.DeviceFlags
                       }
                       
                       //Contact hashes
                       if let description = tlv.getDescription(for: .airDrop) {
                           var currentHashes = self.airDropHashes ?? [Data]()
                           if let contactHashes = description["contactHashes"] as? [Data] {
                               currentHashes.append(contentsOf: contactHashes)
                               self.airDropHashes = Array(Set(currentHashes))
                           }
                       }
                       
                       //Handoff
                       if let description = tlv.getDescription(for: .handoff) {
                           self.handoffIV = description["iv"] as? UInt16
                       }
                       
                       //AirPods
                       if let description = tlv.getDescription(for: .proximityPairing) {
                           self.airPodModel = description["deviceModel"] as? AppleBLEDecoding.AirPodsBLEDecoder.DeviceType
                       }
                       
                       //Hey Siri Device class
                       if let description = tlv.getDescription(for: .heySiri) {
                           self.heySiriDeviceClass = description["deviceClass"] as? AppleBLEDecoding.HeySiriDecoder.DeviceClass
                       }
                   }
        }
        
        func matches(_ identifiers: TrackingIdentifiers) -> Bool {
            if let ownHandoff = self.handoffIV,
                let otherHandoff = identifiers.handoffIV {
                return (ownHandoff...ownHandoff+10).contains(otherHandoff)
            }
            
            return false
        }
    }
}
