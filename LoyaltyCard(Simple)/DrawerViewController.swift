//
//  DrawerViewController.swift
//  LoyaltyCard(Simple)
//
//  Created by John Nik on 2/4/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import Firebase
import TwitterKit
import FBSDKLoginKit
import KYDrawerController
import MapKit
import GoogleSignIn
import UserNotifications

class DrawerViewController: UIViewController {
    
    var currentUserRef: FIRDatabaseReference!
    
    @IBOutlet var btnLogout: UIButton!
    @IBOutlet var btnTeam: UIButton!
    @IBOutlet var btnRedeem: UIButton!
    @IBOutlet var btnRefer: UIButton!
    @IBOutlet var btnFeedback: UIButton!
    @IBOutlet var btnNearestStroe: UIButton!
    @IBOutlet var btnProfile: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUserRef = FIRDatabase.database().reference(withPath: "users/\(FIRAuth.auth()!.currentUser!.uid)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentUserRef.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.value is NSNull { return }
            
            let userData = snapshot.value as! Dictionary<String, AnyObject>
            self.userName.text = userData["name"] as! String!
            if let imageURL = userData["photoURL"], imageURL as? String != "" {
                let url = URL(string: imageURL as! String)
                self.profileImage?.kf.setImage(with: url)
                self.profileImage?.makeCircular(color: UIColor.white)
            }
        })
    }
    
    func goNearestMap(){
        if let drawerController = self.parent as? KYDrawerController {
            drawerController.setDrawerState(.closed, animated: true)
        }
        
        self.showActionSheetForMap()
    }
    
    @IBAction func onProfile(_ sender: UIButton) {
        
//        btnProfile.imageView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        
//        UIView.animate(withDuration: 0.5,
//                       delay: 0,
//                       usingSpringWithDamping: 0.2,
//                       initialSpringVelocity: 3.0,
//                       options: .allowUserInteraction,
//                       animations: { [weak self] in
//                        self?.btnProfile.imageView?.transform = .identity
//            }, completion: { (value: Bool) in
                        if let drawerController = self.parent as? KYDrawerController {
                            drawerController.setDrawerState(.closed, animated: true)
                        }
                        self.performSegue(withIdentifier: "profile", sender: self)
//        })
        

    }
    
    @IBAction func onNearestMap(_ sender: UIButton) {
        
//        btnNearestStroe.imageView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        
//        UIView.animate(withDuration: 0.5,
//                       delay: 0,
//                       usingSpringWithDamping: 0.2,
//                       initialSpringVelocity: 3.0,
//                       options: .allowUserInteraction,
//                       animations: { [weak self] in
//                        self?.btnNearestStroe.imageView?.transform = .identity
//            }, completion: { (value: Bool) in
                self.goNearestMap()
//        })
        
    }
    
    @IBAction func onRefer(_ sender: UIButton) {
        
//        btnRefer.imageView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        
//        UIView.animate(withDuration: 0.5,
//                       delay: 0,
//                       usingSpringWithDamping: 0.2,
//                       initialSpringVelocity: 3.0,
//                       options: .allowUserInteraction,
//                       animations: { [weak self] in
//                        self?.btnRefer.imageView?.transform = .identity
//            }, completion: { (value: Bool) in
                if let drawerController = self.parent as? KYDrawerController {
                    drawerController.setDrawerState(.closed, animated: true)
                }
                self.performSegue(withIdentifier: "refer", sender: self)
//        })
        
        
    }
    
    @IBAction func onRedeem(_ sender: UIButton) {
        
//        btnRedeem.imageView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        
//        UIView.animate(withDuration: 0.5,
//                       delay: 0,
//                       usingSpringWithDamping: 0.2,
//                       initialSpringVelocity: 3.0,
//                       options: .allowUserInteraction,
//                       animations: { [weak self] in
//                        self?.btnRedeem.imageView?.transform = .identity
//            }, completion: { (value: Bool) in
                if let drawerController = self.parent as? KYDrawerController {
                    drawerController.setDrawerState(.closed, animated: true)
                }
                self.performSegue(withIdentifier: "redeem", sender: self)
//        })
        
        
    }
    
    @IBAction func onTeam(_ sender: UIButton) {
        
//        btnTeam.imageView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        
//        UIView.animate(withDuration: 0.5,
//                       delay: 0,
//                       usingSpringWithDamping: 0.2,
//                       initialSpringVelocity: 3.0,
//                       options: .allowUserInteraction,
//                       animations: { [weak self] in
//                        self?.btnTeam.imageView?.transform = .identity
//            }, completion: { (value: Bool) in
                if let drawerController = self.parent as? KYDrawerController {
                    drawerController.setDrawerState(.closed, animated: true)
                }
                self.performSegue(withIdentifier: "team", sender: self)
//        })
        
       
    }
    
    @IBAction func onFeedback(_ sender: UIButton) {
        
//        btnFeedback.imageView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        
//        UIView.animate(withDuration: 0.5,
//                       delay: 0,
//                       usingSpringWithDamping: 0.2,
//                       initialSpringVelocity: 3.0,
//                       options: .allowUserInteraction,
//                       animations: { [weak self] in
//                        self?.btnFeedback.imageView?.transform = .identity
//            }, completion: { (value: Bool) in
                if let drawerController = self.parent as? KYDrawerController {
                    drawerController.setDrawerState(.closed, animated: true)
                }
                self.performSegue(withIdentifier: "feedback", sender: self)
//        })
        
        
    }
    
    @IBAction func onLogout(_ sender: UIButton) {
        
//        btnLogout.imageView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//       let context = self
//        
//        UIView.animate(withDuration: 0.5,
//                       delay: 0,
//                       usingSpringWithDamping: 0.2,
//                       initialSpringVelocity: 3.0,
//                       options: .allowUserInteraction,
//                       animations: { [weak self] in
//                        self?.btnLogout.imageView?.transform = .identity
//            }, completion: { (value: Bool) in
                if FIRAuth.auth()!.currentUser != nil {
                    UserDefaultsManager.saveDefaults(latteStamps: 0, redeemCount: 0)
                }
                do {
                    // remove notifications
                    let center = UNUserNotificationCenter.current()
                    center.removeAllDeliveredNotifications()
                    center.removeAllPendingNotificationRequests()
                    
                    GIDSignIn.sharedInstance().signOut()
                    
                    let store = Twitter.sharedInstance().sessionStore
                    
                    if let userID = store.session()?.userID {
                        store.logOutUserID(userID)
                    }
                    
                    FBSDKProfile.setCurrent(nil)
                    FBSDKAccessToken.setCurrent(nil)
                    
                    FBSDKLoginManager().logOut()
                    try FIRAuth.auth()!.signOut()
                } catch let error as NSError {
                    self.simpleAlert(message: error.localizedDescription)
                }
                // Redirect To Signin Page
                if let viewController = storyboard?.instantiateViewController(withIdentifier: "SigninViewController") as? SigninViewController {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = viewController
                }
//        })
        
       
    }
    
    // Simple alerts with message and ok action
    func simpleAlert(message: String) {
        let alert = UIAlertController(title: "✉️", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showActionSheetForMap() {
        // get source and destination location from StoreManager
        guard let sourceLocation = StoreManager.userCurrectLocation else {
            Alert.show(controller: self, title: "Oops!!!", message: "Your current location is not available", action: {
                
            })
            return
        }
        
        // sort to get the nearest location
        let destinationLocation = StoreManager.storeLocations.sorted(by: { loc, loc2 in
            return loc.distance(from: sourceLocation) < loc2.distance(from: sourceLocation)
        })
        
        guard destinationLocation.count > 0 else { return }
        
        let lat = destinationLocation.first?.coordinate.latitude
        let long = destinationLocation.first?.coordinate.longitude
        
        
        if let drawerController = self.parent as? KYDrawerController {
            
            let actionsheet = UIAlertController(title: "🏎️💨", message: "Show the nearest store from the following apps:", preferredStyle: UIAlertControllerStyle.actionSheet)
            let googleMap = UIAlertAction(title: "Google Maps", style: UIAlertActionStyle.default, handler: {
                _ in
                
                if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                    UIApplication.shared.open(NSURL(string:
                        "comgooglemaps://?saddr=&daddr=\(lat!),\(long!)&directionsmode=driving")! as URL, options: ["": ""], completionHandler: {
                            bool in
                    })
                } else {
                    Alert.show(controller: drawerController, title: "Map not found", message: "Please install google map", action: {})
                }
                
            })
            
            let appleMap = UIAlertAction(title: "Apple Maps", style: UIAlertActionStyle.default, handler: {
                _ in
                
                let coordinate = CLLocationCoordinate2DMake(lat!, long!)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                mapItem.name = "Nearest store"
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
                
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: {
                _ in
                
            })
            
            
            actionsheet.addAction(googleMap)
            actionsheet.addAction(appleMap)
            actionsheet.addAction(cancel)
            
            drawerController.present(actionsheet, animated: true, completion: {})
        }
        
    }
}
