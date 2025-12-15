import 'package:flutter/widgets.dart';
import 'package:rbm_qr_sdk_v1/models/qr_model.dart';

abstract class ReadQrWithImage {
  Future<QrModel?> readQrCodeFromImage(BuildContext context);
}
