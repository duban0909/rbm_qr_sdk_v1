import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:camera/camera.dart';

import 'qr_scanner_camera_adapter.dart';

class QrScannerCameraZxingAdapter extends QrScannerCameraAdapter {
  bool _flashOn = false;
  CameraController? _cameraController;
  @override
  Widget buildQrCamera({
    required void Function(String? value) onQrCodeScanned,
    required Widget Function(BuildContext context, Object? error) onError,
  }) {
    return Builder(
      builder: (context) {
        return SizedBox(
          height: 300,
          width: 300,
          child: ReaderWidget(
            onScan: (code) {
              if (code.isValid == true) {
                onQrCodeScanned(code.text);
              } else {
                onError(context, code.error ?? "Unknown error");
              }
            },
            onControllerCreated: (controller, exception) {
              if (exception != null) {
                onError(context, exception);
                return;
              }
              _cameraController = controller;
            },
            tryInverted: true,
            tryDownscale: true,
            cropPercent: 1,
            scanDelay: const Duration(milliseconds: 300),
            resolution: ResolutionPreset.medium,
            lensDirection: CameraLensDirection.back,
            showFlashlight: false,
            showToggleCamera: false,
            showGallery: false,
            allowPinchZoom: false,
            showScannerOverlay: false,
          ),
        );
      },
    );
  }

  @override
  void toggleFlash() async {
    if (_cameraController == null) return;

    _flashOn = !_flashOn;
    await _cameraController!.setFlashMode(
      _flashOn ? FlashMode.torch : FlashMode.off,
    );
  }
}