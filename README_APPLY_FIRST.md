# Sangam Pro auto-save bundle

This bundle includes:
- Previous UI and Android native notification listener patches
- A patched `providers.dart` based on your attached provider architecture
- Native UPI notification events automatically entering `smsQueueProvider`
- A helper method to convert queue entries into transactions

## What happens now
- Android NotificationListener captures UPI notifications.
- Flutter receives them through EventChannel.
- `smsQueueProvider` auto-adds those events as pending `SmsEntry` items.
- You can then keep using your existing SMS queue review screen.

## Apply
1. Extract this zip.
2. Copy `lib/` into your project root and replace files.
3. Copy `android/` into your project root and replace files.
4. If your package name is not `com.example.sangam_pro`, fix Kotlin package declarations and folder names.
5. Run:
   - flutter clean
   - flutter pub get
   - flutter run

## Important
- This patch safely routes native UPI events into your existing queue architecture.
- It does not force auto-matching customers. Reconciliation still happens from your review flow, which is safer for W5.
