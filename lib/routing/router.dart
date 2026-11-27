import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myledger/routing/routes.dart';
import 'package:myledger/viewmodels/contact_viewmodel.dart';
import 'package:myledger/viewmodels/edit_payment_viewmodel.dart';
import 'package:myledger/viewmodels/home_viewmodel.dart';
import 'package:myledger/viewmodels/new_contact_viewmodel.dart';
import 'package:myledger/viewmodels/new_payment_viewmodel.dart';
import 'package:myledger/viewmodels/payment_viewmodel.dart';
import 'package:myledger/viewmodels/preferences_viewmodel.dart';
import 'package:myledger/views/contact_view.dart';
import 'package:myledger/views/edit_payment_view.dart';
import 'package:myledger/views/home_view.dart';
import 'package:myledger/views/new_contact_view.dart';
import 'package:myledger/views/new_payment_view.dart';
import 'package:myledger/views/payment_view.dart';
import 'package:myledger/views/preferences_view.dart';
import 'package:provider/provider.dart';

Widget _changeNotifierRoute<T extends ChangeNotifier>({
  required T Function(BuildContext context) create,
  required Widget Function(T viewModel) builder,
}) => ChangeNotifierProvider<T>(
  create: create,
  child: Consumer<T>(
    builder: (context, viewModel, child) => builder(viewModel),
  ),
);

GoRouter router() => GoRouter(
  routes: [
    GoRoute(
      path: homePath,
      builder: (context, state) => _changeNotifierRoute<HomeViewModel>(
        create: (context) => HomeViewModel(contactRepository: context.read()),
        builder: (viewModel) => HomeView(viewModel: viewModel),
      ),
    ),
    GoRoute(
      path: preferencesPath,
      builder: (context, state) => _changeNotifierRoute<PreferencesViewModel>(
        create: (context) =>
            PreferencesViewModel(contactRepository: context.read()),
        builder: (viewModel) => PreferencesView(viewModel: viewModel),
      ),
    ),
    GoRoute(
      path: newContactPath,
      builder: (context, state) => _changeNotifierRoute<NewContactViewModel>(
        create: (context) => NewContactViewModel(),
        builder: (viewModel) => NewContactView(viewModel: viewModel),
      ),
    ),
    GoRoute(
      path: contactPath,
      builder: (context, state) {
        final extra = state.extra as ContactExtra;

        return _changeNotifierRoute<ContactViewModel>(
          create: (context) => ContactViewModel(
            extra.contact,
            paymentRepository: context.read(),
            contactRepository: context.read(),
          ),
          builder: (viewModel) => ContactView(viewModel: viewModel),
        );
      },
    ),
    GoRoute(
      path: newPaymentPath,
      builder: (context, state) {
        final extra = state.extra as NewPaymentExtra;

        return _changeNotifierRoute<NewPaymentViewModel>(
          create: (context) => NewPaymentViewModel(extra.contact),
          builder: (viewModel) => NewPaymentView(viewModel: viewModel),
        );
      },
    ),
    GoRoute(
      path: editPaymentPath,
      builder: (context, state) {
        final extra = state.extra as EditPaymentExtra;

        return _changeNotifierRoute<EditPaymentViewModel>(
          create: (context) => EditPaymentViewModel(
            extra.payment,
            paymentRepository: context.read(),
          ),
          builder: (viewModel) => EditPaymentView(viewModel: viewModel),
        );
      },
    ),
    GoRoute(
      path: paymentPath,
      builder: (context, state) {
        final extra = state.extra as PaymentExtra;

        return _changeNotifierRoute<PaymentViewModel>(
          create: (context) => PaymentViewModel(
            extra.payment,
            extra.contact,
            paymentRepository: context.read(),
            contactRepository: context.read(),
          ),
          builder: (viewModel) => PaymentView(viewModel: viewModel),
        );
      },
    ),
  ],
);
