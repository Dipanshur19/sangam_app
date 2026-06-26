╔═══════════════════════════════════════════════════════════╗
║     SANGAM PRO W5 DROP-IN PATCH                          ║
║     Extract into your sangam_pro/ root folder            ║
║     Say YES to all 'replace file?' prompts               ║
╚═══════════════════════════════════════════════════════════╝

DIRECT REPLACEMENTS (overwrite automatically when you paste):
─────────────────────────────────────────────────────────────
android/app/src/main/AndroidManifest.xml
android/app/src/main/kotlin/com/sangam/app/MainActivity.kt
android/app/src/main/kotlin/com/sangam/app/UpiPayment.kt              NEW
android/app/src/main/kotlin/com/sangam/app/UpiPaymentBroadcaster.kt   NEW
android/app/src/main/kotlin/com/sangam/app/UpiNotificationListener.kt NEW
android/app/src/main/kotlin/com/sangam/app/NotificationPermissionHelper.kt NEW
lib/services/upi_notification_service.dart                             NEW
lib/models/upi_payment_model.dart                                      NEW

PATCH FILES (open each one and follow the instructions inside):
──────────────────────────────────────────────────────────────
lib/services/auth_service_PATCH.dart
lib/presentation/providers/providers_PATCH.dart
lib/presentation/screens/splash/splash_screen_PATCH.dart
lib/presentation/screens/onboarding/onboarding_screen_PATCH.dart
lib/presentation/screens/staff/staff_screen_PATCH.dart

AFTER DROPPING FILES:
─────────────────────
  flutter clean && flutter pub get && flutter run

FIRST LAUNCH ON SMRITI'S PHONE:
────────────────────────────────
  Settings > Notification Access > Sangam > Toggle ON
  Done. Every GPay/PhonePe/Paytm payment auto-captures.
