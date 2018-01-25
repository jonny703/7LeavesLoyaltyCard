//
//  UserNotificationManager.swift
//  LoyaltyCard(Simple)
//
//  Created by John Nik on 16/2/2017.
//
//

import UIKit
import UserNotifications

class UserNotificationManager: NSObject {
    static func setBirthdayNotification(birthday: String) {
        
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        
        if birthday == "" || (birthday.characters.count) == 0 { return }
        
        /* user birthday */
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "MMM dd, yyyy"
        let fireDate = formatter.date(from: birthday)
        
        guard fireDate != nil else { return }
        
        let unitFlags = Set<Calendar.Component>([.hour, .year, .minute, .month, .day])
        let components = NSCalendar.current.dateComponents(unitFlags, from: fireDate!)
        let todayComponent = NSCalendar.current.dateComponents(unitFlags, from: Date())
        
        let content = UNMutableNotificationContent()
        content.title = "Free Stamp"
        content.body = "You got 1 stamp for your birthday"
        content.categoryIdentifier = "birthday_stamp"
        content.userInfo = ["birthday": true]
        content.sound = UNNotificationSound.default()
        
        var dateComponents = DateComponents()
        dateComponents.year = todayComponent.year
        dateComponents.month = components.month
        dateComponents.day = components.day
        
        /*Prod values*/
        dateComponents.hour = 0
        dateComponents.minute = 0
        
        /*Debug values
        dateComponents.hour = todayComponent.hour
        dateComponents.minute = todayComponent.minute! + 1*/
 
        
        debugPrint("fire at \(dateComponents.year) \(dateComponents.month) \(dateComponents.day) \(dateComponents.hour) \(dateComponents.minute)")
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
        
    }

}
