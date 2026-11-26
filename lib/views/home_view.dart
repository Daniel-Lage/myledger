import 'package:flutter/material.dart';
import 'package:myledger/components/contact_component.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/preferences_model.dart';
import 'package:provider/provider.dart';
import 'package:myledger/viewmodels/home_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().load();
    });
  }

  Future<void> _goToNewContact() async {
    NewContactResult result =
        await Navigator.of(context).pushNamed("/new_contact")
            as NewContactResult;

    if (result.contact == null) return;
    if (mounted) {

    await context.read<HomeViewModel>().addContact(result.contact!);
    }
  }

  Future<void> _goToContact(ContactObject contact) async {
    final result = await Navigator.of(context).pushNamed(
      '/contact',
      arguments: ContactArguments(contact: contact),
    ) as ContactResult;
    if (mounted) {
    await context.read<HomeViewModel>().handleContactResult(result);
    }
  }

  Future<void> _goToPrefs() async {
    final result = await Navigator.of(context).pushNamed("/preferences")
        as PreferencesResult;

    if (result.actions.updatedIsUsingLocalContacts ||
        result.actions.dataErased) {
    if (mounted) {
      await context.read<HomeViewModel>().load();
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final compareKey = viewModel.compareKey;
    final isReversed = viewModel.isReversed;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorScheme.of(context).primary,
        iconTheme: IconThemeData(
          color: ColorScheme.of(context).onPrimary,
          size: 35,
        ),
        title: Text(
          'Início',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: ColorScheme.of(context).onPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: _goToPrefs,
          icon: Icon(Icons.settings),
          padding: EdgeInsetsGeometry.all(5),
        ),
      ),
      body: ListView(
        children: [
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: ColorScheme.of(context).secondary),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => viewModel.changeSort(
                        ContactCompareKey.name,
                      ),
                      child: Text(
                        "Nome",
                        style: compareKey == ContactCompareKey.name
                            ? TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: ColorScheme.of(context).onPrimary,
                              )
                            : TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: ColorScheme.of(context).onSecondary,
                              ),
                      ),
                    ),
                    Icon(
                      isReversed
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: compareKey == ContactCompareKey.name
                          ? ColorScheme.of(context).onSecondary
                          : Colors.transparent,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => viewModel.changeSort(
                        ContactCompareKey.balance,
                      ),
                      child: Text(
                        "Saldo",
                        style: compareKey == ContactCompareKey.balance
                            ? TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: ColorScheme.of(context).onPrimary,
                              )
                            : TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: ColorScheme.of(context).onSecondary,
                              ),
                      ),
                    ),
                    Icon(
                      isReversed
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: compareKey == ContactCompareKey.balance
                          ? ColorScheme.of(context).onSecondary
                          : Colors.transparent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          ...context.watch<HomeViewModel>().contacts.map(
            (contact) => ContactComponent(
              contact: contact,
              goTo: () => _goToContact(contact),
            ),
          ),
        ],
      ),
      floatingActionButton: IconButton(
        style: IconButton.styleFrom(
          backgroundColor: ColorScheme.of(context).primary,
        ),
        onPressed: _goToNewContact,
        icon: Icon(Icons.add),
        iconSize: 40,
        color: ColorScheme.of(context).onPrimary,
        padding: EdgeInsetsGeometry.all(10),
      ),
    );
  }
}
