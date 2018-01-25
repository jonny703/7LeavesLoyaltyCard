//
//  UserDefaultsManager.swift
//  7Leaves Card
//
//  Created by John Nik on 1/24/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation


struct UserDefaultsManager {
    
    static var savedCode:String?
    
    //MARK: - NSUserDefaults functions
    
    static let kStampsNumber = "stampsNumber"
    static let kRedeemCount = "redeemCount"
    static let kCntStamps = "cntStamps"
    
    // Save data for latteStamps and coffeeStamps
    static func saveDefaults(latteStamps: Int, redeemCount: Int) {
        print("saved")
        let defaults = UserDefaults.standard
        let numberOfLattes = NSNumber(value: latteStamps)
        let reddemCount = NSNumber(value: redeemCount)
        defaults.setValue(numberOfLattes, forKey: kStampsNumber)
        defaults.setValue(reddemCount, forKey: kRedeemCount)
        defaults.synchronize()
    }
    
    // Upon app initialization, data is loaded for latteStamps and coffeeStamps
    static func loadDefaults() -> (Int, Int) {
        let defaults = UserDefaults.standard
        var latteStamps = 0
        var redeemCount = 0
        
        if let value = defaults.value(forKey: kStampsNumber) as? NSNumber {
            latteStamps = value.intValue
        }
        if let redeemValue = defaults.value(forKey: kRedeemCount) as? NSNumber {
            redeemCount = redeemValue.intValue
        }
        
        print("loaded stamps \(latteStamps)")
        
        return (latteStamps, redeemCount)
    }
    
    // Clear data for StampsNumber
    static func cleanStampsNumber(){
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: kStampsNumber)
        userDefault.synchronize()
    }
    
    // Clear data for CntStamps
    static func cleanCntStamps(){
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: kCntStamps)
        userDefault.synchronize()
    }
    
    // Save data for StampsNumber
    static func saveStampsNumber(value: Int) {
        let defaults = UserDefaults.standard
        let numberValue = NSNumber(value: value)
        defaults.setValue(numberValue, forKey: kStampsNumber)
        defaults.synchronize()
    }
    
    // Save data for CntStamps
    static func saveCntStamps(value: Date) {
        let defaults = UserDefaults.standard
        defaults.setValue(value, forKey: kCntStamps)
        defaults.synchronize()
    }
    
    // Get data for CntStamps
    static func getCntStamps() -> Date? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: kCntStamps) as! Date?
    }
}
