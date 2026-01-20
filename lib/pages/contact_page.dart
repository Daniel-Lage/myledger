import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myledger/components/payment_component.dart';
import 'package:myledger/currency_input_formatter.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/services/database_service.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  bool _updated = false;
  final String initialText = CurrencyInputFormatter.formatter.format(0);
  ContactObject? _contact;
  List<PaymentObject> _paymentsList = <PaymentObject>[];
  final DatabaseService _databaseService = DatabaseService.instance;

  int toValue = 0;
  int fromValue = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ContactArguments args =
          ModalRoute.of(context)?.settings.arguments as ContactArguments;

      setState(() {
        _contact = args.contact;
      });
      loadState();
    });
  }

  Future<void> loadState() async {
    final paymentsTable = await _databaseService.getContactsPayments(
      _contact!.name,
    );

    setState(() {
      _paymentsList = paymentsTable;
    });
  }

  Future<void> _goToNewPayment() async {
    NewPaymentResults args =
        await Navigator.of(context).pushNamed(
              "/new_payment",
              arguments: NewPaymentArguments(contact: _contact!),
            )
            as NewPaymentResults;

    if (args.payment == null) return;

    setState(() {
      _paymentsList.add(args.payment!);
      _updated = true;
    });
  }

  void _removeContact(String name) {
    _databaseService.removeContact(name);
  }

  Future<void> _removeContactDialogBuilder(BuildContext context, String name) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("Excluir contato?"),
          content: Text("As transações armazenadas também serão perdidas."),
          actions: [
            IconButton(
              onPressed: () {
                _removeContact(name);
                Navigator.of(context).pop();
                Navigator.of(context).pop(
                  ContactResults(
                    contact: _contact!,
                    action: ContactPageAction.delete,
                  ),
                );
              },
              icon: Icon(Icons.remove),
              style: IconButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      );

  Widget loading() => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
    ),
    body: Center(
      child: ListView(
        children: <Widget>[
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width - 100,
                  child: TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Valor',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => _contact == null
      ? loading()
      : Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(
              "Contato",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onPrimary,
            ),

            leading: BackButton(
              onPressed: () {
                Navigator.of(context).pop(
                  ContactResults(
                    contact: _contact!,
                    action: _updated
                        ? ContactPageAction.update
                        : ContactPageAction.none,
                  ),
                );
              },
            ),
          ),
          body: Center(
            child: ListView(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.person, size: 100),

                      Text(
                        formatDebt(_contact!.debt, _contact!.name),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),

                Text(
                  'Transações',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                ..._paymentsList.map(
                  (payment) => PaymentComponent(payment: payment),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      width: MediaQuery.of(context).size.width - 100,
                      height: 50,
                      child: TextButton(
                        onPressed: () => _removeContactDialogBuilder(
                          context,
                          _contact!.name,
                        ),
                        child: Text("Excluir Contato"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _goToNewPayment,
            icon: Icon(Icons.add),
            iconSize: 40,
            color: Theme.of(context).colorScheme.onPrimary,
            padding: EdgeInsetsGeometry.all(10),
          ),
        );
}

String formatDebt(int debt, String name) {
  String debtString = CurrencyInputFormatter.formatter.format(debt.abs() / 100);
  if (debt > 0) return "$name te deve $debtString";
  if (debt < 0) return "Você deve $debtString a $name";
  return "Você não tem divida com $name";
}
