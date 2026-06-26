import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../providers/providers.dart';

class SmsQueueScreen extends ConsumerWidget {
  const SmsQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('UPI Auto-Capture')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E8FF),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.notifications_active_outlined, size: 40, color: Color(0xFF4E46E5)),
              ),
              const SizedBox(height: 28),
              Text('Auto-capture UPI payments', style: AppTextStyles.h2, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('Allow Sangam to read UPI payment notifications from Paytm, GPay and PhonePe — no SMS permission needed. Your data never leaves your phone.', textAlign: TextAlign.center, style: AppTextStyles.body),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => ref.read(smsAutoReadProvider.notifier).enable(),
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('Open Notification Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
