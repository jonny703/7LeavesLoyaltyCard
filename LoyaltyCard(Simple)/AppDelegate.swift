//
//  AppDelegate.swift
//  7Leaves Card
//
//  Created by John Nik on 12/17/16.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Fabric
import TwitterCore
import TwitterKit
import CoreData
import CoreLocation
import IQKeyboardManagerSwift
import KYDrawerController
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FirebaseDynamicLinks
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var center: UNUserNotificationCenter?
    let customURLScheme = "com.JasonMcCoy.7LeavesCard"
    let locationManager = CLLocationManager()
    var selectedShortcutItem:UIApplicationShortcutItem?     //Using saved shorcut item selected
    
    override init() {
        super.init()
        
        // Use Firebase library to configure APIs
        FIROptions.default().deepLinkURLScheme = customURLScheme
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        RemoteConfig().initialize()
        
        let _ = RCValues.sharedInstance
        Twitter.sharedInstance().start(withConsumerKey: "I4pH4vNNFfRcfiAhCH6xDa3p1", consumerSecret: "H7KogpW7Gnalc7MtHxfCxjJ7fXXvZfUkT690Ns8oygbgETMwHD")
        Fabric.with([Twitter.self])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.sharedManager().enable = true
        
        // init google signin
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //add shortcut item action
        
        
        // if uninstalled logout the user
        let userDefaults = UserDefaults.standard
        let isSignedIn = userDefaults.bool(forKey: "isSignedIn")
        let loginVC = storyboard.instantiateViewController(withIdentifier: "SigninViewController") as! SigninViewController
        let signupVC = storyboard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        
        if !isSignedIn {
            do {
                try FIRAuth.auth()?.signOut()
            }catch {
                self.window?.rootViewController = loginVC
            }
            self.window?.rootViewController = signupVC
        } else if FIRAuth.auth()!.currentUser != nil {
            
            self.checkUserAgainstDatabase(completion: {
                success, error in
                
                if success == true {
                    //drawerController.mainViewController = mainViewController
                    //drawerController.drawerViewController = drawerViewController
                    //self.window?.rootViewController = drawerController
                } else {
                    self.window?.rootViewController = loginVC
                    self.forceLogout()
                }
                
            })
            
        } else {
            self.window?.rootViewController = loginVC
        }
        
        
        self.window?.rootViewController = loginVC
        
        // Override point for customization after application launch.
        center = UNUserNotificationCenter.current()
        center?.delegate = self
        return true
        //return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func checkUserAgainstDatabase(completion: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        guard let currentUser = FIRAuth.auth()?.currentUser else { return }
        
        let usersRef = FIRDatabase.database().reference(withPath: "users")
        let currentUserRef = usersRef.child(currentUser.uid)
        currentUserRef.observe(.value, with: {
            snapshot in
            
            if snapshot.value is NSNull {
                completion(false, nil)
            } else {
                completion(true, nil)
            }
            
        })
    }
    
    
    // Facebook Delegate
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    
        let handle = FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL!, sourceApplication: sourceApplication, annotation: annotation) || GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
        if let dynamicLink = FIRDynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url) {
            if let url = dynamicLink.url {
                self.handleDynamicLink(linkURL: url)
            }
            return true
        }
        return handle
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return self.application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
            //            return GIDSignIn.sharedInstance().handle(url,
//                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
//                                                     annotation: [:])
//                || FBSDKApplicationDelegate.sharedInstance().application(application, open: url, options: options) || application(application, open: url, sourceApplication: nil, annotation: [:])
    }
    
    func forceLogout() {
        if FIRAuth.auth()!.currentUser != nil {
            UserDefaultsManager.saveDefaults(latteStamps: 0, redeemCount: 0)
        }
        do {
            
            GIDSignIn.sharedInstance().signOut()
            
            let store = Twitter.sharedInstance().sessionStore
            
            if let userID = store.session()?.userID {
                store.logOutUserID(userID)
            }
            
            FBSDKLoginManager().logOut()
            try FIRAuth.auth()!.signOut()
            
            
        } catch _ as NSError {
            
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "SigninViewController") as? SigninViewController {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = viewController
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        guard let dynamicLinks = FIRDynamicLinks.dynamicLinks() else {
            return false
        }
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            if let url = dynamiclink?.url {
                self.handleDynamicLink(linkURL: url)
            }
        }
        return handled
    }
    
    private func handleDynamicLink(linkURL: URL) {
        let link = linkURL.absoluteString.components(separatedBy: "/")
        if link.count >= 3 {
            let shareCodeValue = link[3].components(separatedBy: "=")
            if shareCodeValue.count >= 2 {
                let code = shareCodeValue[1]
                debugPrint("code is ", code)
                UserDefaults.standard.setValue(code, forKey: SHARE_CODE_KEY)
                if let drawer = self.window?.rootViewController as? KYDrawerController,
                    let mainVC = drawer.mainViewController as? ViewController {
                    if let _ = drawer.presentedViewController {
                        drawer.dismiss(animated: false, completion: {
                            mainVC.redeemSavedCode()
                        })
                    } else {
                        mainVC.redeemSavedCode()
                    }
                }
            }
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handledShortCutItem = handleShortcutItem(shortcutItem: shortcutItem)
        
        completionHandler(handledShortCutItem)
    }
    
    //MARK: Notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        UserDefaults.standard.setValue(true, forKey: BIRTHDAY_FREE_STAMP_KEY)
        self.handleNotification()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UserDefaults.standard.setValue(true, forKey: BIRTHDAY_FREE_STAMP_KEY)
        self.handleNotification()
    }
    
    func handleNotification() {
        UserDefaults.standard.setValue(true, forKey: BIRTHDAY_FREE_STAMP_KEY)
        if let topController = UIApplication.topViewController() {
            Alert.show(controller: topController, title: "Greetings!", message: "Happy Birthday! You got free stamp.", action: {
                
                if let drawer = self.window?.rootViewController, drawer is KYDrawerController {
                    let mainVC = (drawer as! KYDrawerController).mainViewController
                    (mainVC as! ViewController).addFreeStampForBirthday()
                }
            })
            
        }
    }
    
    //MARK: Custom
    func handleShortcutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false
        
        guard let type = ShortcutItemType(rawValue: shortcutItem.type) else {
            return false
        }
        
        if let drawer = self.window?.rootViewController, drawer is KYDrawerController, let drawerVC = (drawer as! KYDrawerController).drawerViewController as? DrawerViewController{
            let navigation = {
                switch (type) {
                case .NearestStore:
                    // Handle Nearest Store
                    drawerVC.goNearestMap()
                    handled = true
                    break
                case .ReferEarn:
                    // Handle Refer & Earn
                    drawerVC.performSegue(withIdentifier: "refer", sender: self)
                    handled = true
                    break
                case .RedeemCode:
                    // Handle Redeem code
                    drawerVC.performSegue(withIdentifier: "redeem", sender: self)
                    handled = true
                    break
                case .YourTeam:
                    // Handle Team
                    drawerVC.performSegue(withIdentifier: "team", sender: self)
                    handled = true
                    break
                }
            }
            if let _ = drawer.presentedViewController {
                drawer.dismiss(animated: false, completion: navigation)
            } else {
                navigation()
            }
        }
        return handled
    }
}/*
 func handleEvent(forRegion region: CLRegion!) {
 if isUserValidForStamp() {
 let userDefaults = UserDefaults.standard
 userDefaults.set(true, forKey: "stampRedeem")
 userDefaults.setValue(Date(), forKey: "lastRedeemDate")
 // Show an alert if application is active
 if UIApplication.shared.applicationState == .active {
 let message = note(fromRegionIdentifier: region.identifier)
 window?.rootViewController?.showAlert(withTitle: nil, message: message)
 }
 
 // Increase stamp count
 ViewController.sharedInstance.latteStamps += 1;
 ViewController.sharedInstance.updateUIOfMine()
 UserDefaultsManager.saveDefaults(latteStamps: ViewController.sharedInstance.latteStamps, redeemCount: ViewController.sharedInstance.redeemCount)
 if FIRAuth.auth()!.currentUser != nil {
 let userRef = FIRDatabase.database().reference(withPath: "users/\(FIRAuth.auth()!.currentUser!.uid)")
 userRef.child("/stampCount").setValue(ViewController.sharedInstance.latteStamps)
 }
 }
 }
 
 func note(fromRegionIdentifier identifier: String) -> String? {
 let geotifications = ViewController.sharedInstance.geotifications
 for each in geotifications {
 if each.identifier == identifier {
 return each.note
 }
 }
 return "Congrats! You got free Stamp"
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
 
 }*/

/*
 extension AppDelegate: CLLocationManagerDelegate {
 
 func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
 if region is CLCircularRegion {
 handleEvent(forRegion: region)
 }
 }
 
 func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
 if region is CLCircularRegion {
 handleEvent(forRegion: region)
 }
 }
 }
 */

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
