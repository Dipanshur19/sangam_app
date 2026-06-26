// =========================================================================
// PATCH: splash_screen.dart
// =========================================================================
// ADD import at top:
//   import '../../../services/upi_notification_service.dart';
//
// In _startSequence(), ADD this block BEFORE the auth routing logic:
// =========================================================================

/*
  // Check for staff invite deep link (app opened via invite link)
  final invite = await UpiNotificationService.getPendingInvite();
  if (invite != null && mounted) {
    final auth = ref.read(authServiceProvider);
    final user = await auth.loginWithInviteToken(
      staffId: invite['staff_id']!,
      shopId:  invite['shop_id']!,
      token:   invite['token']!,
    );
    if (user != null && mounted) {
      await ref.read(currentUserProvider.notifier).setUser(user);
      context.go('/dashboard');
      return;
    }
  }
  // Listen for invite links while app is running
  UpiNotificationService.setInviteHandler((invite) async {
    final auth = ref.read(authServiceProvider);
    final user = await auth.loginWithInviteToken(
      staffId: invite['staff_id']!,
      shopId:  invite['shop_id']!,
      token:   invite['token']!,
    );
    if (user != null && mounted) {
      await ref.read(currentUserProvider.notifier).setUser(user);
      context.go('/dashboard');
    }
  });
*/
