//
//  QRCodeReaderDelegate.swift
//  7Leaves Card
//
//  Created by John Nik on 12/17/16.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import FirebaseAuth
import FirebaseDatabase

class QRCodeReaderDelegate: NSObject, QRCodeReaderViewControllerDelegate {
    
    weak var controller: ViewController!
    var userRef: FIRDatabaseReference! = nil
    
    lazy var reader = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
        $0.showTorchButton = true
    })
    
    // MARK: - QRCodeReader Delegate Methods
    
    // Delegate of QRCode reader ViewContoller
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        self.controller.dismiss(animated: true) { [unowned self] in
            // Check if the QR code is valid:
            
            // 1. Redeem QR code scanned
            if result.value == redeemQRCode {
                print("Redeem scanned!")
                
                // Check the number of stamps the user has
                if self.controller.checkForRedeemable() {
                    
                    // User has redeemed enough stamps (10+)
                    Alert.show(controller: self.controller, title: "", message: AlertMessage.Redeemed.rawValue, action: {
                        DispatchQueue.main.async {
                            Utils.playSound()
                            self.controller.updateUIOfMine()
                            UserDefaultsManager.saveDefaults(latteStamps: self.controller.latteStamps, redeemCount: self.controller.redeemCount)
                            self.controller.changeUIDoneEdit(state: false)
                            self.controller.isAuthorized = false
                            self.controller.editOutlet.isHidden = false
                        }
                    })
                    return
                }
                
                // User hasn't redeemed enough stampsz
                Alert.show(controller: self.controller, title: "", message: AlertMessage.NotEnoughStamps.rawValue, action: {
                    self.controller.editOutlet.isHidden = false
                })
                return
            }
            
            // 2. Add stamp QR code scanned
            //if self.controller.verificationCodes.contains(where: result.value) {
            let resultVerification: VerificationCode = VerificationCode(code: result.value);
            debugPrint("codes ", verificationCodeArray)
            for verificationCode in verificationCodeArray {
                if( verificationCode.code == resultVerification.code) {
                    print("Approved!")
                    print(verificationCode.stamps);
                    if self.controller.isUserNearStore() {
                        
                        //Vibrate phone
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        
                        Alert.show(controller: self.controller, title: "", message: AlertMessage.StampAdded.rawValue, action: {
                            DispatchQueue.main.async {
                                for (_, verificationCode) in self.controller.verificationCodes.enumerated() {
                                    if result.value != verificationCode.code {
                                        continue
                                    }
                                    print("no of stamps:  \(self.controller.latteStamps)");
                                    print(resultVerification.stamps);
                                    self.controller.latteStamps += verificationCode.stamps;
                                    self.controller.updateUIOfMine()
                                    UserDefaultsManager.saveDefaults(latteStamps: self.controller.latteStamps, redeemCount: self.controller.redeemCount)
                                    if FIRAuth.auth()!.currentUser != nil {
                                        self.userRef = FIRDatabase.database().reference(withPath: "users/\(FIRAuth.auth()!.currentUser!.uid)")
                                        self.userRef.child("/stampCount").setValue(self.controller.latteStamps)
                                        let formatter = DateFormatter()
                                        formatter.dateStyle = .long
                                        formatter.timeStyle = .medium
                                        
                                        // let dateString = formatter.string(from: Date())
                                        // let stampData = [
                                        //     "stampCount": verificationCode.stamps,
                                        //     "time": dateString
                                        //     ] as [String : Any]
                                        //self.userRef.child("/allStamps").childByAutoId().setValue(stampData)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(verificationCode.stamps/2), execute: {
                                        self.controller.giveFreeStamptoUser()
                                    })
                                    self.controller.changeUIDoneEdit(state: false)
                                    self.controller.isAuthorized = false
                                    self.controller.redeemStarsLblTxt.isHidden = true
                                    
                                    break
                                }
                            }
                        })
                    } else {
                        Alert.show(controller: self.controller, title: "Location verification error", message: "You are not within the range permissible (15 meters) to redeem your stamp(s). Please be present inside the store.", action: {
                            self.controller.changeUIDoneEdit(state: false)
                            self.controller.isAuthorized = false
                            self.controller.redeemStarsLblTxt.isHidden = true
                        })
                    }
                    return
                }
            }
            
            // 3. Invalid QR code scanned
            Alert.show(controller: self.controller, title: "", message: AlertMessage.InvalidQRCode.rawValue, action: {
                DispatchQueue.main.async {
                    //self.controller.ScanQRCode(scannedString: "", isSuccess: false)
                    self.controller.changeUI(state: false)
                    print("Authorization Failed!")
                }
            })
        }
    }
    
    // Call when switch between front and back camera
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        if let cameraName = newCaptureDevice.device.localizedName {
            print("Switching capturing to: \(cameraName)")
        }
    }
    
    // Cancel button on QRCode reader ViewContoller
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        self.controller.dismiss(animated: true, completion: nil)
        self.controller.changeUI(state: false)
    }
    
    //MARK: - Alert set up
    
    // Show alert for Authorization
    func showAlert() {
        
        Alert.showWithTextField(controller: self.controller, title: "Password Required!", message: "Please allow the store employee to type the super secret password onto your phone please!", done: {
            
            self.controller.latteStamps = 0
            UserDefaultsManager.saveDefaults(latteStamps: self.controller.latteStamps, redeemCount: self.controller.redeemCount)
            if FIRAuth.auth()!.currentUser != nil {
                self.userRef = FIRDatabase.database().reference(withPath: "users/\(FIRAuth.auth()!.currentUser!.uid)")
                self.userRef.child("/stampCount").setValue(self.controller.latteStamps)
            }
            self.controller.updateUIOfMine()
            self.controller.changeUIDoneEdit(state: true)
            self.controller.isAuthorized = true
        }, cancel: {
            self.controller.changeUI(state: false)
        })
    }
    
    // Start QRCode reader ViewContoller
    func showQRAlert() {
        
            let result = try! QRCodeReader.supportsMetadataObjectTypes()
            if result {
                reader.modalPresentationStyle = .formSheet
                reader.delegate               = self
                
                reader.completionBlock = { (result: QRCodeReaderResult?) in
                    if let result = result {
                        print("Completion with result: \(result.value) of type \(result.metadataType)")
                    }
                }
                
                self.controller.present(reader, animated: true, completion: nil)
            }

        
    }
}
