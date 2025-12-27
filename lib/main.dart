import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Imports for your new modules
import 'modules/layout/main_screen.view.dart';
import 'modules/setup/setup.view.dart';
import 'modules/setup/setup.service.dart';
import 'core/database/database.service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize the database connection
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // The Gatekeeper logic starts here
      home: FutureBuilder<bool>(
        future: SetupService().isAppInitialized(),
        builder: (context, snapshot) {
          // While checking the database, show a loading screen
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If data is true, go to Dashboard; otherwise, go to Setup
          if (snapshot.hasData && snapshot.data == true) {
            return const MainScreen();
          } else {
            return const SetupView();
          }
        },
      ),
    );
  }
}
