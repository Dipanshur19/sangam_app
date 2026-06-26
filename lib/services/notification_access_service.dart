import 'package:flutter/services.dart';

class NotificationAccessService {
  static const _channel = MethodChannel('sangam/notification_access');

  Future<bool> isEnabled() async {
    final result = await _channel.invokeMethod<bool>('isEnabled');
    return result ?? false;
  }

  Future<void> openSettings() async {
    await _channel.invokeMethod('openSettings');
  }
}
