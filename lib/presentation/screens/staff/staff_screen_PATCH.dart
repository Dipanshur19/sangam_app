// =========================================================================
// PATCH: staff_screen.dart
// =========================================================================
// ADD import at top:
//   import 'package:share_plus/share_plus.dart';
//   import '../../../services/upi_notification_service.dart';
//
// ADD this method in your StaffScreen State:
// =========================================================================

/*
  Future<void> _shareInviteLink(AppUser staff) async {
    final auth = ref.read(authServiceProvider);
    final token = await auth.generateInviteToken(staff.id);
    final shopId = ref.read(storeProfileProvider).valueOrNull?.id ?? 'shop';
    final link = UpiNotificationService.buildInviteLink(
      staffId: staff.id,
      shopId:  shopId,
      token:   token,
    );
    final msg = 'Hi \${staff.name}! Tap to join Sangam (no sign-up):\n\$link';
    await Share.share(msg);
  }

  // In your ListTile trailing, ADD:
  // trailing: IconButton(
  //   icon: const Icon(Icons.share_outlined),
  //   tooltip: 'Share invite link',
  //   onPressed: () => _shareInviteLink(staff),
  // ),
*/
