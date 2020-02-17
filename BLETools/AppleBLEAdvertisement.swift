//
//  AppleBLEAdvertisement.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 17.02.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation

struct AppleBLEAdvertisment {
    /// An array of all advertisement types that are contained in this advertisement
    var advertisementTypes = [AdvertisementType]()
    var advertisementMessages = [UInt8: Data]()
    
    init(manufacturerData: Data) {
        //Parse the advertisement
        var parsable = manufacturerData
        
        while parsable.count > 0 {
            let advType = parsable[parsable.startIndex]
            let length = parsable[parsable.startIndex.advanced(by: 1)]
            
            if advType == 0x4c { //Apple manufacturer type
                parsable.removeFirst(2)
            }else {
                let start = parsable.startIndex.advanced(by: 2)
                let end = parsable.startIndex.advanced(by: Int(length))
                let value = parsable[start...end]
                
                advertisementMessages[advType] = value
                if let advType = AdvertisementType(rawValue: advType) {
                    advertisementTypes.append(advType)
                }else {
                    advertisementTypes.append(.unknown)
                }
            }
        }
    }
    
    
    enum AdvertisementType: UInt8 {
        case handoff = 0x0c
        case wifiSettings = 0x0d
        case instantHotspot = 0x0e
        case wifiPasswordSharing = 0xf
        case nearby = 0x10

        case unknown = 0x00
        
    }
}
