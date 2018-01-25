//
//  SignupViewController.swift
//  7Leaves Card
//
//  Created by John Nik on 1/30/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import FirebaseAuth
import TwitterKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import KYDrawerController
import GoogleSignIn

class SignupViewController: UIViewController {
    
    var usersRef: FIRDatabaseReference!
    var currentUserRef: FIRDatabaseReference!
    
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var fullNameError: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordError: UILabel!
    @IBOutlet weak var retypePassword: UITextField!
    @IBOutlet weak var retypePasswordError: UILabel!
    @IBOutlet weak var showorhideButton: UIButton!
    @IBOutlet weak var retypeShoworhideButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var superViewtoCenterDistance: NSLayoutConstraint!
    @IBOutlet weak var signupButton: UIButton!
    
    var invalidDomains = [String]()
    var alreadyPushed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        invalidDomains = JSONParser().invalidEmails() as! [String]
        
        usersRef = FIRDatabase.database().reference(withPath: "users")
        
        // Show view button on right view of password textfiled
        password.rightView = showorhideButton
        password.rightViewMode = UITextFieldViewMode.whileEditing
        //retypePassword.rightView = retypeShoworhideButton
        //retypePassword.rightViewMode = UITextFieldViewMode.whileEditing
        
        // Google Sign in
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        // Hide Keyboard when tapped around
        self.hideKeyboardWhenTappedAround()
        
        self.signupButton.layer.borderColor = UIColor.white.cgColor
        
        
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let user = user {
                if user.isEmailVerified || (FBSDKAccessToken.current() != nil) || (Twitter.sharedInstance().sessionStore.session() != nil) || ( GIDSignIn.sharedInstance().currentUser != nil ) {
                    
                    guard self.alreadyPushed == false else { return }
                    
                    //Push User into firebase schema
                    self.alreadyPushed = true
                    self.pushUsertoFirebase(user: user)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        // Underlines for textfileds
        fullName.underlined(color: UIColor.white, width: 1.0)
        email.underlined(color: UIColor.white, width: 1.0)
        password.underlined(color: UIColor.white, width: 1.0)
        //retypePassword.underlined(color: UIColor.white, width: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Keyboard Notification
        /*
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
         */
    }
    
    func pushUsertoFirebase(user: FIRUser) {
        currentUserRef = self.usersRef.child(user.uid)
        currentUserRef.observeSingleEvent(of: .value, with: { snapshot in
            if (!snapshot.hasChildren()) {
                let key = snapshot.key
                let index = key.index(key.startIndex, offsetBy: 8)
                if (FBSDKAccessToken.current() != nil) {
                    let profile = user.providerData[0]
                    let currentUser = [
                        "key": key,
                        "name": profile.displayName ?? "",
                        "email": profile.email ?? "",
                        "photoURL": (profile.photoURL == nil ? "" : "\(profile.photoURL!)"),
                        "gender": "",
                        "birthDay": "",
                        "referralCode": key.substring(to: index).uppercased(),
                        "stampCount" : 0,
                        "redeemCount": 0,
                        "phone":""
                        ] as [String : Any]
                    self.currentUserRef.setValue(currentUser)
                } else if (Twitter.sharedInstance().sessionStore.session() != nil) {
                    let profile = user.providerData[0]
                    let currentUser = [
                        "key": key,
                        "name": profile.displayName ?? "",
                        "email": profile.email ?? "",
                        "photoURL": (profile.photoURL == nil ? "" : "\(profile.photoURL!)"),
                        "gender": "",
                        "birthDay": "",
                        "referralCode": key.substring(to: index).uppercased(),
                        "stampCount" : 0,
                        "redeemCount": 0,
                        "phone":""
                        ] as [String : Any]
                    self.currentUserRef.setValue(currentUser)
                } else if ( GIDSignIn.sharedInstance().currentUser != nil) {
                    let profile = user.providerData[0]
                    let currentUser = [
                        "key": key,
                        "name": profile.displayName ?? "",
                        "email": profile.email ?? "",
                        "photoURL": (profile.photoURL == nil ? "" : "\(profile.photoURL!)"),
                        "gender": "",
                        "birthDay": "",
                        "referralCode": key.substring(to: index).uppercased(),
                        "stampCount" : 0,
                        "redeemCount": 0,
                        "phone":""
                        ] as [String : Any]
                    self.currentUserRef.setValue(currentUser)
                } else {
                    let currentUser = [
                        "key": key,
                        "name": user.displayName ?? "",
                        "email": user.email ?? "",
                        "photoURL": (user.photoURL == nil ? "" : "\(user.photoURL!)"),
                        "gender": "",
                        "birthDay": "",
                        "referralCode": key.substring(to: index).uppercased(),
                        "stampCount" : 0,
                        "redeemCount": 0,
                        "phone":""
                        ] as [String : Any]
                    self.currentUserRef.setValue(currentUser)
                }
            }
        })
        
        DispatchQueue.main.async {
            // Code to include navigation drawer
            let mainViewController   = self.storyboard?.instantiateViewController(withIdentifier: "homeVC")
            let drawerViewController = self.storyboard?.instantiateViewController(withIdentifier: "drawerVC")
            let drawerController     = KYDrawerController(drawerDirection: .left, drawerWidth: (UIScreen.main.bounds.size.width) * 0.75)
            drawerController.mainViewController = mainViewController
            drawerController.drawerViewController = drawerViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = drawerController
            //self.performSegue(withIdentifier: "homepage", sender: self)
        }
    }
    
    @IBAction func onShoworHidePassword(_ sender: UIButton) {
        if sender.tag == 1 {
            self.showorhideButton.setTitle("Hide", for: .normal)
            sender.tag = 2
        } else {
            self.showorhideButton.setTitle("Show", for: .normal)
            sender.tag = 1
        }
        
        self.password.isSecureTextEntry = !self.password.isSecureTextEntry
    }
    
    /*
     @IBAction func onRetypeShoworHidePassword(_ sender: UIButton) {
     if sender.tag == 1 {
     self.retypeShoworhideButton.setTitle("Hide", for: .normal)
     sender.tag = 2
     } else {
     self.retypeShoworhideButton.setTitle("Show", for: .normal)
     sender.tag = 1
     }
     
     self.retypePassword.isSecureTextEntry = !self.retypePassword.isSecureTextEntry
     }
     */
    
    @IBAction func onSignUp(_ sender: UIButton) {
        if signupValidations() {
            view.endEditing(true)
            self.activityIndicator.startAnimating()
            FIRAuth.auth()!.createUser(withEmail: email.text!, password: password.text!) { user, error in
                if error == nil {
                    
                    // Send Email Verification
                    user?.sendEmailVerification() { error in
                        if error != nil {
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                                self.simpleAlert(message: "Check Your Network Connection and try again!")
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                                let alert = UIAlertController(title: "✉️", message: "We've sent an email to \(self.email.text!) verify your address. Please click the link in that email to continue.", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                                    self.performSegue(withIdentifier: "signIn", sender: self)
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    
                    // Update Fullname
                    if let user = user {
                        let changeRequest = user.profileChangeRequest()
                        changeRequest.displayName = self.fullName.text!
                        changeRequest.commitChanges { error in
                            if let error = error {
                                self.simpleAlert(message: error.localizedDescription)
                            } else {
                                self.clearFields()
                            }
                        }
                    }
                    
                } else {
                    self.activityIndicator.stopAnimating()
                    self.simpleAlert(message: (error?.localizedDescription)!)
                }
            }
        }
    }
    
    @IBAction func onFbLogin(_ sender: UIButton) {
        
        self.activityIndicator.startAnimating()
        if FBSDKAccessToken.current() != nil {
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.simpleAlert(message: (error?.localizedDescription)!)
                    }
                }
            }
        } else {
            let fbLoginManager = FBSDKLoginManager()
            fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) -> Void in
                if(error != nil) {
                    fbLoginManager.logOut()
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.simpleAlert(message: (error?.localizedDescription)!)
                    }
                } else if (result?.isCancelled)! {
                    fbLoginManager.logOut()
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                } else {
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                        if error == nil {
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                                self.simpleAlert(message: (error?.localizedDescription)!)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func onTwitterLogin(_ sender: UIButton) {
        self.activityIndicator.startAnimating()
        let twitterLoginManager = Twitter.sharedInstance()
        twitterLoginManager.logIn(completion: {session, error in
            if (session != nil) {
                let authToken = session?.authToken
                let authTokenSecret = session?.authTokenSecret
                let credential = FIRTwitterAuthProvider.credential(withToken: authToken!, secret: authTokenSecret!)
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    if error != nil {
                        self.activityIndicator.stopAnimating()
                        self.simpleAlert(message: (error?.localizedDescription)!)
                    } else {
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
            } else {
                if error != nil {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.simpleAlert(message: (error?.localizedDescription)!)
                    }
                }
            }
        })
    }
    
    
    @IBAction func onGmailLogin( _ send: UIButton ) {
        self.activityIndicator.startAnimating()
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func onSigninButton(_ sender: UIButton) {
        view.endEditing(true)
        self.performSegue(withIdentifier: "signIn", sender: self)
    }
    
    @IBAction func passwordEditing(_ sender: UITextField) {
        passwordError.isHidden = true
        password.underlined(color: UIColor.white, width: 1.0)
    }
    
    /*
     @IBAction func onRetypePasswordEditing(_ sender: UITextField) {
     retypePasswordError.isHidden = true
     retypePassword.underlined(color: UIColor.white, width: 1.0)
     }*/
    
    @IBAction func emailEditing(_ sender: UITextField) {
        emailError.isHidden = true
        email.underlined(color: UIColor.white, width: 1.0)
    }
    
    @IBAction func fullNameEditing(_ sender: UITextField) {
        fullNameError.isHidden = true
        fullName.underlined(color: UIColor.white, width: 1.0)
    }
    
    func signupValidations() -> Bool {
        if fullName.text == "" {
            fullName.underlined(color: UIColor.white, width: 1.0)
            fullNameError.isHidden = false
            return false
        }
        if email.text == "" {
            email.underlined(color: UIColor.white, width: 1.0)
            emailError.isHidden = false
            return false
        }
        if !(email.text?.isValidEmail())! || self.isBlockedDomain() == true {
            email.underlined(color: UIColor.white, width: 1.0)
            emailError.isHidden = false
            return false
        }
        if password.text == "" {
            password.underlined(color: UIColor.white, width: 1.0)
            passwordError.isHidden = false
            return false
        }
        //        if retypePassword.text == "" {
        //            retypePassword.underlined(color: UIColor.white, width: 1.0)
        //            retypePasswordError.isHidden = false
        //            return false
        //        }
        //        if retypePassword.text != password.text {
        //            retypePassword.underlined(color: UIColor.white, width: 1.0)
        //            retypePasswordError.isHidden = false
        //            return false
        //        }
        return true
    }
    
    func isBlockedDomain() -> Bool {
        for domain in self.invalidDomains {
            debugPrint(domain)
            if self.email.text?.contains(domain) == true {
                return true
            }
        }
        return false
    }
    
    func clearFields() {
        fullName.text = ""
        email.text = ""
        password.text = ""
    }
    
    // MARK: - AutoLayout Keyboard
    /*
     func keyboardWillShow(notification: NSNotification) {
     let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
     let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
     
     self.superViewtoCenterDistance.constant = -keyboardSize.height/8
     UIView.animate(withDuration: duration, animations: {
     self.view.layoutIfNeeded()
     })
     }
     
     func keyboardWillHide(notification: NSNotification) {
     let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
     
     self.superViewtoCenterDistance.constant = 70
     UIView.animate(withDuration: duration, animations: {
     self.view.layoutIfNeeded()
     })
     }
     */
    
    // Simple alerts with message and ok action
    func simpleAlert(message: String) {
        let alert = UIAlertController(title: "✉️", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: Textfield Delegate
extension SignupViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField
        {
        case fullName:
            email.becomeFirstResponder()
            break
        case email:
            password.becomeFirstResponder()
            break
        case password:
            retypePassword.becomeFirstResponder()
            break
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}

extension SignupViewController: GIDSignInDelegate, GIDSignInUIDelegate  {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            self.activityIndicator.stopAnimating()
            self.simpleAlert(message: error.localizedDescription)
        }
        guard user != nil else { return }
 
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                self.simpleAlert(message: error.localizedDescription)
            }
        }
    }
}
