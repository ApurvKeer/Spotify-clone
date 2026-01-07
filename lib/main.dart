/// Main Entry Point
///
/// This file contains:
/// - App initialization
/// - Riverpod provider scope setup
/// - Material app configuration
/// - Root navigation
/// - Dependency injection setup
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'presentation/pages/splash_screen.dart';
import 'core/services/hive_storage_service.dart';
import 'core/services/firestore_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirestoreConfig.initialize();
  await HiveStorageService.instance.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spotify Clone',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: Colors.orange,
          surface: const Color(0xFF1a1a1a),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a1a1a),
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
