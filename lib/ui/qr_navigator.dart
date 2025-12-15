import 'package:flutter/material.dart';
import 'package:rbm_qr_sdk_v1/ui/qr_scanner_screen.dart';

Future<T?> openQrScanner<T>(BuildContext context) {
  return Navigator.of(
    context,
    rootNavigator: true,
  ).push<T>(MaterialPageRoute(builder: (_) => const QrScannerScreen()));
}
