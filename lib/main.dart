import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app.dart';
import 'core/utils/logger.dart';
import 'firebase_options.dart';
import 'services/notifications/notification_service.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ));

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initializeaza timezone pentru notificari programate
      tz.initializeTimeZones();

      await Hive.initFlutter();
      await NotificationService.instance.initialize();
      await NotificationService.instance.requestPermissions();
      AppLogger.init();

      runApp(
        const ProviderScope(
          child: SmartDriverApp(),
        ),
      );
    },
    (error, stack) {
      AppLogger.error('Unhandled error', error, stack);
    },
  );
}
