import UIKit
import Flutter
import UserNotifications // Import UserNotifications for handling notifications

@main
@objc class AppDelegate: FlutterAppDelegate, UNUserNotificationCenterDelegate { // Conform to the UNUserNotificationCenterDelegate
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register plugins with Flutter
    GeneratedPluginRegistrant.register(with: self)

    // Set the UNUserNotificationCenter delegate if iOS 10.0 or later is available
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    // Call super to ensure Flutter's internal logic runs
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle notification when the app is in the foreground (iOS 10+)
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // Display the notification even when the app is in the foreground
    completionHandler([.alert, .badge, .sound])
  }
}
