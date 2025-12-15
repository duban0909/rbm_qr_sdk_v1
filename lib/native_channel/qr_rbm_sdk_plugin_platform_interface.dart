import 'dart:async';

import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'qr_rbm_sdk_plugin_method_channel.dart';

abstract class QrRbmSdkPluginPlatform extends PlatformInterface {
  /// Constructs a QrRbmSdkPluginPlatform.
  QrRbmSdkPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static QrRbmSdkPluginPlatform _instance = MethodChannelQrRbmSdkPlugin();

  /// The default instance of [QrRbmSdkPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelQrRbmSdkPlugin].
  static QrRbmSdkPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [QrRbmSdkPluginPlatform] when
  /// they register themselves.
  static set instance(QrRbmSdkPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  final scanResponseController = StreamController<String>.broadcast();
  final errorResponseController = StreamController<String>.broadcast();
  Stream<String> get onScanResponse => scanResponseController.stream;
  Stream<String> get onErrorResponse => errorResponseController.stream;

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> initializeLibrary() {
    throw UnimplementedError('initializeLibrary() has not been implemented.');
  }

  Future<Map<String, dynamic>?> transformData(String data) {
    throw UnimplementedError('transformData() has not been implemented.');
  }

  Future<void> handleMethodCall(MethodCall methodCall) {
    throw UnimplementedError('handleMethodCall() has not been implemented.');
  }

  void dispose() {
    scanResponseController.close();
    errorResponseController.close();
  }
}
