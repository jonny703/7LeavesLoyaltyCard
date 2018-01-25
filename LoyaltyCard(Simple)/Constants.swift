//
//  Constants.swift
//  7Leaves Card
//
//  Created by John Nik on 1/24/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation

let SHARE_CODE_KEY = "share_code_key"
let BIRTHDAY_EDITED_KEY = "birthday_edit"
let BIRTHDAY_FREE_STAMP_KEY = "birthday_free_stamp"
let VERIFICATION_CODES = "verification_code"

var verificationCodeArray: [VerificationCode] = []


// Clear 10 stamps
var redeemQRCode: String = ""


//MARK: - ENUMS
enum ShortcutItemType: String{
    case NearestStore = "NearestStore"
    case ReferEarn = "ReferEarn"
    case RedeemCode = "RedeemCode"
    case YourTeam = "YourTeam"
    
    var name: String{
        switch(self){
        case .NearestStore:
            return "Nearest Store"
        case .ReferEarn:
            return "Refer & Earn"
        case .RedeemCode:
            return "Redeem Code"
        case .YourTeam:
            return "Your Team"
        }
    }
}
