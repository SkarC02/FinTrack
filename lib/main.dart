import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sic_app/core/services/fcm_service.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('es', null);

  await FcmService.instance.init();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      debugPrint(' Notificación: ${message.notification!.title}');
      debugPrint(' Cuerpo: ${message.notification!.body}');

      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Text('🔔 ', style: TextStyle(fontSize: 18)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.notification!.title ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    Text(
                      message.notification!.body ?? '',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ]),
            backgroundColor: const Color(0xFF1E293B),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('📲 Notificación tocada: ${message.notification?.title}');
  });

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: SICApp(),
    ),
  );
}

class SICApp extends ConsumerWidget {
  const SICApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'FinTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}