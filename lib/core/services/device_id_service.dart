import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  final FlutterSecureStorage _secureStorage;
  static const _deviceIdKey = 'app_device_id';

  DeviceIdService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<String> getDeviceId() async {
    String? deviceId = await _secureStorage.read(key: _deviceIdKey);

    if (deviceId != null) {
      return deviceId;
    }

    deviceId = const Uuid().v4();

    await _secureStorage.write(key: _deviceIdKey, value: deviceId);

    return deviceId;
  }

  // Optional: Get Human Readable Name (e.g., "iPhone 13") for emails/UI
  Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return '${androidInfo.manufacturer} ${androidInfo.model}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name; // e.g. "John's iPhone"
    }
    return 'Unknown Device';
  }
}
