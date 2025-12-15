import 'package:flutter/material.dart';

abstract class QrScannerCameraAdapter {
  Widget buildQrCamera({
    required void Function(String? value) onQrCodeScanned,
    required Widget Function(BuildContext context, Object? error) onError,
  });

  void toggleFlash();
}
