import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_project/notifiers/preferences_notifier.dart';
import 'package:flutter_project/pages/home_page.dart';
import 'package:flutter_project/pages/contact_page.dart';
import 'package:flutter_project/pages/new_contact_page.dart';
import 'package:flutter_project/pages/new_transaction_page.dart';
import 'package:flutter_project/pages/settings_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => PreferenceNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flutter Project',
    theme: ThemeData(
      colorScheme: ColorScheme(
        primary: Provider.of<PreferenceNotifier>(context).isDarkTheme
            ? const Color(0xFF77992A)
            : const Color(0xFFB8E555),
        onPrimary: Provider.of<PreferenceNotifier>(context).isDarkTheme
            ? Colors.white
            : Colors.black,
        secondary: Provider.of<PreferenceNotifier>(context).isDarkTheme
            ? Colors.black
            : Colors.white,
        onSecondary: Provider.of<PreferenceNotifier>(context).isDarkTheme
            ? Colors.white
            : Colors.black,
        error: Colors.red,
        onError: Colors.black,
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
    initialRoute: '/',
    routes: {
      '/': (context) => HomePage(),
      '/contact': (context) => ContactPage(),
      '/settings': (context) => SettingsPage(),
      '/new_contact': (context) => NewContactPage(),
      '/new_transaction': (context) => NewTransactionPage(),
    },
  );
}
