//
//  AppleBLEDevice.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 17.02.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine
import AppleBLEDecoder

public class BLEDevice: NSObject, Identifiable, ObservableObject {
    public var id: String
    private var _name: String?
    public internal(set) var name: String? {
        get {
            if let n = _name {
                return n
            }
            
            return self.peripheral?.name
        }
        set(v) {
            self._name = v
        }
    }
    @Published public private (set) var advertisements = [BLEAdvertisment]()
    
    @Published public private(set) var services = Set<BLEService>()
    
    @Published public internal(set) var isActive: Bool = false
        
    public internal(set) var peripheral: CBPeripheral?
    
    /// The UUID of the peripheral
    public var uuid: UUID {return peripheral?.identifier ?? UUID()}
    
    public private(set) var macAddress: BLEMACAddress?
    
    /// The manufacturer of this device. Mostly taken from advertisement
    public private(set) var manufacturer: BLEManufacturer {
        didSet {
            if self.manufacturer == .seemoo {
                self.deviceType = .seemoo 
            }
        }
    }
    
    /// Device type can be retrieved from device information or advertisement data
    @Published public internal(set) var deviceType: DeviceType = .other
    /// Model number string received from device information service
    @Published public internal(set) var modelNumber: String? {
        // Set the device type to the according model number
        didSet {
            guard let modelNumber = self.modelNumber else {return}
            
            switch modelNumber {
            case let s where s.lowercased().contains("macbook"):
                self.deviceType = .macBook
                
            case let s where s.lowercased().contains("imac"):
                self.deviceType = .iMac
                
            case let s where s.lowercased().contains("iphone"):
                self.deviceType = .iPhone
                
            case let s where s.lowercased().contains("ipad"):
                self.deviceType = .iPad
                
            case let s where s.lowercased().contains("ipod"):
                self.deviceType = .iPod
            
            case let s where s.lowercased().contains("airpods"):
                self.deviceType = .AirPods
                
            case let s where s.lowercased().contains("watch"):
                self.deviceType = .AppleWatch
                
            default:
                self.deviceType = .other
            }
            
            if self.deviceType != .other && self.manufacturer == .unknown {
                self.manufacturer = .apple
            }
        }
    }
    
    
    /// Last RSSI value that has been received
    @Published public var lastRSSI: Float = -100
    
    
//    public var lastRSSI: NSNumber {
//        return self.advertisements.first?.rssi.last ?? NSNumber(value: -100)
//    }
    
    /// True if the device marks itself as connectable
    public var connectable: Bool {
        return self.advertisements.last(where: {$0.connectable}) != nil
    }
    
    /// The last time when this device has sent an advertisement
    public private(set) var lastUpdate: Date = Date()
    
    /// Subject to which can be subscribed to receive every new advertisement individually after it has been added to the device.
    public let newAdvertisementSubject = PassthroughSubject<BLEAdvertisment, Never>()
    
    /// If available the current os version will be set. Is a string like: iOS 13 or macOS
    @Published public private(set) var osVersion: String?
    
    /// If available the state of the wifi setting will be set
    @Published public private(set) var wiFiOn: Bool?
    
    
    /// A CSV file string that contains all advertisements
    public var  advertisementCSV: String {
        self.convertAdvertisementsToCSV()
    }
    
    internal var activityTimer: Timer?
    
    init(peripheral: CBPeripheral, and advertisement: BLEAdvertisment) {
        
        self.peripheral = peripheral
        self._name = peripheral.name
        self.id = peripheral.identifier.uuidString
        self.manufacturer = advertisement.manufacturer
        super.init()
        self.advertisements.append(advertisement)
        self.detectOSVersion(from: advertisement)
        self.lastRSSI = advertisement.rssi.last?.floatValue ?? -100.0
        
    }
    
    /// Initializer for using other inputsources than CoreBluetooth. This needs a **MAC address** in the advertisement
    /// - Parameter advertisement: BLE Advertisement
    /// - Throws:Error if no **MAC address** is passed in the advertisement
    init(with advertisement: BLEAdvertisment) throws {
//        self._name =
        guard let macAddress = advertisement.macAddress else {
            throw Error.noMacAddress
        }
        self.id = macAddress.addressString
        self.macAddress = macAddress
        self.manufacturer = advertisement.manufacturer
        super.init()
        self.advertisements.append(advertisement)
        self.detectOSVersion(from: advertisement)
        self.lastRSSI = advertisement.rssi.last?.floatValue ?? -100.0
        self._name = advertisement.deviceName
    }
    
    public static func == (lhs: BLEDevice, rhs: BLEDevice) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Add a received advertisement to the device
    /// - Parameter advertisement: received BLE advertisement
    func add(advertisement: BLEAdvertisment) {
        // Check if that advertisement has been received before
        if let matching = self.advertisements.first(where: {$0.manufacturerData == advertisement.manufacturerData}) {
            matching.update(with: advertisement)
        }else {
            self.advertisements.append(advertisement)
        }
        
        self.lastUpdate = advertisement.receptionDates.last!
        
        self.detectOSVersion(from: advertisement)
        if let rssi = advertisement.rssi.last?.floatValue {
            self.lastRSSI = rssi
        }
        
        self.isActive = true
        self.activityTimer?.invalidate()
        self.activityTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (_) in
            self.isActive = false
        }
    }
    
    func addServices(services: [BLEService]) {
        self.services = Set(services)
        
    }
    
    func updateService(service: BLEService) {
        if service.uuid == CBServiceUUIDs.deviceInformation.uuid,
            let modelNumber = service.characteristics.first(where: {$0.uuid == CBCharacteristicsUUIDs.modelNumber.uuid}){
            self.modelNumber = modelNumber.value?.stringUTF8
        }
        self.services.update(with: service)
    }
    
    private func detectOSVersion(from advertisement: BLEAdvertisment) {
        let nearbyInt = BLEAdvertisment.AppleAdvertisementType.nearby.rawValue
        if let nearby = advertisement.advertisementTLV?.getValue(forType: nearbyInt),
            let description = try? AppleBLEDecoding.decoder(forType: UInt8(nearbyInt)).decode(nearby),
            let wifiState = description["wiFiState"] as? AppleBLEDecoding.NearbyDecoder.DeviceFlags {
            
            switch wifiState {
            case .iOS10:
                self.osVersion = "iOS 10"
            case .iOS11:
                self.osVersion = "iOS 11"
            case .iOS12OrIPadOS13WiFiOn:
                if self.modelNumber?.lowercased().contains("ipad") == true {
                    self.osVersion = "iPadOS 13"
                }else {
                    self.osVersion = "iOS 12"
                }
                
                self.wiFiOn = true
            case .iOS12WiFiOn:
                if self.modelNumber?.lowercased().contains("mac") == true {
                    self.osVersion = "macOS"
                }else {
                    self.osVersion = "iOS 12"
                }
                
                self.wiFiOn = true
            case .iOS12WiFiOff:
                if self.modelNumber?.lowercased().contains("mac") == true {
                    self.osVersion = "macOS"
                }else {
                    self.osVersion = "iOS 12"
                }
                
                self.wiFiOn = false
            case .iOS12OrMacOSWifiOn:
                if self.modelNumber?.lowercased().contains("mac") == true {
                    self.osVersion = "macOS"
                }else {
                    self.osVersion = "iOS 12"
                }
                
                self.wiFiOn = true
            case .iOS13WiFiOn:
                self.osVersion = "iOS 13"
                self.wiFiOn = true
            case .iOS13WiFiOff:
                self.osVersion = "iOS 13"
                self.wiFiOn = false
            case .iOS13WifiOn2:
                self.osVersion = "iOS 13"
                self.wiFiOn = true
            case .macOSWiFiUnknown:
                self.osVersion = "macOS"
            case .macOSWiFiOn:
                self.osVersion = "macOS"
                self.wiFiOn = true
            case .watchWiFiUnknown:
                self.osVersion = "watchOS"
            case .unknown:
                break
            }
        }
    }

    
    public override var debugDescription: String {
        return(
        """
        \(self.uuid.uuidString)
        \t \(String(describing: self.name))
        \t \(self.advertisements.count) advertisements
        """)
    }
    
    func convertAdvertisementsToCSV() -> String {
        var csv = ""
        //Header
        csv += "Manufacturer data; TLV; Description"
        
        //Add hex encoded content
        let advertisementStrings = advertisements.compactMap { advertisement -> String in
            // Manufacturer data hex
            let mData = (advertisement.manufacturerData?.hexadecimal ?? "no data")
            //Formatted TLV (if it's not containing TLVs  the data will be omitted)
            let tlvString = advertisement.advertisementTLV.flatMap { tlvBox -> String  in
                tlvBox.tlvs.map { (tlv) -> String in
                    String(format: "%02x ", tlv.type) + String(format: "%02x ", tlv.length) + tlv.value.hexadecimal.separate(every: 8, with: " ")
                }.joined(separator: ", ")
                } ?? "no data"
            
            // Description for all contained TLV types
            let descriptionDicts = advertisement.advertisementTLV.flatMap { (tlvBox) -> [String] in
                // Map all TLVs to a string describing their content
                tlvBox.tlvs.map { (tlv) -> String in
                    
                    guard tlv.type != 0x4c else {return "Apple BLE"}
                    
                    let typeString = BLEAdvertisment.AppleAdvertisementType(rawValue: tlv.type)?.description ?? "Unknown type"
                    
                    let descriptionString = ((try? AppleBLEDecoding.decoder(forType: UInt8(tlv.type)).decode(tlv.value)))?.map({($0.0, $0.1)})
                        .compactMap({ (key, value) -> String in
                            if let data = value as? Data {
                                return "\(key): \t\(data.hexadecimal.separate(every: 8, with: " ")) \t"
                            }
                            
                            if let array = value as? [Any] {
                                return "\(key): \t \(array.map{String(describing: $0)}) \t"
                            }
                            
                            return "\(key):\t\(value),\t"
                            
                        }) ?? ["unknown type"]
                    
                    return typeString + "\t: " + descriptionString.joined(separator: " ")
                }
                }?.joined(separator: ",\t") ?? "no data"
            
            return mData + ";" + tlvString + ";" + descriptionDicts
        }
        csv += "\n"
        csv += advertisementStrings.joined(separator: "\n")
        return csv
    }
    
//    public override func hash(into hasher: inout Hasher) {
//        return hasher.combine(id)
//    }

    public enum DeviceType {
        case iPhone
        case macBook
        case iMac
        case iPad
        case iPod
        case AirPods
        case Pencil
        case AppleWatch
        case appleEmbedded
        case seemoo
        case other
        
        public var string: String {
            switch self {
            case .AirPods:
                return "AirPods"
            case .appleEmbedded:
                return "Embedded"
            case .iMac:
                return "iMac"
            case .AppleWatch:
                return "Apple Watch"
            case .iPad: return "iPad"
            case .iPod: return "iPod"
            case .iPhone: return "iPhone"
            case .macBook: return "MacBook"
            case .other:
                return "BluetoothDevice"
            case .Pencil: return "Pencil"
            case .seemoo: return "seemoo"
            }
        }
    }
    
    public enum Error: Swift.Error {
        case noMacAddress
    }
}

extension BLEDevice: CBPeripheralDelegate {
    
}
