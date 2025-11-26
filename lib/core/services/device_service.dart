// lib/core/services/device_service.dart

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._();
  static DeviceService get instance => _instance;
  DeviceService._();

  String? platform;
  String? deviceModel;
  String? osVersion;
  String? appVersion;

  Future<void> init() async {
    try {
      // App version
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;

      // Device info
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        platform = 'android';
        deviceModel = '${info.manufacturer} ${info.model}';
        osVersion = 'Android ${info.version.release}';
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        platform = 'ios';
        deviceModel = info.model;
        osVersion = '${info.systemName} ${info.systemVersion}';
      }
    } catch (e) {
      // Silent fail - device info kritik emas
    }
  }

  Map<String, String?> toJson() => {
    'platform': platform,
    'device_model': deviceModel,
    'os_version': osVersion,
    'app_version': appVersion,
  };
}