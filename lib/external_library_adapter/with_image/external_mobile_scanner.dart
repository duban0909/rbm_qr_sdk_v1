

import 'package:flutter/widgets.dart';

import 'package:rbm_qr_sdk_v1/external_library_adapter/with_image/read_qr_with_image_adapter.dart';
import 'package:rbm_qr_sdk_v1/mappers/qr_mapper.dart';
import 'package:rbm_qr_sdk_v1/models/qr_model.dart';
import 'package:rbm_qr_sdk_v1/native_channel/qr_rbm_sdk_plugin_platform_interface.dart';
import 'package:rbm_qr_sdk_v1/utils/camera_gallery.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

class ExternalMobileScanner implements ReadQrWithImage {
  final nativeChannelInstance = QrRbmSdkPluginPlatform.instance;

  @override
  Future<QrModel?> readQrCodeFromImage(BuildContext context) async {
    final imagePath = await CameraGallery.selectPhoto();
    if (imagePath == null) {
      return QrModel(channel: 'Close Scanner');
    }
    final params = DecodeParams(
      format: Format.qrCode,
      tryHarder: true,
      tryInverted: true,
      imageFormat: ImageFormat.rgb,
      maxSize: 2000,
    );

    final Code code = await zx.readBarcodeImagePathString(imagePath, params);

    if (code.text == null || code.text!.isEmpty) {
      return null;
    }

    

    try {
      final qrData = await nativeChannelInstance.transformData(code.text ?? '');
      if(qrData != null) {
        return QrMapper.fromJson(qrData);
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  bool validateQRString(String qrData) {
    if (qrData.isEmpty) return false;

    const entities = [
      'ACH',
      'BRC',
      'CRB',
      'MCCA',
      'RBM',
      'SVB',
      'VCSS',
      'VISI',
    ];

    final redRegex = RegExp(
      r'CO\.COM\.(ACH|BRC|CRB|MCCA|RBM|SVB|VCSS|VISI)\.RED',
      dotAll: true,
    );

    final redMatches = redRegex.allMatches(qrData);
    if (redMatches.isEmpty) return false;

    for (final m in redMatches) {
      final entity = m.group(1)!;

      if (!entities.contains(entity)) continue;

      final civaRegex = RegExp('CO\\.COM\\.$entity\\.CIVA', dotAll: true);
      final ivaRegex = RegExp('CO\\.COM\\.$entity\\.IVA', dotAll: true);

      if (civaRegex.hasMatch(qrData) && ivaRegex.hasMatch(qrData)) {
        return true;
      }
    }

    return false;
  }
}
