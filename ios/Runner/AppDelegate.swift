import UIKit
import Flutter

@available(iOS 10.0, *)
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
  let notifications = Notifications()
  let platform = PlatformChannelManager()
  
  override func application( _ application: UIApplication,
                             didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool {
    notifications.notificationCenter.delegate = notifications
    notifications.notificationsRequest()
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let notificationsChannel = FlutterMethodChannel(name: "notifications", binaryMessenger: controller.binaryMessenger)
    
    notificationsChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      guard call.method == "setNotification" else {
        result(FlutterMethodNotImplemented)
        return
      }
      do {
        let res = try self.platform.setNotification(notifications: self.notifications, arg: call.arguments as Any)
        result(res)
      } catch {
        result(error)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
