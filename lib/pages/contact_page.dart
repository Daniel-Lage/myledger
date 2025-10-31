import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/components/transaction_component.dart';
import 'package:flutter_project/currency_input_formatter.dart';
import 'package:flutter_project/models/contact_model.dart';
import 'package:flutter_project/models/transaction_model.dart';
import 'package:flutter_project/services/database_service.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  bool _updated = false;
  final String initialText = CurrencyInputFormatter.formatter.format(0);
  ContactObject? _contact;
  List<TransactionObject> _transactionsList = <TransactionObject>[];
  final DatabaseService _databaseService = DatabaseService.instance;

  int toValue = 0;
  int fromValue = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Object? args = ModalRoute.of(context)?.settings.arguments;

      if (args == null) return;

      Map<String, Object> argsMap = args as Map<String, Object>;

      ContactObject selectedContact = argsMap["contact"] as ContactObject;

      setState(() {
        _contact = selectedContact;
      });
      loadState();
    });
  }

  Future<void> loadState() async {
    final transactionsTable = await _databaseService.getContactsTransactions(
      _contact!.name,
    );

    setState(() {
      _transactionsList = transactionsTable;
    });
  }

  Future<void> _goToNewTransaction() async {
    Object? args = await Navigator.of(
      context,
    ).pushNamed("/new_transaction", arguments: {"contact": _contact!});

    if (args == null) return;

    Map<String, Object> argsMap = args as Map<String, Object>;

    final newTransaction = argsMap["transaction"] as TransactionObject;

    setState(() {
      _transactionsList.add(newTransaction);
      _updated = true;
    });
  }

  void _removeContact(String name) {
    _databaseService.removeContact(name);
    Navigator.pop(context, {
      "contact": _contact!,
      "action": ContactPageAction.delete,
    });
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
                Navigator.pop(context, {
                  "contact": _contact!,
                  "action": ContactPageAction.delete,
                });
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
                Navigator.pop(context, {
                  "contact": _contact!,
                  "action": _updated
                      ? ContactPageAction.update
                      : ContactPageAction.none,
                });
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
                ..._transactionsList.map(
                  (transaction) =>
                      TransactionComponent(transaction: transaction),
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
            onPressed: _goToNewTransaction,
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
