import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myledger/models/preferences_model.dart';
import 'package:myledger/viewmodels/preferences_viewmodel.dart';

class PreferencesView extends StatefulWidget {
  final PreferencesViewModel viewModel;
  const PreferencesView({super.key, required this.viewModel});

  @override
  State<PreferencesView> createState() => _PreferencesViewState();
}

class _PreferencesViewState extends State<PreferencesView> {
  Future<void> _eraseDataDialogBuilder(BuildContext context) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("Apagar dados?"),
          content: Text("Dados excluidos não poderão ser reconstituidos."),
          actions: [
            IconButton(
              onPressed: () {
                widget.viewModel.eraseData();
                context.pop();
              },
              icon: Icon(Icons.remove),
              style: IconButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: ColorScheme.of(context).primary,
          iconTheme: IconThemeData(color: ColorScheme.of(context).onPrimary),
          title: Text(
            'Preferências',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ColorScheme.of(context).onPrimary,
            ),
          ),
          leading: BackButton(
            onPressed: () {
              context.pop<PreferencesResult>(
                PreferencesResult(actions: widget.viewModel.actions),
              );
            },
          ),
        ),
        body: ListView(
          children: <Widget>[
            Preference(
              title: 'Usar modo noturno',
              enabled: widget.viewModel.isDarkTheme,
              onDisable: () => widget.viewModel.setDarkTheme(false),
              onEnable: () => widget.viewModel.setDarkTheme(true),
            ),
            Preference(
              unavailable: Platform.isWindows,
              title: 'Usar contatos locais',
              enabled: widget.viewModel.isUsingLocalContacts,
              onDisable: () => widget.viewModel.setUsingLocalContacts(false),
              onEnable: () => widget.viewModel.setUsingLocalContacts(true),
            ),
            Action(
              icon: Icons.delete,
              title: 'Apagar dados',
              onClick: () => _eraseDataDialogBuilder(context),
            ),
          ],
        ),
      ),
    );
  }
}

class Preference extends StatelessWidget {
  final String title;
  final bool enabled;
  final bool unavailable;
  final void Function()? onEnable;
  final void Function()? onDisable;

  const Preference({
    super.key,
    required this.title,
    this.unavailable = false,
    required this.enabled,
    required this.onDisable,
    required this.onEnable,
  });

  @override
  Widget build(BuildContext context) => unavailable
      ? Container()
      : Padding(
          padding: EdgeInsetsGeometry.directional(start: 65, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: enabled ? onDisable : onEnable,
                icon: enabled
                    ? Icon(Icons.check_box)
                    : Icon(Icons.check_box_outline_blank),
              ),
              Text(title),
            ],
          ),
        );
}

class Action extends StatelessWidget {
  final String title;
  final bool unavailable;
  final IconData icon;
  final void Function()? onClick;

  const Action({
    super.key,
    required this.title,
    this.unavailable = false,
    required this.icon,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) => unavailable
      ? Container()
      : Padding(
          padding: EdgeInsetsGeometry.directional(start: 65, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(onPressed: onClick, icon: Icon(icon)),
              Text(title),
            ],
          ),
        );
}
