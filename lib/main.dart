import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/notifiers/preferences_notifier.dart';
import 'package:myledger/repositories/contact_repository.dart';
import 'package:myledger/repositories/payment_repository.dart';
import 'package:myledger/services/database_service.dart';
import 'package:myledger/viewmodels/contact_viewmodel.dart';
import 'package:myledger/viewmodels/edit_payment_viewmodel.dart';
import 'package:myledger/viewmodels/new_contact_viewmodel.dart';
import 'package:myledger/viewmodels/new_payment_viewmodel.dart';
import 'package:myledger/viewmodels/payment_viewmodel.dart';
import 'package:myledger/views/edit_payment_view.dart';
import 'package:myledger/views/home_view.dart';
import 'package:myledger/views/contact_view.dart';
import 'package:myledger/views/new_contact_view.dart';
import 'package:myledger/views/new_payment_view.dart';
import 'package:myledger/views/payment_view.dart';
import 'package:myledger/views/preferences_view.dart';
import 'package:myledger/viewmodels/home_viewmodel.dart';
import 'package:myledger/viewmodels/preferences_viewmodel.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  if (Platform.isWindows) {
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
  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeView(
          viewModel: HomeViewModel(contactRepository: context.read()),
        ),
      ),
      GoRoute(
        path: '/preferences',
        builder: (context, state) => PreferencesView(
          viewModel: PreferencesViewModel(contactRepository: context.read()),
        ),
      ),
      GoRoute(
        path: '/new_contact',
        builder: (context, state) =>
            NewContactView(viewModel: NewContactViewModel()),
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) {
          final args = state.extra as ContactArguments;

          return ContactView(
            viewModel: ContactViewModel(
              args.contact,
              paymentRepository: context.read(),
              contactRepository: context.read(),
            ),
          );
        },
      ),
      GoRoute(
        path: '/new_payment',
        builder: (context, state) {
          final args = state.extra as NewPaymentArguments;

          return NewPaymentView(viewModel: NewPaymentViewModel(args.contact));
        },
      ),
      GoRoute(
        path: '/edit_payment',
        builder: (context, state) {
          final args = state.extra as EditPaymentArguments;

          return EditPaymentView(
            viewModel: EditPaymentViewModel(
              args.payment,
              paymentRepository: context.read(),
            ),
          );
        },
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final args = state.extra as PaymentArguments;

          return PaymentView(
            viewModel: PaymentViewModel(
              args.payment,
              args.contact,
              paymentRepository: context.read(),
              contactRepository: context.read(),
            ),
          );
        },
      ),
    ],
  );

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
