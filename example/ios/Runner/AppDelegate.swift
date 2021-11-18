import UIKit
import Flutter
import banuba_arcloud

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, ARCloudPluginDelegate {
    var arCloudURL: String = <Place your url here>
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
