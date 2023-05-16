import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder {
  var window: UIWindow?
}

extension AppDelegate: UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions:
                        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    UNUserNotificationCenter.current().requestAuthorization(options: [
      .badge, .sound, .alert
    ]) { granted, _ in
      guard granted else { return }

      DispatchQueue.main.async {
        application.registerForRemoteNotifications()
      }
    }

    return true
  }
}
