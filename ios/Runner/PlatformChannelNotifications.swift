//
//  PlatformChannel.swift
//  Runner
//
//  Created by Максим Гребенников on 24.06.2020.
//

import UIKit
import Flutter

enum PlatformError: Error {
  case BadArguments
}

@available(iOS 10.0, *)
class PlatformChannelNotications {
  
  private let notifications: Notifications
  
  init(notifications: Notifications) {
    self.notifications = notifications
  }
  
  func chanelCallHandler(window: UIWindow) {
    let controller: FlutterViewController = window.rootViewController as! FlutterViewController
    let notificationsChannel = FlutterMethodChannel(name: "notifications", binaryMessenger: controller.binaryMessenger)
    
    notificationsChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      guard call.method == "setNotification" else {
        result(FlutterMethodNotImplemented)
        return
      }
      do {
        let res = try self.setNotification(notifications: self.notifications, arg: call.arguments as Any)
        result(res)
      } catch {
        result(error)
      }
    })
  }
  
  private func setNotification(notifications: Notifications, arg: Any) throws -> Int {
    guard let arg = arg as? Dictionary<String, Any> else { throw PlatformError.BadArguments }
    guard let title = arg["title"] as? String else { throw PlatformError.BadArguments }
    guard let id = arg["id"] as? Int else { throw PlatformError.BadArguments }
    guard let timeSince = arg["timeSince"] as? Double else {throw PlatformError.BadArguments }
    
    let res = notifications.scheduleNotification(text: title, timeSince: timeSince, id: id)
    return res
  }
}
