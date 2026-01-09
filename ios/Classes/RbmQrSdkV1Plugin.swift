import Flutter
import UIKit
import SdkQrCore

public class RbmQrSdkV1Plugin: NSObject,
                              FlutterPlugin,
                              QrLicenseCallback,
                              QrManagerCallback,
                              QrErrorCallback {

    private var manager: QrManager?
    private var pendingResult: FlutterResult?

    // MARK: - Plugin registration
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "rbm_qr_sdk_v1",
            binaryMessenger: registrar.messenger()
        )
        let instance = RbmQrSdkV1Plugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // MARK: - MethodChannel handler
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "initializeLibrary":
            initializeLibrary(result: result)

        case "transformData":
            guard
                let args = call.arguments as? [String: Any],
                let qrString = args["qrString"] as? String,
                !qrString.isEmpty
            else {
                result(FlutterError(
                    code: "INVALID_INPUT",
                    message: "qrString is required",
                    details: nil
                ))
                return
            }
            transformData(qrString: qrString, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// MARK: - SDK initialization
extension RbmQrSdkV1Plugin {

    func initializeLibrary(result: @escaping FlutterResult) {
        print("Inicializando SDK RBM iOS")

        manager = QrManagerImp()

        manager?.initializeLibrary(
            "https://rgw.1647-63a93ef4.us-south.apiconnect.appdomain.cloud/rbmcalidad/calidad/api/v1/prx-licenses/validate",
            publicKey: "a3c7002d989e83a163a2648fcf8631bf:ec9008b76dea494ebc623c0dda976d30",
            license: "763cd5d7b76152c82162692a59aa362dcc616e72173239ff14e34e649459516e",
            callbackLicense: self
        )

        result(true)
    }

    public func checkInitializeScan(_ start: Bool) {
        print("Licencia validada iOS: \(start)")
    }
}

// MARK: - Transform QR
extension RbmQrSdkV1Plugin {

    func transformData(qrString: String, result: @escaping FlutterResult) {
        guard let manager = manager else {
            result(FlutterError(
                code: "NOT_INITIALIZED",
                message: "SDK not initialized",
                details: nil
            ))
            return
        }

        print("🔹 transformData recibido desde Flutter")
        pendingResult = result
        manager.transformData(qrString, callbackResult: self)
    }

    public func onScanResponse(
        _ qrData: String,
        qrEntity: QrEntity,
        qrBaseData: [KeyValueNode]
    ) {
        print("QR transformado correctamente iOS")

        let qrTxIdValue = extractQrTxId(from: qrBaseData)

        let response: [String: Any?] = [
            "channel": qrEntity.merchantUnreservedTemplamples?.channel,
            "merchantCity": qrEntity.merchantCity,
            "ivaTaxIndicator": "01",
            "purposeOfTransaction": qrEntity.merchantAdditionalData?.purposeOfTransaction,
            "QRType": qrEntity.pointOfInitiationMethod == "12" ? "DNI" : "STA",
            "terminalLabel": qrEntity.merchantAdditionalData?.terminalLabel,
            "tipOrConvenienceIndicator": qrEntity.tipOrConvenienceIndicator,
            "valueOfConvenienceFeeFixed": qrEntity.valueOfConvenienceFeeFixed,
            "TransactionAmount": qrEntity.transactionAmount,
            "QRTransactionID": qrEntity.merchantUnreservedTemplamples?.consecutiveTransaction,
            "MerchantID": qrEntity.merchantAccountInformation?.uniqueCodeMerchant,
            "multikeyPayment": qrEntity.merchantAccountInformation?.multikeyPayment,
            "SecurityCode": qrEntity.merchantUnreservedTemplamples?.securityField,
            "merchantName": qrEntity.merchantName,
            "storeLabel": qrEntity.merchantAdditionalData?.storeLabel,
            "transactionCurrency": qrEntity.transactionCurrency,
            "rrn": qrEntity.rrn,
            "approvalNumber": qrEntity.approvalNumber,
            "idAcquirer": qrEntity.merchantAccountInformation?.idAcquirer,
            "QrTxId": qrTxIdValue
        ]

       
        pendingResult?(response.compactMapValues { $0 })
        pendingResult = nil
    }
}

// MARK: - Error callback
extension RbmQrSdkV1Plugin {

    public func onErrorShow(_ errorType: Int, message: String, detail: String?) {
        print("Error SDK iOS: \(message) \(detail ?? "")")

        pendingResult?(FlutterError(
            code: "TRANSFORM_ERROR",
            message: message,
            details: detail
        ))
        pendingResult = nil
    }
}

// MARK: - TAG 90 extraction (ANDROID 1:1)
extension RbmQrSdkV1Plugin {

    private func extractQrTxId(from qrBaseData: [KeyValueNode]) -> String {

        guard let node90 = qrBaseData.first(where: { $0.key == "90" }) else {
            return ""
        }

        let dict = node90.dictionaryValue

        let tag00 = dict.first(where: { $0.key == "00" })?.stringValue ?? ""
        let tag01 = dict.first(where: { $0.key == "01" })?.stringValue ?? ""

        
        return tag00 + tag01
    }
}
