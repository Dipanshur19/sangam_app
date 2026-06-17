import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme.dart';
import '../../../domain/entities/sms_entry.dart';
import '../../../domain/entities/transaction.dart';
import '../../../services/claude_service.dart';
import '../../providers/providers.dart';
import '../auth/login_screen.dart' show ContextSnack;

class PhotoImportScreen extends ConsumerStatefulWidget {
  const PhotoImportScreen({super.key});
  @override
  ConsumerState<PhotoImportScreen> createState() => _S();
}

class _S extends ConsumerState<PhotoImportScreen> {
  File? _image; bool _loading = false; List<ParsedKhataEntry> _entries = [];
  String? _error; bool _saved = false; final Set<int> _removed = {};

  Future<void> _pick(ImageSource src) async {
    final x = await ImagePicker().pickImage(source: src, imageQuality: 85, maxWidth: 1920);
    if (x == null) return;
    setState(() { _image = File(x.path); _entries = []; _error = null; _saved = false; _removed.clear(); });
    await _parse(File(x.path));
  }

  Future<void> _parse(File f) async {
    setState(() => _loading = true);
    final key = ref.read(apiKeyProvider).value;
    if (key == null || key.isEmpty) { setState(() { _error = 'No API key. Go to Settings.'; _loading = false; }); return; }
    try {
      final entries = await ClaudeService(key).parseKhataImage(f);
      setState(() { _entries = entries; _error = entries.isEmpty ? 'No entries found.' : null; });
    } catch (e) { setState(() => _error = 'Error: $e'); }
    setState(() => _loading = false);
  }

  Future<void> _saveAll() async {
    final visible = _entries.asMap().entries.where((e) => !_removed.contains(e.key)).toList();
    for (final e in visible) {
      await ref.read(addTransactionProvider)(Transaction(
        id: const Uuid().v4(), customerId: null, customerName: e.value.name, amount: e.value.amount,
        type: e.value.isCredit ? TransactionType.credit : TransactionType.cash,
        direction: e.value.isCredit ? TransactionDirection.outgoing : TransactionDirection.incoming,
        note: e.value.note ?? 'From khata photo', date: DateTime.now(), source: 'photo',
      ));
    }
    setState(() => _saved = true);
    if (mounted) context.showSnack('${visible.length} entries saved!');
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _entries.asMap().entries.where((e) => !_removed.contains(e.key)).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Khata Photo Import'), leading: BackButton(onPressed: () => context.pop())),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.saffronLight, borderRadius: BorderRadius.circular(AppRadius.lg)),
          child: Row(children: [const Icon(Icons.auto_awesome_rounded, color: AppColors.saffron, size: 18), const SizedBox(width: 10),
            Expanded(child: Text('AI reads handwritten entries in Hindi or English.', style: AppTextStyles.bodySm.copyWith(color: AppColors.saffronDark)))])),
        const SizedBox(height: 16),

        if (_image != null) Stack(children: [
          ClipRRect(borderRadius: BorderRadius.circular(AppRadius.xl), child: Image.file(_image!, height: 220, width: double.infinity, fit: BoxFit.cover)),
          Positioned(top: 8, right: 8, child: GestureDetector(onTap: () => setState(() { _image = null; _entries = []; }),
            child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 16)))),
        ]) else Column(children: [
          _PickTile(icon: Icons.camera_alt_outlined, label: 'Take photo', onTap: () => _pick(ImageSource.camera)),
          const SizedBox(height: 10),
          _PickTile(icon: Icons.photo_library_outlined, label: 'Choose from gallery', onTap: () => _pick(ImageSource.gallery)),
        ]),
        const SizedBox(height: 16),

        if (_loading) Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.border)),
          child: Row(children: [const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.saffron)), const SizedBox(width: 12), const Text('AI is reading the khata…')])),

        if (_error != null) Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(AppRadius.lg)),
          child: Text(_error!, style: AppTextStyles.bodySm.copyWith(color: AppColors.error))),

        if (_saved) Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(AppRadius.lg)),
          child: Text('All entries saved!', style: AppTextStyles.bodySm.copyWith(color: AppColors.success, fontWeight: FontWeight.w600))),

        if (visible.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Found ${visible.length} entries', style: AppTextStyles.labelCaps),
          const SizedBox(height: 8),
          ...visible.map((e) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.borderLight)),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.value.name, style: AppTextStyles.bodyMd),
                Text(e.value.isCredit ? 'Udhar given' : 'Received', style: AppTextStyles.caption),
              ])),
              Text('₹${e.value.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w700, color: e.value.isCredit ? AppColors.udhar : AppColors.success)),
              const SizedBox(width: 8),
              GestureDetector(onTap: () => setState(() => _removed.add(e.key)), child: const Icon(Icons.close, size: 16, color: AppColors.text3)),
            ]))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveAll, child: Text('Save ${visible.length} Entries'))),
        ],
        const SizedBox(height: 32),
      ])),
    );
  }
}

class _PickTile extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _PickTile({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.border, width: 1.5)),
    child: Row(children: [const SizedBox(width: 16), Icon(icon, size: 24, color: AppColors.saffron), const SizedBox(width: 14), Text(label, style: AppTextStyles.bodyMd), const Spacer(), const Icon(Icons.chevron_right_rounded, color: AppColors.border), const SizedBox(width: 16)])));
}
