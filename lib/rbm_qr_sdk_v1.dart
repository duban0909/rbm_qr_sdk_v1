import 'package:flutter/widgets.dart';
import 'package:rbm_qr_sdk_v1/external_library_adapter/qr_scanner_factory.dart';
import 'package:rbm_qr_sdk_v1/models/qr_model.dart';
import 'package:rbm_qr_sdk_v1/native_channel/qr_rbm_sdk_plugin_platform_interface.dart';
import 'package:rbm_qr_sdk_v1/ui/qr_navigator.dart';

export './models/qr_model.dart';

class RbmQrSdkV1 {
  Future<bool> initializeLibrary() {
    return QrRbmSdkPluginPlatform.instance.initializeLibrary();
  }

  Future<QrModel?> readQrWithCamera(BuildContext context) {
    return openQrScanner<QrModel>(context);
  }

  Future<QrModel?> readQrWithImage(BuildContext context) {
    return QrScannerFactory.getAdapterImage().readQrCodeFromImage(context);
  }
}
