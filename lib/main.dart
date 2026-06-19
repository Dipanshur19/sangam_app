import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'router.dart';
import 'firebase_options.dart';
import 'services/cloud_service.dart';
import 'presentation/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Cloud sync — only initialises if Firebase keys were provided at build time
  // (via --dart-define). The app runs fully offline otherwise.
  if (DefaultFirebaseOptions.isConfigured) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      CloudService.markAvailable();
    } catch (e) {
      debugPrint('Firebase init skipped: $e');
    }
  }

  runApp(const ProviderScope(child: SangamApp()));
}

class SangamApp extends ConsumerWidget {
  const SangamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appInitProvider);
    final router = buildRouter();

    return MaterialApp.router(
      title: 'Sangam',
      theme: buildAppTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child!,
      ),
    );
  }
}
