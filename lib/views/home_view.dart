import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myledger/components/contact_component.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/models/preferences_model.dart';
import 'package:myledger/viewmodels/home_viewmodel.dart';

class HomeView extends StatefulWidget {
  final HomeViewModel viewModel;
  const HomeView({super.key, required this.viewModel});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Future<void> _goToNewContact() async {
    final result = await context.push<NewContactResult>('/new_contact');

    print(result?.contact);

    if (result?.contact == null) return;

    await widget.viewModel.addContact(result!.contact!);
  }

  Future<void> _goToContact(ContactObject contact) async {
    final result = await context.push<ContactResult>(
      '/contact',
      extra: ContactArguments(contact: contact),
    );

    if (result == null) return;
    await widget.viewModel.handleContactResult(result);
  }

  Future<void> _goToPrefs() async {
    final result = await context.push<PreferencesResult>('/preferences');

    if (result == null) return;
    if (result.actions.updatedIsUsingLocalContacts ||
        result.actions.dataErased) {
      await widget.viewModel.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final compareKey = widget.viewModel.compareKey;
    final isReversed = widget.viewModel.isReversed;

    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, child) => Scaffold(
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
              decoration: BoxDecoration(
                color: ColorScheme.of(context).tertiary,
                border: Border(
                  bottom: BorderSide(
                    color: ColorScheme.of(context).outline,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () =>
                            widget.viewModel.changeSort(ContactCompareKey.name),
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
                        onPressed: () => widget.viewModel.changeSort(
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
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context).secondary,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "A Receber",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          PaymentObject.formatCurrency(
                            widget.viewModel.contacts.fold(
                              0,
                              (total, contact) =>
                                  total +
                                  (contact.balance > 0 ? contact.balance : 0),
                            ),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context).tertiary,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "A Pagar",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          PaymentObject.formatCurrency(
                            widget.viewModel.contacts.fold(
                              0,
                              (total, contact) =>
                                  total +
                                  (contact.balance < 0 ? contact.balance : 0),
                            ),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            ...widget.viewModel.contacts.map(
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
      ),
    );
  }
}
