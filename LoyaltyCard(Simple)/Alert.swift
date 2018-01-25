//
//  Alert.swift
//  7Leaves Card
//
//  Created by John Nik on 1/24/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit


enum AlertMessage: String {
    case StampAdded      = "Stamp(s) Added!"
    case Redeemed        = "Redeemed!"
    case InvalidQRCode   = "Invalid QR Code! Please try again if you believe this is an error."
    case NotSupported    = "Reader not supported by the current device"
    case Error           = "Error"
    case NoBackCamera    = "This app is not authorized to use the Back Camera."
    case NotEnoughStamps = "Not enough stamps to redeem."
}

struct Alert {
    
    // MARK: - Simple
    
    // Alert for simple action with 1 button (OK)
    static func show(controller :UIViewController, title :String, message:String?, action: (() -> ())?){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertActionStyle.cancel,
                                      handler: { _ in
                                        action?()
        }))
        controller.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Alert for Setting
    
    // Alert for 2 actions with 2 buttons (Setting/Cancel)
    static func showWith2Buttons(controller :UIViewController, title :String, message:String?, actionOk: (() -> ())?, actionCancel: (() -> ())?){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Setting",
                                      style: UIAlertActionStyle.default,
                                      handler: { _ in
                                        actionOk?()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: UIAlertActionStyle.cancel,
                                      handler: { _ in
                                        actionCancel?()
        }))
        controller.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Alert for Setting
    
    // Alert textfield with 2 buttons (Authorize/Cancel) for Authorization
    static func showWithTextField(controller :UIViewController, title :String, message:String?, done: (() -> ())?, cancel: (() -> ())?){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // Added another text field, but fixed hiding password
        alertController.addTextField {
            (textField) -> Void in
            
            textField.placeholder = "Type in the super secret password"
            textField.isSecureTextEntry = true
        }
        
        let verifyAction = UIAlertAction(title: "Authorize", style: .default) {
            (verifyAction) -> Void in
            
            let textField = alertController.textFields?.first
            
            // Test for verification
            if textField!.text == verificationCodeArray.first?.code { // TO DO: Show "Success!" image or popup.
                print("Approved!")
                if let action = done {
                    action()
                }
            } else { // TO DO: Show "Failed!" image or popup.
                // Failed authorization
                print("Authorization Failed!")
                if let action = cancel {
                    action()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            (alertAction) -> Void in
            cancel?()
        }
        alertController.addTextField {
            (textField) -> Void in
        }
        
        alertController.addAction(verifyAction)
        alertController.addAction(cancelAction)
        
        controller.present(alertController, animated: true, completion: nil)
    }
}
