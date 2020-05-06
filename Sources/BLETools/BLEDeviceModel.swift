//
//  BLEDeviceModel.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 23.04.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation

public struct BLEDeviceModel {
    public let modelName: String
    public var deviceType: DeviceType

    public var modelDescription: String {
        return BLEDeviceModel.modelNameToDescription(self.modelName)
    }

    public init(_ modelName: String) {
        self.modelName = modelName
        
        switch modelName {
        case let s where s.lowercased().contains("macbook"):
            self.deviceType = .macBook
            
        case let s where s.lowercased().contains("imac"):
            self.deviceType = .iMac
            
        case let s where s.lowercased().contains("mac"):
            self.deviceType = .Mac
            
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
    }
    
    //MARK:- DeviceType
    public enum DeviceType {
        case iPhone
        case macBook
        case iMac
        case Mac
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
            case .Mac:
                return "Mac"
            }
        }
    }

    //MARK:- Model Name to description
    public static func modelNameToDescription(_ modelName: String) -> String {
        switch modelName {
        case "iPod5,1": return "iPod touch (5th generation)"
        case "iPod7,1": return "iPod touch (6th generation)"
        case "iPod9,1": return "iPod touch (7th generation)"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
        case "iPhone4,1": return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2": return "iPhone 5s"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone8,4": return "iPhone SE"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad (3rd generation)"
        case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad (4th generation)"
        case "iPad6,11", "iPad6,12": return "iPad (5th generation)"
        case "iPad7,5", "iPad7,6": return "iPad (6th generation)"
        case "iPad7,11", "iPad7,12": return "iPad (7th generation)"
        case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
        case "iPad5,3", "iPad5,4": return "iPad Air 2"
        case "iPad11,4", "iPad11,5": return "iPad Air (3rd generation)"
        case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad mini"
        case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad mini 3"
        case "iPad5,1", "iPad5,2": return "iPad mini 4"
        case "iPad11,1", "iPad11,2": return "iPad mini (5th generation)"
        case "iPad6,3", "iPad6,4": return "iPad Pro (9.7-inch)"
        case "iPad6,7", "iPad6,8": return "iPad Pro (12.9-inch)"
        case "iPad7,1", "iPad7,2": return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad7,3", "iPad7,4": return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro (11-inch)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":
            return "iPad Pro (12.9-inch) (3rd generation)"
        case "AppleTV5,3": return "Apple TV"
        case "AppleTV6,2": return "Apple TV 4K"
        case "AudioAccessory1,1": return "HomePod"
        //Watch
        case "Watch1,1": return "Apple Watch 38mm"
        case "Watch1,2": return "Apple Watch 42mm"
        case "Watch2,6": return "Apple Watch Series 1 38mm"
        case "Watch2,7": return "Apple Watch Series 1 42mm"
        case "Watch2,3": return "Apple Watch Series 2 38mm"
        case "Watch2,4": return "Apple Watch Series 2 42mm"
        case "Watch3,1": return "Apple Watch Series 3 38mm (GPS+Cellular)"
        case "Watch3,2": return "Apple Watch Series 3 42mm (GPS+Cellular)"
        case "Watch3,3": return "Apple Watch Series 3 38mm (GPS)"
        case "Watch3,4": return "Apple Watch Series 3 42mm (GPS)"
        case "Watch4,1": return "Apple Watch Series 4 40mm (GPS)"
        case "Watch4,2": return "Apple Watch Series 4 44mm (GPS)"
        case "Watch4,3": return "Apple Watch Series 4 40mm (GPS+Cellular)"
        case "Watch4,4": return "Apple Watch Series 4 44mm (GPS+Cellular)"
        case "Watch5,1": return "Apple Watch Series 5 40mm (GPS)"
        case "Watch5,2": return "Apple Watch Series 5 44mm (GPS)"
        case "Watch5,3": return "Apple Watch Series 5 40mm (GPS+Cellular)"
        case "Watch5,4": return "Apple Watch Series 5 44mm (GPS+Cellular)"
        //MacBook
        case "MacBook1,1": return "MacBook"
        case "MacBook2,1": return "MacBook Late 2006"
        case "MacBook3,1": return "MacBook 13-inch, Late 2007"
        case "MacBook4,1": return "MacBook 14-inch, Early 2008"
        case "MacBook5,1": return "MacBook 13-inch Aluminium, Late 2008"
        case "MacBook5,2": return "MacBook 13-inch, Mid 2009"
        case "MacBook6,1": return "MacBook 13-inch, Late 2009"
        case "MacBook7,1": return "MacBook 13-inch, Mid 2010"
        case "MacBook8,1": return "MacBook retina 12-inch, Early 2015"
        case "MacBook9,1": return "MacBook retina 12-inch, Early 2016"
        case "MacBook10,1": return "MacBook retina 12-inch, Early 2017"

        case "MacBookAir1,1": return "MacBook Air, Early 2008"
        case "MacBookAir2,1": return "MacBook Air, Late 2008/Mid 2009"
        case "MacBookAir3,1": return "MacBook Air 11-inch, Late 2010"
        case "MacBookAir3,2": return "MacBook Air 13-inch, Late 2010"
        case "MacBookAir4,1": return "MacBook Air 11-inch, Mid 2011"
        case "MacBookAir4,2": return "MacBook Air 13-inch, Mid 2011"
        case "MacBookAir5,1": return "MacBook Air 11-inch, Mid 2012"
        case "MacBookAir5,2": return "MacBook Air 13-inch, Mid 2012"
        case "MacBookAir6,1": return "MacBook Air 11-inch, Mid 2013/Early 2014"
        case "MacBookAir6,2": return "MacBook Air 13-inch, Mid 2013/Early 2014"
        case "MacBookAir7,1": return "MacBook Air 11-inch, Early 2015"
        case "MacBookAir7,2": return "MacBook Air 13-inch, Early 2015/Mid 2017"
        case "MacBookAir8,1": return "MacBook Air retina 13-inch, Mid 2018"
        case "MacBookAir8,2": return "MacBook Air retina 13-inch, Mid 2019"

        case "MacBookPro8,3": return "MacBook Pro 17-inch, Early 2011/Late 2011"
        case "MacBookPro8,1": return "MacBook Pro 13-inch, Late 2011"
        case "MacBookPro8,2": return "MacBook Pro 15-inch, Late 2011"
        case "MacBookPro9,2": return "MacBook Pro 13-inch, Mid 2012"
        case "MacBookPro9,1": return "MacBook Pro 15-inch, Mid 2012"
        case "MacBookPro10,1": return "MacBook Pro retina 15-inch, Mid 2012/Early 2013"
        case "MacBookPro10,2": return "MacBook Pro retina 13-inch, Late 2012/Early 2013"
        case "MacBookPro11,1": return "MacBook Pro retina 15-inch, Late 2013/Mid 2014"
        case "MacBookPro11,2": return "MacBook Pro retina 13-inch, Late 2013/Mid 2014"
        case "MacBookPro11,3": return "MacBook Pro retina 15-inch, Mid 2014"
        case "MacBookPro12,1": return "MacBook Pro retina 13-inch, Early 2015"
        case "MacBookPro11,4": return "MacBook Pro retina 15-inch, Mid 2015"
        case "MacBookPro13,1": return "MacBook Pro retina 13-inch, Late 2016, Two Thunderbolt 3 Ports"
        case "MacBookPro13,2": return "MacBook Pro retina 13-inch, Late 2016, Four Thunderbolt 3 Ports"
        case "MacBookPro13,3": return "MacBook Pro retina 15-inch, Late 2016"
        case "MacBookPro14,1": return "MacBook Pro retina 13-inch, Mid 2017, Two Thunderbolt 3 Ports"
        case "MacBookPro14,2": return "MacBook Pro retina 13-inch, Mid 2017, Four Thunderbolt 3 Ports"
        case "MacBookPro14,3": return "MacBook Pro retina 15-inch, Mid 2017"
        case "MacBookPro15,2":
            return "MacBook Pro retina 13-inch, Mid 2018/Mid 2019, Four Thunderbolt 3 Ports"
        case "MacBookPro15,1": return "MacBook Pro retina 15-inch, Mid 2018/Mid 2019"
        case "MacBookPro15,3": return "MacBook Pro retuna 15-inch, Mid 2019"
        case "MacBookPro15,4": return "MacBook Pro 13-inch, Mid 2019, Two Thunderbolt 3 Ports"

        //iMac
        case "iMac12,1": return "iMac 21.5-inch, Mid 2011/Late 2011"
        case "iMac12,2": return "iMac 27-inch, Mid 2011"
        case "iMac13,1": return "iMac 21.5-inch, Late 2012"
        case "iMac13,2": return "iMac 27-inch, Late 2012/Early 2013"
        case "iMac14,1": return "iMac 21.5-inch, Late 2013"
        case "iMac14,3": return "iMac 21.5-inch, Late 2013"
        case "iMac14,2": return "iMac 27-inch, Late 2013"
        case "iMac14,4": return "iMac 21.5-inch, Mid 2014"
        case "iMac15,1": return "iMac retina 5K 27-inch, Late 2014/Mid 2015"
        case "iMac16,1": return "iMac 21.5-inch, Late 2015"
        case "iMac16,2": return "iMac retina 4K 21.5-inch, Late 2015"
        case "iMac17,1": return "iMac retina 5K 27-inch, Late 2015"
        case "iMac18,1": return "iMac 21.5-inch, Mid 2017"
        case "iMac18,2": return "iMac retina 4K 21.5-inch, Mid 2017"
        case "iMac18,3": return "iMac retina 5K 27-inch, Mid 2017"
        case "iMac19,2": return "iMac retina 4K 21.5-inch, Early 2019"
        case "iMac19,1": return "iMac retina 5K 27-inch, Early 2019"

        case "iMacPro1,1": return "iMac Pro, Late 2017"

        //Mac mini
        case "Macmini4,1": return "Mac mini, Mid 2010"
        case "Macmini5,1": return "Mac mini, Mid 2011"
        case "Macmini5,3": return "Mac mini Server, Mid 2011"
        case "Macmini6,1": return "Mac mini, Late 2012"
        case "Macmini6,2": return "Mac mini Server, Late 2012"
        case "Macmini7,1": return "Mac mini, Late 2014"
        case "Macmini8,1": return "Mac mini, Late 2018"

        default: return modelName
        }
    }
    
    
}
