//
//  ProfileViewController.swift
//  LoyaltyCard(Simple)
//
//  Created by John Nik on 2/4/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import Firebase
import BEMCheckBox
import DatePickerDialog

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var fulName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var birthday: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var isMale: BEMCheckBox!
    @IBOutlet weak var isFemale: BEMCheckBox!
    
    var isImageChanged = false
    var currentUserRef: FIRDatabaseReference!
    var cureentUserRefHandle: FIRDatabaseHandle?
    var imageStorageRef: FIRStorageReference!
    var storageRef: FIRStorageReference!
    var userUID: String!
    var group: BEMCheckBoxGroup! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentUserRef = FIRDatabase.database().reference(withPath: "users/\(FIRAuth.auth()!.currentUser!.uid)")
        self.userUID = FIRAuth.auth()!.currentUser!.uid
        self.storageRef = FIRStorage.storage().reference(forURL: "gs://leaves-cafe.appspot.com")
        self.imageStorageRef = self.storageRef.child(self.userUID + "/profilePics")
        self.updateButton.isEnabled = false
        self.updateButton.layer.borderColor = UIColor.lightGray.cgColor
        self.group = BEMCheckBoxGroup(checkBoxes: [self.isFemale, self.isMale])
        self.group.mustHaveSelection = true
        self.group.selectedCheckBox = nil
        
        group.selectedCheckBox = self.isMale
        self.isFemale.delegate = self
        self.isMale.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollview.contentInset = UIEdgeInsets.zero
        cureentUserRefHandle = currentUserRef.observe(.value, with: { snapshot in
            
            if snapshot.value is NSNull { return }
            
            let userData = snapshot.value as! Dictionary<String, AnyObject>
            self.userName.text = userData["name"] as! String!
            self.fulName.text = userData["name"] as! String!
            self.email.text = userData["email"] as? String ?? ""
            self.birthday.text = userData["birthDay"] as? String ?? ""
            self.phone.text = userData["phone"] as? String ?? ""
            self.phone.keyboardType = UIKeyboardType.phonePad

            if let gender = userData["gender"] {
                if gender as! String == "male" {
                    self.group.selectedCheckBox = self.isMale
                    self.isMale.setOn(true, animated: true)
                    self.isMale.reload()
                } else if gender as! String == "female" {
                    self.group.selectedCheckBox = self.isFemale
                    self.isFemale.setOn(true, animated: true)
                    self.isFemale.reload()
                } else {
                    self.isMale.on = userData["gender"] as? Bool ?? false
                    self.isFemale.on = userData["isFemale"] as? Bool ?? false
                }
            } else {
                self.isMale.on = userData["gender"] as? Bool ?? false
                self.isFemale.on = userData["isFemale"] as? Bool ?? false
            }
            if let imageURL = userData["photoURL"], imageURL as? String != "" {
                if !self.isImageChanged {
                    let url = URL(string: imageURL as! String)
                    self.profileImage?.kf.setImage(with: url)
                    self.profileImage?.makeCircular(color: UIColor.white)
                }
            }
        })
        
    }
    
    override func viewDidLayoutSubviews() {
        email.underlined(color: UIColor.lightGray, width: 1.0)
        fulName.underlined(color: UIColor.lightGray, width: 1.0)
        birthday.underlined(color: UIColor.lightGray, width: 1.0)
        phone.underlined(color: UIColor.lightGray, width: 1.0)
    }
    
    
    @IBAction func onChangeImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onUpdate(_ sender: UIButton) {
        self.activityIndicator.startAnimating()
        
        (UIApplication.shared.delegate as! AppDelegate).center?.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            
            if self.emailValidation() && self.fullNameValidation() && self.phoneValidation(){
                self.uploadImage()
            }
        }
        
    }
    
    func uploadImage() {
        
        // Get NSData from image
        let presentImageRef = self.imageStorageRef.child("profilePic.jpeg")
        let uploadData = UIImageJPEGRepresentation(self.profileImage.image!, 0.2)
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload image and get downloadURL
        presentImageRef.put(uploadData!, metadata: metadata) { (metadata, error) in
            if error != nil {
                self.activityIndicator.stopAnimating()
                self.simpleAlert(message: (error?.localizedDescription)!)
            } else {
                let ticketImageUrl = self.storageRef.child((metadata?.path)!).description
                let storageRef = FIRStorage.storage().reference(forURL: ticketImageUrl)
                storageRef.downloadURL { (data, error) in
                    if let error = error {
                        print("Error downloading image data: \(error)")
                        return
                    }
                    // Save into user object
                    self.currentUserRef.child("photoURL").setValue("\(data!.absoluteURL)")
                    self.updateUserInfo()
                    self.simpleAlert(message: "Profile Updated Successfully.")
                    self.disableUpdateButton()
                }
            }
        }
    }
    
    func updateUserInfo() {
        self.currentUserRef.child("name").setValue(self.fulName.text)
        self.currentUserRef.child("email").setValue(self.email.text)
        self.currentUserRef.child("phone").setValue(self.phone.text)
        if self.birthday.text != "" {
            UserNotificationManager.setBirthdayNotification(birthday: self.birthday.text!)
            self.currentUserRef.child("birthDay").setValue(self.birthday.text)
        }
        if self.isMale.on {
            self.currentUserRef.child("gender").setValue("male")
        } else if self.isFemale.on {
            self.currentUserRef.child("gender").setValue("female")
        }
    }
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func emailValidation() -> Bool {
        if email.text == "" {
            self.simpleAlert(message: "Please enter a valid email address")
            return false
        }
        if !(email.text?.isValidEmail())! {
            self.simpleAlert(message: "Please enter a valid email address")
            return false
        }
        return true
    }
    
    func fullNameValidation() -> Bool {
        if fulName.text == "" {
            self.simpleAlert(message: "Please enter your full name")
            return false
        }
        return true
    }
    
    func phoneValidation() -> Bool {
//        if phone.text == "" {
//            self.simpleAlert(message: "Please enter your phone number")
//            return false
//        }
        if !(phone.text?.isValidPhone())! {
            self.simpleAlert(message: "Please enter a valid phone number")
            return false
        }
        return true
    }
    
    @IBAction func phoneEdiiting(_ sender: Any) {
        self.enableUpdateButton()
    }
    
    @IBAction func emailEditing(_ sender: UITextField) {
        self.enableUpdateButton()
    }
    
    @IBAction func fullNameEditing(_ sender: UITextField) {
        self.enableUpdateButton()
    }
    
    @IBAction func datePickerTapped(sender: AnyObject) {
        if self.birthday.text! != "" || (self.birthday.text?.characters.count) != 0 { return }
      
        self.enableUpdateButton()
        DatePickerDialog().show(title: "Birthday", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", maximumDate: Date(), datePickerMode: .date) {
            (date) -> Void in
            if let date = date {
                
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.dateFormat = "MMM dd, yyyy"
                self.birthday.text = formatter.string(from: date)
            }
        }
    }
    
    func imageAvialable() {
        self.isImageChanged = true
        self.profileImage.makeCircular(color: UIColor.white)
        self.enableUpdateButton()
    }
    
    func enableUpdateButton() {
        self.updateButton.isEnabled = true
        self.updateButton.setTitleColor(UIColor.white, for: .normal)
        self.updateButton.backgroundColor = UIColor.orange
    }
    
    func disableUpdateButton() {
        self.updateButton.isEnabled = false
        self.updateButton.setTitleColor(UIColor.lightGray, for: .normal)
        self.updateButton.backgroundColor = UIColor.white
    }
    
    func simpleAlert(message: String) {
        let alert = UIAlertController(title: "✉️", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.activityIndicator.stopAnimating()
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let orginalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            self.profileImage.image = orginalImage
            
            // Save Image if taken from camera
            if (picker.sourceType == .camera) {
                UIImageWriteToSavedPhotosAlbum(orginalImage, nil, nil, nil)
            }
            
            self.imageAvialable()
        } else{
            print("Something went wrong with profile picture selection")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: BEMCheckBoxDelegate {
    func animationDidStop(for checkBox: BEMCheckBox) {
        print("animaiton did stop")
        self.enableUpdateButton()
    }
    func didTap(_ checkBox: BEMCheckBox) {
        enableUpdateButton()
    }
}

 
