import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme.dart';
import '../../../core/l10n.dart';
import '../../../domain/entities/store_profile.dart';
import '../../../domain/entities/app_user.dart';
import '../../../services/auth_service.dart';
import '../../providers/providers.dart';
import '../auth/login_screen.dart' show ContextSnack;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(storeProfileProvider);
    final me = ref.watch(currentUserProvider);
    final isAdmin = me?.isAdmin ?? false;
    final smsOn = ref.watch(smsAutoReadProvider);
    final hi = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr('Settings', 'सेटिंग्स', hi)),
        leading: BackButton(onPressed: () => context.go('/dashboard')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (me != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppGradients.saffron,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: AppShadows.saffron,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        me.name.isEmpty ? '?' : me.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            me.name,
                            style: AppTextStyles.h4.copyWith(color: Colors.white),
                          ),
                          Text(
                            '@${me.username} · ${me.isAdmin ? 'Admin' : (me.canEdit ? 'Staff (can edit)' : 'Staff (view only)')}',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _Section(
              title: tr('Store', 'दुकान', hi),
              children: [
                _Tile(
                  icon: Icons.store_outlined,
                  label: store.name.isEmpty ? 'My Store' : store.name,
                  sub: _storeSub(store),
                  onTap: isAdmin ? () => _editStore(context, ref, store) : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: tr('Preferences', 'प्राथमिकताएँ', hi),
              children: [
                ListTile(
                  leading: const Icon(Icons.translate_rounded, size: 20, color: AppColors.text3),
                  title: Text(tr('Language', 'भाषा', hi), style: AppTextStyles.bodyMd),
                  subtitle: Text(
                    tr('Choose app language', 'ऐप की भाषा चुनें', hi),
                    style: AppTextStyles.caption,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.saffronLight,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      hi ? 'हिंदी' : 'English',
                      style: AppTextStyles.btnSm.copyWith(color: AppColors.saffron),
                    ),
                  ),
                  onTap: () {
                    final isHindi = ref.read(languageProvider);
                    ref.read(languageProvider.notifier).state = !isHindi;
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: tr('Payments', 'भुगतान', hi),
              children: [
                SwitchListTile(
                  value: smsOn,
                  activeColor: AppColors.saffron,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  secondary: const Icon(Icons.sms_outlined, color: AppColors.text3, size: 20),
                  title: Text(
                    tr('Auto-read UPI SMS', 'UPI SMS अपने आप पढ़ें', hi),
                    style: AppTextStyles.bodyMd,
                  ),
                  subtitle: Text(
                    smsOn
                        ? tr('Reading payment SMS automatically', 'भुगतान SMS अपने आप पढ़े जा रहे हैं', hi)
                        : tr('Detect Paytm / GPay / PhonePe payments from SMS', 'SMS से Paytm / GPay / PhonePe भुगतान पहचानें', hi),
                    style: AppTextStyles.caption,
                  ),
                  onChanged: !isAdmin
                      ? null
                      : (v) async {
                          if (v) {
                            final ok = await ref.read(smsAutoReadProvider.notifier).enable();
                            if (context.mounted) {
                              context.showSnack(
                                ok ? 'Auto-read enabled' : 'SMS permission denied',
                                isError: !ok,
                              );
                            }
                          } else {
                            await ref.read(smsAutoReadProvider.notifier).disable();
                            if (context.mounted) context.showSnack('Auto-read turned off');
                          }
                        },
                ),
                const Divider(height: 0, indent: 56),
                _Tile(
                  icon: Icons.inbox_outlined,
                  label: tr('Review detected payments', 'पहचाने गए भुगतान देखें', hi),
                  sub: tr('Assign incoming UPI SMS to customers', 'आने वाले UPI SMS ग्राहकों को सौंपें', hi),
                  onTap: () => context.push('/sms-queue'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _CloudSyncSection(),
            const SizedBox(height: 16),
            _Section(
              title: tr('Business', 'व्यापार', hi),
              children: [
                _Tile(
                  icon: Icons.person_outline_rounded,
                  label: tr('Profile', 'प्रोफ़ाइल', hi),
                  sub: tr('Business info, GST, UPI ID, address', 'व्यापार जानकारी, GST, UPI ID, पता', hi),
                  onTap: () => context.push('/profile'),
                ),
                const Divider(height: 0, indent: 56),
                _Tile(
                  icon: Icons.inventory_2_outlined,
                  label: tr('Stock management', 'स्टॉक प्रबंधन', hi),
                  sub: tr('Track the items you sell', 'आप जो सामान बेचते हैं उसे ट्रैक करें', hi),
                  onTap: () => context.push('/stock'),
                ),
                const Divider(height: 0, indent: 56),
                _Tile(
                  icon: Icons.devices_rounded,
                  label: tr('Multi device', 'कई डिवाइस', hi),
                  sub: tr('Use on family & staff phones', 'परिवार और स्टाफ़ के फ़ोन पर इस्तेमाल करें', hi),
                  onTap: () => context.push('/multi-device'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isAdmin) ...[
              _TeamSection(),
              const SizedBox(height: 16),
            ],
            if (isAdmin) ...[
              _Section(
                title: tr('Data', 'डेटा', hi),
                children: [
                  _Tile(
                    icon: Icons.delete_outline_rounded,
                    label: tr('Clear all data', 'सारा डेटा मिटाएँ', hi),
                    sub: tr('Erase all customers & transactions', 'सभी ग्राहक और लेन-देन मिटाएँ', hi),
                    onTap: () async {
                      final ok = await _confirm(
                        context,
                        'Clear all data?',
                        'This permanently erases every customer and transaction. Your shop profile and team are kept.',
                        'Clear all',
                        AppColors.error,
                      );
                      if (ok) {
                        await ref.read(localSourceProvider).clearAllData();
                        _refreshData(ref);
                        if (context.mounted) context.showSnack('All data cleared');
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            _Section(
              title: tr('About', 'ऐप के बारे में', hi),
              children: [
                const _Tile(
                  icon: Icons.info_outline_rounded,
                  label: 'Sangam',
                  sub: 'Version 2.0.0',
                ),
                const Divider(height: 0, indent: 56),
                _Tile(
                  icon: Icons.favorite_outline_rounded,
                  label: 'Sab ka ek hisaab',
                  sub: tr('One ledger for UPI, cash & udhar', 'UPI, नकद और उधार — एक ही हिसाब', hi),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(currentUserProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  foregroundColor: AppColors.error,
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(tr('Log out', 'लॉग आउट', hi)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _storeSub(StoreProfile s) {
    final parts = [
      if (s.ownerName.isNotEmpty) s.ownerName,
      if (s.location.isNotEmpty) s.location,
    ];
    return parts.isEmpty ? 'Tap to edit details' : parts.join(' · ');
  }

  void _refreshData(WidgetRef ref) {
    ref.invalidate(transactionsStreamProvider);
    ref.invalidate(customersStreamProvider);
    ref.invalidate(todayTotalsProvider);
    ref.invalidate(overdueCustomersProvider);
    ref.invalidate(usersProvider);
  }

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String body,
    String action,
    Color color,
  ) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
    return r ?? false;
  }

  void _editStore(BuildContext context, WidgetRef ref, StoreProfile current) {
    final nameCtrl = TextEditingController(text: current.name);
    final ownerCtrl = TextEditingController(text: current.ownerName);
    final locationCtrl = TextEditingController(text: current.location);
    int dueDays = current.creditDueDays;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit store details', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Shop name *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ownerCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Owner name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 16),
              Text('CREDIT DUE AFTER', style: AppTextStyles.labelCaps),
              const SizedBox(height: 8),
              Row(
                children: [7, 15, 30]
                    .map(
                      (d) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: GestureDetector(
                            onTap: () => setSheet(() => dueDays = d),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: dueDays == d ? AppColors.saffron : AppColors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: dueDays == d ? AppColors.saffron : AppColors.border,
                                ),
                              ),
                              child: Text(
                                '$d days',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: dueDays == d ? Colors.white : AppColors.text2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty) {
                          context.showSnack('Enter a shop name', isError: true);
                          return;
                        }
                        await ref.read(storeProfileProvider.notifier).save(
                              current.copyWith(
                                name: nameCtrl.text.trim(),
                                ownerName: ownerCtrl.text.trim(),
                                location: locationCtrl.text.trim(),
                                creditDueDays: dueDays,
                              ),
                            );
                        ref.invalidate(overdueCustomersProvider);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) context.showSnack('Store details updated');
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return _Section(
      title: 'Team',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceTinted,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.borderLight, width: 0.6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.groups_2_outlined, size: 18, color: AppColors.saffron),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Create a separate login for each staff member. They should use the Staff tab on the login screen.',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
        ),
        ...usersAsync.when(
          loading: () => [
            const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
          ],
          error: (_, __) => [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Could not load team'),
            ),
          ],
          data: (users) {
            final staff = users.where((u) => !u.isAdmin).toList();
            return [
              for (final u in staff) ...[
                ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.saffronLight,
                    child: Text(
                      u.name.isEmpty ? '?' : u.name[0].toUpperCase(),
                      style: AppTextStyles.btnSm.copyWith(color: AppColors.saffron),
                    ),
                  ),
                  title: Text(u.name, style: AppTextStyles.bodyMd),
                  subtitle: Text(
                    '@${u.username} · ${u.canEdit ? 'Can edit' : 'View only'}',
                    style: AppTextStyles.caption,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_horiz_rounded, size: 20, color: AppColors.text3),
                    onPressed: () => _staffOptions(context, ref, u),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                const Divider(height: 0, indent: 56),
              ],
              ListTile(
                leading: const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 20,
                  color: AppColors.saffron,
                ),
                title: Text(
                  'Add staff login',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.saffron),
                ),
                subtitle: Text(
                  staff.isEmpty ? 'Create the first staff account' : '${staff.length} staff member(s)',
                  style: AppTextStyles.caption,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                onTap: () => _addStaff(context, ref),
              ),
            ];
          },
        ),
      ],
    );
  }

  Future<void> _addStaff(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool canEdit = true;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add staff login', style: AppTextStyles.h3),
              const SizedBox(height: 4),
              Text(
                'Create staff credentials and share them directly after saving.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Staff name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: userCtrl,
                autocorrect: false,
                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'e.g. staff.riya',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Minimum 4 characters',
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: canEdit,
                activeColor: AppColors.saffron,
                contentPadding: EdgeInsets.zero,
                title: Text('Allow adding & editing', style: AppTextStyles.bodyMd),
                subtitle: Text(
                  canEdit ? 'Can record and edit transactions' : 'View only — cannot change data',
                  style: AppTextStyles.caption,
                ),
                onChanged: (v) => setSheet(() => canEdit = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final username = userCtrl.text.trim();
                        final pass = passCtrl.text;

                        if (name.isEmpty || username.length < 3 || pass.length < 4) {
                          context.showSnack(
                            'Name, username (3+), and password (4+) are required',
                            isError: true,
                          );
                          return;
                        }

                        try {
                          await ref.read(authServiceProvider).addStaff(
                                name: name,
                                username: username,
                                password: pass,
                                canEdit: canEdit,
                              );
                          ref.invalidate(usersProvider);

                          if (ctx.mounted) Navigator.pop(ctx);
                          if (!context.mounted) return;

                          context.showSnack('Staff login created');
                          await _shareStaffCredentials(
                            context,
                            ref,
                            name: name,
                            username: username,
                            password: pass,
                            canEdit: canEdit,
                          );
                        } on DuplicateUsernameException {
                          if (context.mounted) {
                            context.showSnack('Username already taken', isError: true);
                          }
                        }
                      },
                      child: const Text('Save & share'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _staffOptions(BuildContext context, WidgetRef ref, AppUser u) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                u.canEdit ? Icons.visibility_outlined : Icons.edit_outlined,
                color: AppColors.text2,
              ),
              title: Text(u.canEdit ? 'Make view-only' : 'Allow editing'),
              onTap: () async {
                await ref.read(authServiceProvider).updateStaff(
                      u.id,
                      canEdit: !u.canEdit,
                    );
                ref.invalidate(usersProvider);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  context.showSnack(
                    !u.canEdit ? 'Editing enabled' : 'Switched to view-only',
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset_rounded, color: AppColors.text2),
              title: const Text('Reset password'),
              onTap: () {
                Navigator.pop(ctx);
                _resetPassword(context, ref, u);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined, color: AppColors.text2),
              title: const Text('Share login instructions'),
              subtitle: Text('@${u.username}', style: AppTextStyles.caption),
              onTap: () async {
                Navigator.pop(ctx);
                await _shareExistingStaff(context, ref, u);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: const Text(
                'Remove staff',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                final ok = await _confirmRemove(context, u.name);
                if (!ok) return;
                await ref.read(authServiceProvider).removeUser(u.id);
                ref.invalidate(usersProvider);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) context.showSnack('Staff removed');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _shareStaffCredentials(
    BuildContext context,
    WidgetRef ref, {
    required String name,
    required String username,
    required String password,
    required bool canEdit,
  }) async {
    final store = ref.read(storeProfileProvider);

    final buffer = StringBuffer()
      ..writeln('Hi $name,')
      ..writeln()
      ..writeln('Your Sangam staff login is ready for ${store.name.isEmpty ? 'the shop' : store.name}.')
      ..writeln()
      ..writeln('Open Sangam and tap the Staff tab on the login screen.')
      ..writeln()
      ..writeln('Username: $username')
      ..writeln('Password: $password')
      ..writeln('Access: ${canEdit ? 'Can edit' : 'View only'}')
      ..writeln()
      ..writeln('Please change or confirm these details with the owner after first login.');

    await Share.share(
      buffer.toString(),
      subject: 'Sangam staff login for ${store.name.isEmpty ? 'your shop' : store.name}',
    );
  }

  Future<void> _shareExistingStaff(BuildContext context, WidgetRef ref, AppUser u) async {
    final store = ref.read(storeProfileProvider);

    final buffer = StringBuffer()
      ..writeln('Hi ${u.name},')
      ..writeln()
      ..writeln('Use the Staff tab in Sangam to log in to ${store.name.isEmpty ? 'the shop' : store.name}.')
      ..writeln()
      ..writeln('Username: ${u.username}')
      ..writeln('Access: ${u.canEdit ? 'Can edit' : 'View only'}')
      ..writeln()
      ..writeln('If you do not have the password, ask the owner to reset it from Settings → Team.');

    await Share.share(
      buffer.toString(),
      subject: 'Sangam staff login for ${store.name.isEmpty ? 'your shop' : store.name}',
    );
  }

  Future<void> _resetPassword(BuildContext context, WidgetRef ref, AppUser u) async {
    final passCtrl = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reset password for ${u.name}', style: AppTextStyles.h4),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (passCtrl.text.length < 4) {
                    context.showSnack('Use at least 4 characters', isError: true);
                    return;
                  }
                  await ref.read(authServiceProvider).setPassword(u.id, passCtrl.text);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) context.showSnack('Password updated');
                },
                child: const Text('Update password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmRemove(BuildContext context, String name) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove staff?'),
        content: Text('This will remove $name from the team login list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title.toUpperCase(), style: AppTextStyles.labelCaps),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.borderLight, width: 0.5),
            ),
            child: Column(children: children),
          ),
        ],
      );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.label,
    this.sub,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, size: 20, color: AppColors.text3),
        title: Text(label, style: AppTextStyles.bodyMd),
        subtitle: sub != null ? Text(sub!, style: AppTextStyles.caption) : null,
        trailing: onTap != null
            ? const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.text4)
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      );
}

class _CloudSyncSection extends StatelessWidget {
  const _CloudSyncSection();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      title: 'Cloud sync',
      children: [
        _Tile(
          icon: Icons.cloud_off_rounded,
          label: 'Not available in this build',
          sub: 'Cloud sync is temporarily hidden until the local provider wiring is restored.',
        ),
      ],
    );
  }
}
