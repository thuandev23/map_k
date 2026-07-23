import Flutter
import UIKit
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let registrar = self.registrar(forPlugin: "MapKLocationPlugin") {
      let channel = FlutterMethodChannel(name: "com.mapk/location", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        if call.method == "getCurrentLocation" {
          let locationManager = CLLocationManager()
          locationManager.requestWhenInUseAuthorization()
          if let loc = locationManager.location {
            result(["lat": loc.coordinate.latitude, "lng": loc.coordinate.longitude])
          } else {
            // Fallback default coordinates if hardware location is warming up
            result(["lat": 10.776889, "lng": 106.700806])
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
