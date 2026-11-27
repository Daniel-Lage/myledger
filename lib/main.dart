import 'dart:io';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myledger/notifiers/preferences_notifier.dart';
import 'package:myledger/repositories/contact_repository.dart';
import 'package:myledger/repositories/payment_repository.dart';
import 'package:myledger/routing/router.dart';
import 'package:myledger/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/open.dart' as sqlite3_open;
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux) {
    sqlite3_open.open.overrideFor(sqlite3_open.OperatingSystem.linux, () {
      try {
        return DynamicLibrary.open('libsqlite3.so');
      } catch (_) {
        return DynamicLibrary.open('libsqlite3.so.0');
      }
    });
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreferenceNotifier()),
        Provider(
          create: (_) => ContactRepository(database: DatabaseService.instance),
        ),
        Provider(
          create: (_) => PaymentRepository(database: DatabaseService.instance),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = router();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    title: 'MyLedger',
    routerConfig: _router,
    theme: ThemeData(
      colorScheme: ColorScheme(
        primary: Colors.green,
        onPrimary: Provider.of<PreferenceNotifier>(context).isDarkTheme
            ? Colors.white
            : Colors.black,
        secondary: Provider.of<PreferenceNotifier>(context).isDarkTheme
            ? const Color.fromARGB(255, 30, 30, 30)
            : const Color.fromARGB(255, 225, 225, 225),
        onSecondary: Provider.of<PreferenceNotifier>(context).isDarkTheme
            ? const Color.fromARGB(255, 200, 200, 200)
            : const Color.fromARGB(255, 55, 55, 55),
        error: Colors.red,
        onError: Colors.white,
        surface: Provider.of<PreferenceNotifier>(context).isDarkTheme
            ? Colors.black
            : Colors.white,
        onSurface: Provider.of<PreferenceNotifier>(context).isDarkTheme
            ? Colors.white
            : Colors.black,
        brightness: Provider.of<PreferenceNotifier>(context).isDarkTheme
            ? Brightness.dark
            : Brightness.light,
      ),
    ),
  );
}
