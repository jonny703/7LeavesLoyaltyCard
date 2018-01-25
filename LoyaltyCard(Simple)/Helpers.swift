//
//  Helpers.swift
//  7Leaves Card
//
//  Created by John Nik on 01/30/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import CoreLocation
import Foundation
import UIKit

// Underline for textfiled
extension UITextField {
    func underlined(color: UIColor, width: Float ){
        let border = CALayer()
        let width = CGFloat(width)
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

extension UITextView {
    func underlined(color: UIColor){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

extension UIButton {
    func underlined(color: UIColor){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = 1.0
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

// Hide Keyboard when tapped around
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// Email Validation, get date from timestamp
extension String {
    func isValidEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    func getDateFromTimeStamp() -> String {
        let date = NSDate(timeIntervalSince1970: Double(self)! / 1000)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date as Date)
    }
    func getDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)!
    }
    func trim() -> String
    {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func isValidPhone() -> Bool {
        if let regex = try? NSRegularExpression(pattern: "^[+]?[01]?[- .]?(\\([2-9]\\d{2}\\)|[2-9]\\d{2})[- .]?\\d{3}[- .]?\\d{4}$", options: NSRegularExpression.Options.caseInsensitive) {
            let numberOfMatches = regex.numberOfMatches(in: self, options: [], range: NSMakeRange(0, (self as NSString).length))
            return numberOfMatches > 0
        }
        return false
    }
}

// Add shadow to view
extension UIView {
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    func addShadow(shadowColor: CGColor = UIColor.black.withAlphaComponent(0.3).cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    /*
    func addShadow() {
        self.layer.masksToBounds = false
        
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 0.6
    }
   */
}

// Make Image circuler and get image from url
extension UIImageView {
    func makeCircular(color: UIColor) {
        self.layer.borderWidth = 2
        self.layer.masksToBounds = false
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = self.frame.height/2.0
        self.clipsToBounds = true
    }
    
    func getImage(urlString: String) {
        let url = URL(string: urlString)
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url!) {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                    self.makeCircular(color: UIColor.white)
                }
            }
        }
    }
}

extension Date {
    func isBetweeen(date1: Date, date2: Date) -> Bool {
        return date1.compare(self) == self.compare(date2)
    }
}


class JSONParser {
    
    enum JSONParseError: Error {
        case notADictionary
        case missingWeatherObjects
    }
    
    func invalidEmails() -> [Any] {
        
        var domains = [Any]()
        let filePath = Bundle.main.path(forResource: "email_invalid",ofType:"json")
        if let data = NSData(contentsOfFile: filePath!) {
            
            do {
                let json = try JSONSerialization.jsonObject(with: data as Data, options:.allowFragments)
                guard let arrayOfDomains = json as? NSArray else { throw JSONParseError.notADictionary }
                
                for dict in arrayOfDomains {
                    guard let d = dict as? NSDictionary else { throw JSONParseError.notADictionary }

                    
                    for v in d.allValues {
                        domains.append(v)
                    }
                }
                
            }
            catch {
                print(error)
                
            }
        }
        
        debugPrint(domains.flatMap({$0}))
        return domains.flatMap({$0})
    }
}

class StoreManager {
    static var storeLocations = [CLLocation]()
    static var stores = [Store]()
    static var userCurrectLocation: CLLocation?
}
