import Flutter
import UIKit

// TODO(maps): Add a real Google Maps iOS API key before enabling GOOGLE_MAPS_ENABLED=true.
// Example after adding GoogleMaps pod/import:
// GMSServices.provideAPIKey("YOUR_REAL_GOOGLE_MAPS_IOS_API_KEY")

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
