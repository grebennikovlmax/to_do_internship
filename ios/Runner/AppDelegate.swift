import UIKit
import Flutter

@available(iOS 10.0, *)
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
  private let notifications = Notifications()
  private var platformChanelNotifications: PlatformChannelNotications!
  
  override func application( _ application: UIApplication,
                             didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool {
    
    notifications.notificationCenter.delegate = notifications
    notifications.notificationsRequest()
    initPlatformChanelNotifications()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func initPlatformChanelNotifications() {
    platformChanelNotifications = PlatformChannelNotications(notifications: notifications)
    platformChanelNotifications.chanelCallHandler(window: window)
  }
}
