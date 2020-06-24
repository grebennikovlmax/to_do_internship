//
//  PlatformChannel.swift
//  Runner
//
//  Created by Максим Гребенников on 24.06.2020.
//

import Foundation

enum PlatformError: Error {
  case BadArguments
}

@available(iOS 10.0, *)
class PlatformChannelManager {
  
  func setNotification(notifications: Notifications, arg: Any) throws -> Int {
    guard let arg = arg as? Dictionary<String, Any> else { throw PlatformError.BadArguments }
    guard let title = arg["title"] as? String else { throw PlatformError.BadArguments }
    guard let id = arg["id"] as? Int else { throw PlatformError.BadArguments }
    guard let timeSince = arg["timeSince"] as? Int else {throw PlatformError.BadArguments }
    
    let res = notifications.scheduleNotification(text: title, timeSince: timeSince, id: id)
    return res
  }
}
