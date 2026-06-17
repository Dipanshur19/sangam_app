import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'router.dart';
import 'presentation/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Firebase — uncomment after flutterfire configure
  // try {
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // } catch (e) { debugPrint('Firebase skipped: $e'); }

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
