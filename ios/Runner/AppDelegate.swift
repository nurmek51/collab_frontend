import Flutter
import UIKit
import AppTrackingTransparency

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    
    if #available(iOS 14.0, *) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        ATTrackingManager.requestTrackingAuthorization { status in
          // Handle tracking authorization status if needed
        }
      }
    }
  }
}

