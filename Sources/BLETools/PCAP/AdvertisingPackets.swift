//
//  AdvertisingPackets.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 11.05.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation

struct AdvDataStructure {
    var adType: ADType
    var data: Data
    var bytes: Data
    
    init(adType: ADType, data: Data) {
        //Adv Structure
        // | Length (1 byte) | AD Type (n bytes) | Data (length - n bytes) |
        
        var adStructure = Data()
        var length = UInt8(data.count) + 1
        adStructure.append(Data(bytes: &length, count: MemoryLayout.size(ofValue: length)))
        adStructure.append(adType.rawValue)
        adStructure.append(data)
        
        self.adType = adType
        self.data = data
        self.bytes = adStructure
    }
    
    static func parse(from data: Data) -> [AdvDataStructure] {
        
        var index = 0
        var structures = [AdvDataStructure]()
        while index < data.count {
            let length = data[index] - 1
            index += 1
            let adTypeVal = data[index]
            guard let adType = ADType(rawValue: adTypeVal) else {continue}
            index += 1
            let data = data.subdata(in: index..<index+Data.Index(length))
            index += Int(length)
            
            structures.append(AdvDataStructure(adType: adType, data: data))
        }
        
        return structures
    }
}


struct AdvertisingData {
    var bytes: Data
    
    init(content: [AdvDataStructure]) {
        self.bytes = content.reduce(Data(), { (result, advDataStructure) -> Data in
            return result + advDataStructure.bytes
        })
    }
}
