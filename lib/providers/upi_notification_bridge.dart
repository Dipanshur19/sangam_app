import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/upi_notification_service.dart';

final upiNotificationServiceProvider = Provider<UpiNotificationService>((ref) {
  return UpiNotificationService();
});

final upiNotificationStreamProvider = StreamProvider<UpiNotificationEvent>((ref) {
  return ref.watch(upiNotificationServiceProvider).stream();
});

class UpiNotificationBridge {
  UpiNotificationBridge(this.ref);
  final Ref ref;
  StreamSubscription<UpiNotificationEvent>? _sub;

  void start({required Future<void> Function(UpiNotificationEvent event) onEvent}) {
    _sub ??= ref.read(upiNotificationServiceProvider).stream().listen(onEvent);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}

final upiNotificationBridgeProvider = Provider<UpiNotificationBridge>((ref) {
  final bridge = UpiNotificationBridge(ref);
  ref.onDispose(() {
    bridge.dispose();
  });
  return bridge;
});
