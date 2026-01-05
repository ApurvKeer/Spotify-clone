import 'package:flutter/material.dart';
import 'domain/app_routes.dart';
import 'data/database_builder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Build fresh database from scratch
  await DatabaseBuilder().buildDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music App',
      theme: ThemeData.dark(useMaterial3: true),
      initialRoute: AppRoutes.splash_page,
      routes: AppRoutes().getRoutes(),
    );
  }
}
