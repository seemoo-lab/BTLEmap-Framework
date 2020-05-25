//
//  File.swift
//  
//
//  Created by Alex - SEEMOO on 07.05.20.
//

import Foundation

public struct DissectedEntry {
    /// A descriptive name
    public let name: String
    /// Any dissected value
    public let value: Any
    /// The data that has been used for dissection
    public let data: Data
    /// The range from its superset that was used to for the data entry
    public let byteRange: ClosedRange<Data.Index>
    /// Several optional sub entries if the dissection of this data can be split up to multiple other entries
    public var subEntries: [DissectedEntry]
    
    /// Optional explanatory text. Used for giving further information 
    public let explanatoryText: String?
    
    public var valueDescription: String {
        if let data = value as? Data {
            return data.hexadecimal.separate(every: 2, with: " ")
        }
        
        if let array = value as? [Any] {
            return array.map{String(describing: $0)}.joined(separator: ", ")
        }
        
        return String(describing: value)
    }
    
    
    /// Create a new dissected entry
    /// - Parameters:
    ///   - name: Name of the entry. Descriptive
    ///   - value: The dissected value. If nil the data will be used
    ///   - data: The dissected data part
    ///   - byteRange: Range in which this data is part of
    ///   - subEntries: Several potential sub entries
    ///   - explanatoryText: If further explanation is needed this can be placed here .
    init(name: String, value: Any?, data: Data, byteRange: ClosedRange<Data.Index>, subEntries: [DissectedEntry], explanatoryText: String?=nil) {
        self.name = name
        if let v = value  {
            self.value = v
        }else {
            self.value = data
        }
        
        self.data = data
        self.byteRange = byteRange
        self.subEntries = subEntries
        self.explanatoryText = explanatoryText
    }
}
