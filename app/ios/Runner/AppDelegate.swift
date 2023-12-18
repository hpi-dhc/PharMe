import UIKit
import Flutter

// Add privacy screen, based on
// https://articles.wesionary.team/securing-your-flutter-app-implementing-a-privacy-screen-61383ce09f0a

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var flutterViewController: FlutterViewController!
  private var securityChannel: FlutterMethodChannel!
  private var blurEffectView: UIVisualEffectView?
  private var isInBackground: Bool = false // Track whether app is in background

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    setupFlutterCommunication()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setupFlutterCommunication() {
    flutterViewController = window?.rootViewController as? FlutterViewController
    securityChannel = FlutterMethodChannel(
      name: "security",
      binaryMessenger: flutterViewController.binaryMessenger
    )

    securityChannel.setMethodCallHandler(handle)
  }

  override func applicationWillResignActive(_ application: UIApplication) {
    isInBackground = true // App will be inactive
    enableAppSecurity()
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    // Check if the app was in background before becoming active
    if isInBackground {
      disableAppSecurity()
      isInBackground = false
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "enableAppSecurity":
      result(nil)
    case "disableAppSecurity":
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func enableAppSecurity() {
    let blurEffect = UIBlurEffect(style: .light)
    blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView?.frame = window!.frame
    window?.addSubview(blurEffectView!)
  }

  private func disableAppSecurity() {
    blurEffectView?.removeFromSuperview()
  }
}
