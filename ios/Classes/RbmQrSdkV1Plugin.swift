import Flutter
import UIKit
@_exported import SdkQrCore

public class RbmQrSdkV1Plugin: NSObject, FlutterPlugin {

  var manager: QrManager?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "rbm_qr_sdk_v1", binaryMessenger: registrar.messenger())
    let instance = RbmQrSdkV1Plugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case  "initializeLibrary":
        initializeLibrary(result: result)
        if(manager != nil){
            result("Library initialized successfully")
        } else {
            result(FlutterError(code: "INITIALIZATION_ERROR", message: "Failed to initialize library", details: nil))
        }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}


// MARK: - License Callback Protocol
extension RbmQrSdkV1Plugin: LicenseCallback {
    
    public func onLicenseValidated(_ isValid: Bool, message: String?) {
        // Handle license validation result
        print("License validation: \(isValid), message: \(message ?? "No message")")
    }
    
    public func onLicenseError(_ error: String) {
        // Handle license validation error
        print("License error: \(error)")
    }
}

// MARK: - Plugin Methods
extension RbmQrSdkV1Plugin {

    func initializeLibrary(result: @escaping FlutterResult) {
        self.manager = QrManagerImp()

        manager?.initializeLibrary(
            urlBase: "https://rgw.1647-63a93ef4.us-south.apiconnect.appdomain.cloud/rbmcalidad/calidad/api/v1/prx-licenses/validate",
            publicKey: "a3c7002d989e83a163a2648fcf8631bf:ec9008b76dea494ebc623c0dda976d30",
            license: "763cd5d7b76152c82162692a59aa362dcc616e72173239ff14e34e649459516e",
            callbackLicense: self
        )
    }
}
