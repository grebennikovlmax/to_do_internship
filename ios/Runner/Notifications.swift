//
//  Notifications.swift
//  Runner
//
//  Created by Максим Гребенников on 24.06.2020.
//

import Foundation
import UserNotifications

@available(iOS 10.0, *)
class Notifications: NSObject, UNUserNotificationCenterDelegate {
  
  let notificationCenter = UNUserNotificationCenter.current()
  
  func notificationsRequest() {
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    notificationCenter.requestAuthorization(options: options) { allow, error in
      if !allow {
        
      }
    }
  }
  
  func scheduleNotification(text: String, timeSince: Double, id: Int) -> Int {
    
    let id = String(id)
    
    notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    
    let content = UNMutableNotificationContent()
    content.title = "Вставай с дивана"
    content.body = "Пора сделать дело \(text)"
    content.sound = UNNotificationSound.default
    content.badge = 1
  
    let interval = timeSince / 1000 - Date(timeIntervalSinceNow: 0).timeIntervalSince1970
    
    guard interval > 0 else { return 0 }
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false);
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    
    var error: Error?
    notificationCenter.add(request) { err in
      error = err
    }
    return error == nil ? 1 : 0
  }
}
