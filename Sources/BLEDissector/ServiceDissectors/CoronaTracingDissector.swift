//
//  File.swift
//  
//
//  Created by Alex - SEEMOO on 07.05.20.
//

import Foundation

struct CoronaTracingDissector {
    
    /// Dissect Corona tracing service
    /// - Parameters:
    ///   - data: Service data contained in the advertisement
    ///   - serviceUUID: UUID formatted string for the service
    static func dissect(data: Data, for serviceUUID: String) -> DissectedEntry {
        let range = data.startIndex...data.endIndex-1
        var coronaEntry = DissectedEntry(name: "Corona Tracing Service - \(serviceUUID)", value: data, data: data, byteRange: range, subEntries: [])
        
        //0-15 16 bytes rolling proximity identifier
        let rIdRange = data.startIndex...data.startIndex+15
        let rIdData = data[rIdRange]
        let rIdDissected = DissectedEntry(name: "Rolling proximity Identifier", value: rIdData, data: rIdData, byteRange: rIdRange, subEntries: [])
        
        //16-19 4 bytes associated **encrypted** metadata
        // the encryption of the data using CTR mode does not allow us to get further information.
        // Therefore, the version and the transmission power readings are commented out
        let metadataRange = data.startIndex+16...data.endIndex-1
        let metaData = data[metadataRange]
        var metadataDissected = DissectedEntry(name: "Associated Encrypted Metadata", value: metaData, data: metaData, byteRange: metadataRange, subEntries: [], explanatoryText: "Encrypted with AES-CTR using the Temporary Exposure Key. The key is stored on device until a person is diagnosed to be COVID-19 positive.")
        
//        // 16 1 byte version
//        let versionByte = metaData[metaData.startIndex]
//        let versionRange = metaData.startIndex...metaData.startIndex
//        let majorVersion = versionByte >> 6
//        let majorVersionDissected = DissectedEntry(name: "Major version", value: majorVersion, data: Data([versionByte]), byteRange: versionRange, subEntries: [])
//
//        let minorVersion = (versionByte << 2) >> 6
//        let minorVersionDissected = DissectedEntry(name: "Minor version", value: minorVersion, data: Data([versionByte]), byteRange: versionRange, subEntries: [])
//
//
//        //17 1 byte transmission power
//        //bitpattern ensures that a signed value will be signed
//        let transmissionPowerByte = metaData[metaData.startIndex+1]
//        let transmissionPower = Int8(bitPattern: transmissionPowerByte)
//        let transmissionPowerRange = metaData.startIndex+1...metaData.startIndex+1
//        let transmissionPowerDissected = DissectedEntry(name: "Transmission Power", value: transmissionPower, data: Data([transmissionPowerByte]), byteRange: transmissionPowerRange, subEntries: [])
//
//        //18-19 2 bytes unsused bytes
//        let reservedBytesRange = metaData.startIndex+2...metaData.endIndex-1
//
//        let reservedBytesDissected = DissectedEntry(name: "Reserved for future use", value: metaData[reservedBytesRange], data: metaData[reservedBytesRange], byteRange: reservedBytesRange, subEntries: [])
//
//        metadataDissected.subEntries = [majorVersionDissected, minorVersionDissected, transmissionPowerDissected, reservedBytesDissected]
        
        coronaEntry.subEntries = [rIdDissected, metadataDissected]
        
        return coronaEntry
    }
}
