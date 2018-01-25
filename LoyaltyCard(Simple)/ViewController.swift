//
//  ViewController.swift
//  7Leaves Card
//
//  Created by John Nik on 12/17/16.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import StoreKit
import Device_swift
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation
import ObjectMapper
import Kingfisher
import TwitterKit
import KYDrawerController

class ViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var redeemStarsLblTxt: UIImageView!
    @IBOutlet weak var doneOutlet: UIButton!
    @IBOutlet weak var editOutlet: UIButton!
    @IBOutlet weak var redeemOutlet: UIButton!
    @IBOutlet var latteButtonCollection: [StampButton]?
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var redeemView: NSLayoutConstraint!
    
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    
    // MARK: Variables
    
    let verificationCodes: [VerificationCode] = verificationCodeArray
    var readerDelegate: QRCodeReaderDelegate! = QRCodeReaderDelegate()
    
    var latteStamps  = 0
    var redeemCount = 0
    var level = 0
    var isAuthorized = false
    var isLoaded     = false
    var isReferralUsed = false
    
    var currentLatitude:CLLocationDegrees?
    var currentLongitude:CLLocationDegrees?
    
    var userRef: FIRDatabaseReference! = nil
    var userRefHandle: FIRDatabaseHandle! = nil
    var storesRef: FIRDatabaseReference!
    var storesRefHandle: FIRDatabaseHandle!
    var teamsRef: FIRDatabaseReference!
    var teamsRefHandle: FIRDatabaseHandle!
    var locationAllowed = false
    var referralID: String?
    var photoURL: String?
    //var geotifications = [Geotification]()
    var stores: [Store] = []
    var teams: [Team] = []
    var cypressCoordinates: CLLocation!
    static var sharedInstance: ViewController! = nil
    
    var locationManager = CLLocationManager()
    // MARK: - Controller Methods
    
    let allTeamHandler = 111
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundImage.image = UIImage(named: "background")
        self.readerDelegate.controller = self
        ViewController.sharedInstance = self;
        self.storesRef = FIRDatabase.database().reference(withPath: "stores")
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.teamsRef = FIRDatabase.database().reference(withPath: "users/\(uid)/teams")
        }
        

        let (savedLatteStamps, savedRedeemCount) = UserDefaultsManager.loadDefaults()
        latteStamps = savedLatteStamps
        redeemCount = savedRedeemCount
        
        if checkAvailable() == true {
            print(" Nice ")
        } else {
            print(" Expired ")
        }
        
        let deviceType = UIDevice.current.deviceType
        
        switch deviceType {
            
        case .iPhone5:
            stackViewTopConstraint.constant = 140.0
            redeemView.constant = 10.0;
            self.view.layoutIfNeeded()
            
        case .iPhone5C:
            stackViewTopConstraint.constant = 140.0
            redeemView.constant = 10.0;
            self.view.layoutIfNeeded()
            
        case .iPhone5S:
            stackViewTopConstraint.constant = 140.0
            redeemView.constant = 10.0;
            self.view.layoutIfNeeded()
            
        case .iPhoneSE:
            stackViewTopConstraint.constant = 140.0
            redeemView.constant = 10.0;
            self.view.layoutIfNeeded()
            
        default: print("Check other available cases of DeviceType")
            
        }
        
        self.view.setNeedsLayout()
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "isSignedIn")
        userDefaults.set(false, forKey: "stampRedeem")
        
        getAllStores()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
//        })
        
        getAllTeams()
        self.addFreeStampForBirthday()
        
        
        // Add LocalNotification
        self.userRef = FIRDatabase.database().reference(withPath: "users/\(FIRAuth.auth()!.currentUser!.uid)")

        self.userRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.value is NSNull { return }
            let userData = snapshot.value as! Dictionary<String, AnyObject>

            let bday = userData["birthDay"] as? String ?? ""
            UserNotificationManager.setBirthdayNotification(birthday: bday)
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        
        DispatchQueue.main.async {
            let backgroundURL = URL(string: RCValues.sharedInstance.string(forKey: .background))
            self.backgroundImage.kf.setImage(with: backgroundURL)
        }
        
        let userDefaults = UserDefaults.standard
        if let lastRedeemDate = userDefaults.object(forKey: "lastRedeemDate") {
            let lastD = lastRedeemDate as! Date
            let lastDDay = Calendar.current.component(.day, from: lastD)
            let curD = Date()
            let curDDay = Calendar.current.component(.day, from: curD)
            let curDHour = Calendar.current.component(.hour, from: curD)
            let diff = curD.timeIntervalSince(lastD)
            let days = diff / 86400
            if days > 1 {
                userDefaults.set(false, forKey: "stampRedeem")
            } else if curDDay > lastDDay && curDHour > 6 {
                userDefaults.set(false, forKey: "stampRedeem")
            }
        }
        
        if isReferralUsed {
            self.isReferralUsed = false
            self.latteStamps += 1
            self.updateUIOfMine()
            UserDefaultsManager.saveDefaults(latteStamps: self.latteStamps, redeemCount: self.redeemCount)
            if FIRAuth.auth()!.currentUser != nil {
                self.userRef = FIRDatabase.database().reference(withPath: "users/\(FIRAuth.auth()!.currentUser!.uid)")
                self.userRef.child("/stampCount").setValue(self.latteStamps)
                
            }
            self.changeUIDoneEdit(state: false)
            self.isAuthorized = false
            self.redeemStarsLblTxt.isHidden = true
        } else {
            updateUserStamps()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        redeemSavedCode()
    }
    
    func fetchTeamStamps(team: Team) {
        
        let ref = FIRDatabase.database().reference(withPath: "users/\(team.key)")
        ref.observe(.value, with: {
            snapshot in
            
            if snapshot.value is NSNull {
                
            } else {
                if let dict = snapshot.value as? NSDictionary {
                    
                    let teamLatestStamp = dict["stampCount"] as! Int
                    let teamLatestRedeem = dict["redeemCount"] as! Int
                    
                    team.stampCount = teamLatestStamp
                    
                    let balance = teamLatestRedeem - team.redeemCount
                    team.redeemCount = teamLatestRedeem
                    
                    if balance > 0 {
                        self.updateRedeemCountFromteam(key: team.key, team: team, balance: balance)
                    }
                    
                    self.updateTeamInfo(key: team.key, team: team)
                }
            }
            
        })
    }
    
    // MARK: Deeplink handler
    func redeemSavedCode() {
        
        let saveCode = UserDefaults.standard.value(forKey: SHARE_CODE_KEY)
        guard let _ = saveCode else { return }
        
        UserDefaultsManager.savedCode = saveCode as! String?
        UserDefaults.standard.setValue(nil, forKey: SHARE_CODE_KEY)
        
        if let drawerController = self.parent as? KYDrawerController {
            drawerController.setDrawerState(.closed, animated: true)
            drawerController.drawerViewController?.performSegue(withIdentifier: "redeem", sender: self)
        }
    }
    
    // MARK: Actions
    
    @IBAction func onMenu(_ sender: UIButton) {
        if let drawerController = self.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    @IBAction func editTapped(_ sender: UIButton) {
        
        self.locationManager.requestWhenInUseAuthorization()
        
        // Start QRCode reader ViewContoller
        print("edit Tapped.")
        
        self.readerDelegate.showQRAlert()
        editOutlet.isHidden = true
        redeemStarsLblTxt.isHidden = true
    }
    
    // Called when pressing stamps
    @IBAction func selectAction(_ sender: UIButton) {
        latteButtonTapped(sender)
    }
    
    // Might be used when Authorizing (Not using now)
    @IBAction func doneTapped(_ sender: UIButton) {
        print("done Tapped.")
        UserDefaultsManager.saveDefaults(latteStamps: self.latteStamps, redeemCount: self.redeemCount)
        changeUIDoneEdit(state: false)
        isAuthorized = false
        updateUIOfMine()
        redeemStarsLblTxt.isHidden = true
    }
    
    // Might be used when Authorizing (Not using now)
    @IBAction func redeemTapped(_ sender: UIButton) {
        if isAuthorized == true {
            latteStamps = 0
            redeemOutlet.isHidden = true
            updateUIOfMine()
            doneTapped(doneOutlet)
        }
    }
    
    func getAllStores() {
        // Get all store locations
//        storesRef.observe(.value, with: { snapshot in
//            self.stores = [Store]()
//            for item in snapshot.children {
//                let item = item as! FIRDataSnapshot
//                if let lJson = item.value as? [String : AnyObject] {
//                    let eachStore = Mapper<Store>().map(JSON: lJson)
//                    self.stores.append(eachStore!)
//                }
//            }
//        })
        
        storesRef.observe(.value, with: { snapshot in
            self.stores = [Store]()
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                if let lJson = item.value as? [String : AnyObject] {
                    let eachStore = Mapper<Store>().map(JSON: lJson)
                    self.stores.append(eachStore!)
                }
            }
        })
        
    }
    
    func getAllTeams() {
        // Get all Team Information
        
        teamsRef.observe(.value, with: { snapshot in
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                if let lJson = item.value as? [String : AnyObject] {
                    let eachTeam = Mapper<Team>().map(JSON: lJson)
                    eachTeam?.key = item.key
                    
                    let isExisting = self.teams.filter({ $0.key == eachTeam?.key }).count > 0
                    guard isExisting == false else { continue }
                    
                    self.teams.append(eachTeam!)
                    self.fetchTeamStamps(team: eachTeam!)
                }
                //self.checkTeamRedeemCount(teams: self.teams)
            }
            
        })
    }
    
    func updateUserStamps() {
        if FIRAuth.auth()!.currentUser != nil {
            self.userRef = FIRDatabase.database().reference(withPath: "users/\(FIRAuth.auth()!.currentUser!.uid)")
            
            // Create listener and store handle
            userRef.observeSingleEvent(of: .value, with: { snapshot in
                
                if let lJson = snapshot.value as? NSDictionary {
                    if let stampCount = lJson["stampCount"] {
                        self.latteStamps = (stampCount as? Int)!
                        self.redeemCount = (lJson["redeemCount"] as? Int)!
                    }
                    self.updateUIOfMine(animated: false)
                    UserDefaultsManager.saveDefaults(latteStamps: self.latteStamps, redeemCount: self.redeemCount)
                }
            })
        } else {
            updateUIOfMine(animated: false)
        }
    }
    
    func updateTeamInfo(key: String, team: Team) {
        let ref = FIRDatabase.database().reference(withPath: "users/\(FIRAuth.auth()!.currentUser!.uid)/teams/\(key)")
        ref.child("stampCount").setValue(team.stampCount)
        ref.child("redeemCount").setValue(team.redeemCount)
    }
    
    func checkTeamRedeemCount(teams: [Team]) {
        for each in teams {
            if each.redeemCount >= 1 {
                Alert.show(controller: self, title: "", message: "Congrats! You got free stamp, because your friend \(each.name) successsfully redeemed 10 stamps.", action: {
                    self.latteStamps += 1
                    self.updateUIOfMine()
                    UserDefaultsManager.saveDefaults(latteStamps: self.latteStamps, redeemCount: self.redeemCount)
                    if FIRAuth.auth()!.currentUser != nil {
                        self.userRef = FIRDatabase.database().reference(withPath: "users/\(FIRAuth.auth()!.currentUser!.uid)")
                        self.userRef.child("/stampCount").setValue(self.latteStamps)
                    }
                    self.changeUIDoneEdit(state: false)
                    self.isAuthorized = false
                    self.redeemStarsLblTxt.isHidden = true
                })
            }
        }
    }
    
    func updateRedeemCountFromteam(key: String, team: Team, balance: Int) {
        
        Alert.show(controller: self, title: "", message: "Congrats! You got free stamp, because your friend \(team.name) successsfully redeemed 10 stamps.", action: {
            self.latteStamps += balance
            self.updateUIOfMine()
            UserDefaultsManager.saveDefaults(latteStamps: self.latteStamps, redeemCount: self.redeemCount)
            if FIRAuth.auth()!.currentUser != nil {
                self.userRef = FIRDatabase.database().reference(withPath: "users/\(FIRAuth.auth()!.currentUser!.uid)")
                self.userRef.child("/stampCount").setValue(self.latteStamps)
            }
            self.changeUIDoneEdit(state: false)
            self.isAuthorized = false
            self.redeemStarsLblTxt.isHidden = true
        })
    }
    
    func addFreeStampForBirthday() {
        
        if UserDefaults.standard.bool(forKey: BIRTHDAY_FREE_STAMP_KEY) == true {
            UserDefaults.standard.setValue(false, forKey: BIRTHDAY_FREE_STAMP_KEY)
            
            self.latteStamps += 1
            self.updateUIOfMine()
            UserDefaultsManager.saveDefaults(latteStamps: self.latteStamps, redeemCount: self.redeemCount)
            if FIRAuth.auth()!.currentUser != nil {
                self.userRef = FIRDatabase.database().reference(withPath: "users/\(FIRAuth.auth()!.currentUser!.uid)")
                self.userRef.child("/stampCount").setValue(self.latteStamps)
            }
            self.changeUIDoneEdit(state: false)
            self.isAuthorized = false
            self.redeemStarsLblTxt.isHidden = true
        }
    }
    
    // MARK: - Button Methods
    
    // Called when stamp card is pressed
    func latteButtonTapped(_ sender:UIButton) {
        
        if isAuthorized == true {
            if sender.isSelected == true {
                latteStamps = latteStamps - 1
                sender.isSelected = false
            } else {
                latteStamps = latteStamps + 1
                sender.isSelected = true
            }
        }
        
        _ = checkForRedeemable()
        Utils.checkLatteStamps(latteStamps: &latteStamps)
    }
    
    // MARK: - UI interaction functions
    
    // Changed UI from QRCode reader ViewContoller
    func changeUI(state: Bool) {
        //state = true  editOutlet.isHidden = true redeemStarsLblTxt.isHidden = false
        self.editOutlet.isHidden = state
        self.redeemStarsLblTxt.isHidden = !state
    }
    
    // Changed UI after QRCode reader ViewContoller
    func changeUIDoneEdit(state: Bool) {
        //state = true  editOutlet.isHidden = true editOutlet.isHidden = false
        editOutlet.isHidden = state
        doneOutlet.isHidden = !state
    }
    
    // Checking that not more then 10 cards are available.
    func checkForRedeemable() -> Bool {
        
        if self.latteStamps >= 10 {
            self.redeemCount += 1
            self.latteStamps = self.latteStamps - 10
            
            if FIRAuth.auth()!.currentUser != nil {
                self.userRef = FIRDatabase.database().reference(withPath: "users/\(FIRAuth.auth()!.currentUser!.uid)")
                self.userRef.child("/redeemCount").setValue(self.redeemCount)
                self.userRef.child("/stampCount").setValue(self.latteStamps)
            }
            
            self.redeemOutlet.isHidden = false
            
            if #available(iOS 10.3, *) {
                // SKStoreReviewController.requestReview()
                //SKStoreReviewController.requestReview()
                print("request review");
            } else {
                // Fallback on earlier versions
            }
            return true
        }
        
        return false
    }
    
    // Change UI when QRCode was correct and accepted
    func updateUIOfMine() {
        updateUIOfMine(animated: true)
    }
    
    func updateUIOfMine(animated: Bool) {
        var delay: Int = 0
        
        for button in latteButtonCollection! {
            button.isSelected = false
            self.level = getLevel(redeemCount: self.redeemCount)
            button.setImage(UIImage(named: "Image_level\(self.level)"), for: .normal)
            if button.tag <= latteStamps {
                button.setImage(UIImage(named: "Image_level\(self.level)full"), for: .selected)
                if !button._redeemed {
                    if !animated {
                        button.isSelected = true
                        button.setRedeemed(true)
                    }
                    else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(275 * delay), execute: {
                            Utils.playSound()
                            button.isSelected = true
                            button.setRedeemed(true)
                        })
                        delay += 1
                    }
                }
                else {
                    button.isSelected = true
                }
            }
            else {
                button.setRedeemed(false)
            }
        }
    }
    
    // MARK: - checkAvailable
    func checkAvailable() -> Bool {
        let result = Utils.checkAvailable(latteStamps: &latteStamps)
        return result
    }
    
    func getLevel(redeemCount: Int) -> Int{
        if redeemCount >= 3 {
            return 3
        } else if redeemCount >= 1 {
            return 2
        } else {
            return 1
        }
    }
    
    // Simple alerts with message and ok action
    func simpleAlert(message: String) {
        let alert = UIAlertController(title: "✉️", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func getCypressCoordinate() {
        for each in self.stores {
            if each.identifier == "Cypress" {
                self.cypressCoordinates = CLLocation.init(latitude: each.lat, longitude: each.lan)
            }
        }
    }
    
    func getCypressRadius() -> Double {
        for each in self.stores {
            if each.identifier == "Cypress" {
                return each.radius
            }
        }
        return 15.0
    }
    
    func hasNearestStore() -> Bool {
        
        guard let long = self.currentLongitude, let lat = self.currentLatitude
            else { return false }
        
        let userCoordinates = CLLocation.init(latitude: lat, longitude: long)//CLLocation.init(latitude: lat, longitude: long)
        
        for each in self.stores {
            let storeLocation = CLLocation.init(latitude: each.lat, longitude: each.lan)
            let distance = storeLocation.distance(from: userCoordinates)
            let radius = Double(each.radius)
            
            // Save store locations to StoreManager for reference
            let locations = StoreManager.storeLocations
            if !locations.contains(storeLocation) {
                StoreManager.storeLocations.append(storeLocation)
                StoreManager.stores.append(each)
            }
            
            if distance <= radius {
                return true
            }
        }
        
        return false
    }
    
    // user location check
    func isUserNearStore() -> Bool{
        if self.locationAllowed {
            return hasNearestStore()
        } else {
            let alert = UIAlertController(title: nil, message: "Your location is needed to accurately identify and verify stamps, rewards and promotions.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
                self.changeUIDoneEdit(state: false)
                self.isAuthorized = false
                self.redeemStarsLblTxt.isHidden = true
            }))
            
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
                self.changeUIDoneEdit(state: false)
                self.isAuthorized = false
                self.redeemStarsLblTxt.isHidden = true
                let settings = URL(string: UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(settings!) {
                    UIApplication.shared.open(settings!, options: [:], completionHandler: nil)
                }
            }))
            
            present(alert, animated: true, completion: nil)
            return false
        }
    }
    
    func isUserValidForStamp() -> Bool {
        // show only once per day
        let userDefaults = UserDefaults.standard
        let onceCheck = userDefaults.bool(forKey: "stampRedeem")
        let startDate = RCValues.sharedInstance.string(forKey: .startDate).getDate()
        let endDate = RCValues.sharedInstance.string(forKey: .endDate).getDate()
        let dateCheck = Date().isBetweeen(date1: startDate, date2: endDate)
        if !onceCheck && dateCheck {
            return true
        } else {
            return false
        }
    }
    
    func isUserValidForStampNew(store : Store) -> Bool {
        // show only once per day
        
        let userDefaults = UserDefaults.standard
        let onceCheck = userDefaults.bool(forKey: "stampRedeem")
        let startDate = store.startDate.getDate()
        let endDate = store.endDate.getDate()
        let dateCheck = Date().isBetweeen(date1: startDate, date2: endDate)
        if !onceCheck && dateCheck {
            return true
        } else {
            return false
        }
    }
    
    func giveFreeStamptoUser() {
        
        // sort to get the nearest location
        let sourceLocation = CLLocation(latitude: currentLatitude!, longitude: currentLongitude!)
        let stores = StoreManager.stores.sorted(by: { loc, loc2 in
            return CLLocation(latitude: loc.lat!, longitude: loc.lan!).distance(from: sourceLocation) < CLLocation(latitude: loc2.lat!, longitude: loc2.lan!).distance(from: sourceLocation)
        })
        
        if isUserNearStore() && isUserValidForStampNew(store: stores[0]) && stores.count > 0 {
            let userDefaults = UserDefaults.standard
            userDefaults.set(true, forKey: "stampRedeem")
            userDefaults.setValue(Date(), forKey: "lastRedeemDate")
            Alert.show(controller: self, title: "🎉🎉🎉", message: "And here is "+String(stores[0].freeStampCount)+" extra for the promotion.", action: {
                DispatchQueue.main.async {
                    self.latteStamps += stores[0].freeStampCount
                    self.updateUIOfMine()
                    UserDefaultsManager.saveDefaults(latteStamps: self.latteStamps, redeemCount: self.redeemCount)
                    if FIRAuth.auth()!.currentUser != nil {
                        self.userRef = FIRDatabase.database().reference(withPath: "users/\(FIRAuth.auth()!.currentUser!.uid)")
                        self.userRef.child("/stampCount").setValue(self.latteStamps)
                    }
                    self.changeUIDoneEdit(state: false)
                    self.isAuthorized = false
                    self.redeemStarsLblTxt.isHidden = true
                }
            })
        }
    }
    
    /*
     // MARK: Functions that update the model/associated views with geotification changes
     func add(geotification: Geotification) {
     geotifications.append(geotification)
     }
     
     
     // other mapview functions
     func region(withGeotification geotification: Geotification) -> CLCircularRegion {
     
     let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
     
     region.notifyOnEntry = (geotification.eventType == .onEntry)
     region.notifyOnExit = !region.notifyOnEntry
     return region
     }
     
     func startMonitoring(geotification: Geotification) {
     if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
     showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
     return
     }
     
     if CLLocationManager.authorizationStatus() != .authorizedAlways {
     let alert = UIAlertController(title: nil, message: "Your location is needed to accurately identify and verify stamps, rewards and promotions.", preferredStyle: .alert)
     
     alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: { (action: UIAlertAction!) in
     alert.dismiss(animated: true, completion: nil)
     }))
     
     alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action: UIAlertAction!) in
     alert.dismiss(animated: true, completion: nil)
     let settings = URL(string: UIApplicationOpenSettingsURLString)
     if UIApplication.shared.canOpenURL(settings!) {
     UIApplication.shared.open(settings!, options: [:], completionHandler: nil)
     }
     }))
     
     present(alert, animated: true, completion: nil)
     }
     
     let region = self.region(withGeotification: geotification)
     
     locationManager.startMonitoring(for: region)
     }
     
     func stopMonitoring(geotification: Geotification) {
     for region in locationManager.monitoredRegions {
     guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
     locationManager.stopMonitoring(for: circularRegion)
     }
     }
     */
}


// MARK: - Location Manager Delegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            self.locationAllowed = true
        } else {
            self.locationAllowed = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLatitude = manager.location?.coordinate.latitude
        self.currentLongitude = manager.location?.coordinate.longitude
        
        StoreManager.userCurrectLocation = CLLocation(latitude: self.currentLatitude!, longitude: self.currentLongitude!)
        _ = self.hasNearestStore()
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
}
