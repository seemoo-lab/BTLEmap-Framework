//
//  File.swift
//  
//
//  Created by Alex - SEEMOO on 07.05.20.
//

import Foundation

/// General struct for dissecting service information
public struct ServiceDissectors {
    
    /// Advertisements can contain service data that is used for sending service specific information in an advertisement
    /// - Parameters:
    ///   - data: Service data contained in the advertisement
    ///   - serviceUUID: UUID formatted string for the service
    public static func dissect(data: Data, for serviceUUID: String) -> DissectedEntry {
        switch serviceUUID {
        case "FD6F":
            return CoronaTracingDissector.dissect(data: data, for: serviceUUID)
        default:
            return standardDissector(data: data, for: serviceUUID)
        }
    }
    
    /// The standard dissector does not extract any information, since the data is unknown
    /// - Parameters:
    ///   - data: Service data contained in the advertisement
    ///   - serviceUUID: UUID formatted string for the service
    /// - Returns: A dissected entry with basic information
    static func standardDissector(data: Data, for serviceUUID: String) -> DissectedEntry {
        let range = data.startIndex...data.endIndex
        let dissectedEntry = DissectedEntry(name: "\(serviceUUID)", value: data, data: data, byteRange: range, subEntries: [])
        
        return dissectedEntry
    }
}
