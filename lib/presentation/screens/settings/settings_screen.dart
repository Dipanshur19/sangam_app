import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../providers/providers.dart';
import '../auth/login_screen.dart' show ContextSnack;

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _S();
}

class _S extends ConsumerState<SettingsScreen> {
  final _keyCtrl = TextEditingController();
  bool _visible = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    ref.read(apiKeyProvider.future).then((k) {
      if (k != null && k.isNotEmpty && mounted) _keyCtrl.text = '••••••${k.substring(k.length<6?0:k.length-6)}';
    });
  }

  @override
  void dispose() { _keyCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings'), leading: BackButton(onPressed: () => context.go('/dashboard'))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Section(title: 'Store', children: [_Tile(icon: Icons.store_outlined, label: 'Smriti General Store', sub: 'Patna, Bihar')]),
        const SizedBox(height: 16),
        _Section(title: 'AI Photo Parsing', children: [Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Anthropic API Key', style: AppTextStyles.bodyMd), const SizedBox(height: 4),
          Text('Required for Khata Photo import.', style: AppTextStyles.caption), const SizedBox(height: 10),
          TextField(controller: _keyCtrl, obscureText: !_visible, decoration: InputDecoration(hintText: 'sk-ant-api03-…',
            suffixIcon: IconButton(icon: Icon(_visible ? Icons.visibility_off : Icons.visibility, size: 18), onPressed: () => setState(() => _visible = !_visible)))),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () { _keyCtrl.clear(); ref.read(setApiKeyProvider)(''); context.showSnack('Cleared'); }, child: const Text('Clear'))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(onPressed: _saving ? null : () async {
              final v = _keyCtrl.text.trim();
              if (v.isEmpty || v.startsWith('••')) { context.showSnack('Enter valid key', isError: true); return; }
              setState(() => _saving = true);
              await ref.read(setApiKeyProvider)(v);
              setState(() => _saving = false);
              if (mounted) context.showSnack('Saved!');
            }, child: _saving ? const SizedBox(width:16,height:16,child: CircularProgressIndicator(strokeWidth:2,color: Colors.white)) : const Text('Save'))),
          ]),
        ]))]),
        const SizedBox(height: 16),
        _Section(title: 'Access PINs', children: [
          _Tile(icon: Icons.lock_outlined, label: 'Owner PIN: 1234', sub: 'Full access'),
          const Divider(height: 0, indent: 56),
          _Tile(icon: Icons.lock_open_outlined, label: 'Staff PIN: 5678', sub: 'Read-only lookup'),
        ]),
        const SizedBox(height: 16),
        _Section(title: 'Data', children: [_Tile(icon: Icons.refresh_rounded, label: 'Reset to demo data', sub: 'Restore sample customers', onTap: () async {
          final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
            title: const Text('Reset data?'), content: const Text('This erases current entries.'),
            actions: [TextButton(onPressed: ()=>Navigator.pop(ctx,false), child: const Text('Cancel')), TextButton(onPressed: ()=>Navigator.pop(ctx,true), child: const Text('Reset', style: TextStyle(color: AppColors.error)))]));
          if (confirm == true) {
            await ref.read(localSourceProvider).resetToDemo();
            ref.invalidate(transactionsStreamProvider); ref.invalidate(customersStreamProvider);
            ref.invalidate(todayTotalsProvider); ref.invalidate(overdueCustomersProvider);
            if (context.mounted) context.showSnack('Demo data restored!');
          }
        })]),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: () => context.go('/login'),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), foregroundColor: AppColors.error),
          child: const Text('Logout'))),
        const SizedBox(height: 40),
      ])),
    );
  }
}

class _Section extends StatelessWidget {
  final String title; final List<Widget> children;
  const _Section({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(title.toUpperCase(), style: AppTextStyles.labelCaps)),
    Container(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.borderLight, width: 0.5)), child: Column(children: children)),
  ]);
}

class _Tile extends StatelessWidget {
  final IconData icon; final String label; final String? sub; final VoidCallback? onTap;
  const _Tile({required this.icon, required this.label, this.sub, this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, size: 20, color: AppColors.text3),
    title: Text(label, style: AppTextStyles.bodyMd),
    subtitle: sub != null ? Text(sub!, style: AppTextStyles.caption) : null,
    trailing: onTap != null ? const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.text4) : null,
    onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
  );
}
