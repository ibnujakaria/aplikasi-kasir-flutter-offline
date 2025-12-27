import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'modules/main_screen.dart';
import 'core/database/database.service.dart';

void main() async {
  // Ensure Flutter is ready to handle async calls before runApp
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows) {
    // Initialize FFI for Desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    print("Database Engine: FFI (Desktop)");
  } else {
    print("Database Engine: Native (Android/iOS)");
  }

  print("Initializing database...");
  final dbService = DatabaseService();
  await dbService.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kasir Resto',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MainScreen(),
    );
  }
}
