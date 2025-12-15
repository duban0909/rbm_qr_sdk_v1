import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rbm_qr_sdk_v1/external_library_adapter/qr_scanner_factory.dart';
import 'package:rbm_qr_sdk_v1/external_library_adapter/with_camera/qr_scanner_camera_adapter.dart';
import 'package:rbm_qr_sdk_v1/mappers/qr_mapper.dart';
import 'package:rbm_qr_sdk_v1/models/qr_model.dart';
import 'package:rbm_qr_sdk_v1/native_channel/qr_rbm_sdk_plugin_platform_interface.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final nativeChannelInstance = QrRbmSdkPluginPlatform.instance;

  final qrScanner = QrScannerFactory.getAdapterCamera();
  late final Widget qrScannerWidget;
  bool _hasReadCode = false;
  StreamSubscription<String>? _subscription;
  StreamSubscription<String>? _errorSubscription;

  @override
  void dispose() {
    _hasReadCode = true;
    _subscription?.cancel();
    _errorSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //nativeChannelInstance.initializeLibrary();

    _errorSubscription = nativeChannelInstance.onErrorResponse.listen((
      errorData,
    ) {
      Navigator.of(context, rootNavigator: true).pop();
    });
    qrScannerWidget = qrScanner.buildQrCamera(
      onQrCodeScanned: (value) async {
        if (!_hasReadCode && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_hasReadCode && mounted) {
              setState(() {
                _hasReadCode = true;
              });
            }
          });

          final result = await nativeChannelInstance.transformData(value ?? '');
          if (result != null && mounted) {
            final qrModel = QrMapper.fromJson(result);
            Navigator.of(context, rootNavigator: true).pop(qrModel);
          } else if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }
      },
      onError: (context, error) => const Text(
        "Error al intentar leer el código QR, vuelve a intentarlo",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReaderQrView(
      scannerCamera: qrScannerWidget,
      qrScannerCamera: qrScanner,
    );
  }
}

class ReaderQrView extends StatefulWidget {
  final Widget scannerCamera;
  final QrScannerCameraAdapter qrScannerCamera;

  const ReaderQrView({
    super.key,
    required this.scannerCamera,
    required this.qrScannerCamera,
  });

  @override
  State<ReaderQrView> createState() => _ReaderQrViewState();
}

class _ReaderQrViewState extends State<ReaderQrView> {
  bool flashOn = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop(QrModel(channel: 'Close Scanner'));
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(39, 21, 51, 1),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pop(QrModel(channel: 'Close Scanner'));
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Container(
                    height: 260,
                    width: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.black,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          widget.scannerCamera,
                          Image.asset('assets/images/scanner_focus.png'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    icon: Icon(
                      flashOn ? Icons.flashlight_off : Icons.flashlight_on,
                      size: 26,
                      color: const Color(0xff5C3478),
                    ),
                    onPressed: () {
                      widget.qrScannerCamera.toggleFlash();
                      setState(() {
                        flashOn = !flashOn;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
