import 'package:rbm_qr_sdk_v1/external_library_adapter/with_camera/qr_scanner_camera_adapter.dart';
import 'package:rbm_qr_sdk_v1/external_library_adapter/with_camera/qr_scanner_camera_zxing_adapter.dart';
import 'package:rbm_qr_sdk_v1/external_library_adapter/with_image/external_mobile_scanner.dart';

class QrScannerFactory {
  static QrScannerCameraAdapter getAdapterCamera() {
    return QrScannerCameraZxingAdapter();
  }

  static ExternalMobileScanner getAdapterImage() {
    return ExternalMobileScanner();
  }
}
