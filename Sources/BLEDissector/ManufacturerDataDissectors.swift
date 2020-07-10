//
//  File.swift
//  
//
//  Created by Alex - SEEMOO on 22.05.20.
//

import Foundation

public protocol DataDissector {
    static func dissect(data: Data) -> [DissectedEntry]
}

public struct ManufacturerDataDissector {
    public static func dissect(data: Data) -> DissectedEntry {
        var manufacturerData = DissectedEntry(name: "Manufacturer Data", value: data, data: data, byteRange: data.startIndex...data.endIndex, subEntries: [], explanatoryText: nil)
        
        
        //Check if this is matches Apple's company id
        
        let companyIdData = data.subdata(in: data.startIndex..<data.startIndex+2)
        let companyID = CompanyID.fromCompanyId(companyIdData)
        if companyID == .apple {
            let appleAdvertisement = data[(data.startIndex+2)...]
            let entries = AppleMDataDissector.dissect(data: appleAdvertisement)
            manufacturerData.subEntries.append(contentsOf: entries)
        }else if companyID == .microsoft {
            let advertisement = data[(data.startIndex+2)...]
            let entries = MicrosoftDissector.dissect(data: advertisement)
            manufacturerData.subEntries.append(contentsOf: entries)
        }
        
        return manufacturerData
    }
}
