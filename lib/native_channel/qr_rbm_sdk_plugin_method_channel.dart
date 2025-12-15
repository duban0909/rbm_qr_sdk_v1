import 'dart:async';
import 'package:flutter/services.dart';

import 'qr_rbm_sdk_plugin_platform_interface.dart';

/// An implementation of [QrRbmSdkPluginPlatform] that uses method channels.
class MethodChannelQrRbmSdkPlugin extends QrRbmSdkPluginPlatform {
  /// The method channel used to interact with the native platform.
  final methodChannel = const MethodChannel('rbm_qr_sdk_v1');

  MethodChannelQrRbmSdkPlugin() {
    methodChannel.setMethodCallHandler(handleMethodCall);
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<bool> initializeLibrary() async {
    print('initializeLibrary called');
    final result = await methodChannel.invokeMethod<bool>('initializeLibrary');
    print('initializeLibrary result: $result');
    return result ?? false;
  }

  @override
  Future<Map<String, dynamic>?> transformData(String data) async {
    print('String brefore transformData: $data');
    try {
      final result = await methodChannel.invokeMethod('transformData', {
        'qrString': data,
      });
      print('transformData result: $result');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Error during transformData: $e');
      return null;
    }
    // if (!validateQRString(data)) {
    //   errorResponseController.add('Error: Invalid QR data format');
    //   return null;
    // } else {
    //   try {
    //     final result = await methodChannel.invokeMethod('transformData', {
    //       'qrString': data,
    //     });
    //     print('transformData result: $result');
    //     return Map<String, dynamic>.from(result);
    //   } catch (e) {
    //     print('Error during transformData: $e');
    //     return null;
    //   }
    // }
  }

  @override
  Future<void> handleMethodCall(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'onScanResponse':
      print('handleMethodCall onScanResponse called');
        String qrData = methodCall.arguments;
        scanResponseController.add(qrData);
        break;
      case 'onErrorShow':
      print('handleMethodCall onErrorShow called');
        String errorData = methodCall.arguments;
        scanResponseController.add(errorData);
        break;
      default:
        throw MissingPluginException();
    }
  }

  // bool validateQRString(String qrData) {
  //   final regex = RegExp(
  //     r'CO\.COM\.RBM\.RED.*CO\.COM\.RBM\.CIVA.*CO\.COM\.RBM\.IVA',
  //     dotAll: true,
  //   );

  //   if (regex.hasMatch(qrData)) {
  //     return true;
  //   }

  //   return false;
  // }
}
