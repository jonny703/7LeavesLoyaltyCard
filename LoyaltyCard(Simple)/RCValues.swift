//
//  RCValues.swift
//  LoyaltyCard(Simple)
//
//  Created by John Nik on 1/31/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import Firebase

enum ValueKey: String {
    case startDate
    case endDate
    case redeemStampCount
    case background
}


class RCValues {
    
    static let sharedInstance = RCValues()
    
    private init() {
        loadDefaultValues()
        fetchCloudValues()
    }
    
    func loadDefaultValues() {
        let appDefaults: [String: NSObject] = [
            ValueKey.startDate.rawValue: "2017-01-01" as NSObject,
            ValueKey.endDate.rawValue: "2017-03-01" as NSObject,
            ValueKey.redeemStampCount.rawValue: "1" as NSObject,
            ValueKey.background.rawValue: "https://firebasestorage.googleapis.com/v0/b/leaves-cafe.appspot.com/o/unspecified-5.png?alt=media&token=7712abf8-1f04-4a58-8524-b777f51e4659" as NSObject,
            ]
        FIRRemoteConfig.remoteConfig().setDefaults(appDefaults)
    }
    
    func fetchCloudValues() {
        let fetchDuration: TimeInterval = 43200
        //activateDebugMode()
        FIRRemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) { (status, error) in
            
            guard error == nil else {
                print ("Uh-oh. Got an error fetching remote values \(error)")
                return
            }
            
            FIRRemoteConfig.remoteConfig().activateFetched()
        }
    }
    
    func activateDebugMode() {
        let debugSettings = FIRRemoteConfigSettings(developerModeEnabled: true)
        FIRRemoteConfig.remoteConfig().configSettings = debugSettings!
    }
    
    func string(forKey key: ValueKey) -> String {
        return FIRRemoteConfig.remoteConfig()[key.rawValue].stringValue ?? ""
    }
    
    func intValue(forKey key: ValueKey) -> Int {
        if let numberValue = FIRRemoteConfig.remoteConfig()[key.rawValue].numberValue {
            return numberValue.intValue
        } else {
            return 0
        }
    }
}
