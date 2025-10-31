import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/currency_input_formatter.dart';
import 'package:flutter_project/models/contact_model.dart';
import 'package:flutter_project/models/transaction_model.dart';
import 'package:flutter_project/services/database_service.dart';

class NewTransactionPage extends StatefulWidget {
  const NewTransactionPage({super.key});

  @override
  State<NewTransactionPage> createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  final TextEditingController _toController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();

  final String initialText = CurrencyInputFormatter.formatter.format(0);

  ContactObject? _contact;

  int toValue = 0;
  int fromValue = 0;

  @override
  void initState() {
    super.initState();
    _toController.text = initialText;
    _fromController.text = initialText;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Object? args = ModalRoute.of(context)?.settings.arguments;

      if (args == null) return;

      Map<String, Object> argsMap = args as Map<String, Object>;

      ContactObject selectedContact = argsMap["contact"] as ContactObject;

      setState(() {
        _contact = selectedContact;
      });
    });
  }

  void _addTransaction() {
    if (_contact == null) return;

    final value = toValue == 0 ? fromValue : -toValue;

    final transaction = TransactionObject(
      contactName: _contact!.name,
      value: value.abs(),
      type: toValue == 0 ? TransactionType.plus : TransactionType.minus,
    );

    setState(() {
      _contact?.debt -= value;
      toValue = 0;
      fromValue = 0;
    });

    _databaseService.updateContact(_contact!);
    _databaseService.addTransaction(transaction);
    _toController.text = initialText;
    _fromController.text = initialText;

    Navigator.pop(context, {"transaction": transaction});
  }

  String text = "";

  Widget loading() => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
    ),
  );

  @override
  Widget build(BuildContext context) => _contact == null
      ? loading()
      : Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            title: Text(
              'Registrar Transação',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
          body: Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 75,
                  child: TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyInputFormatter(),
                    ],
                    controller: _toController,
                    onChanged: (text) {
                      setState(() {
                        toValue =
                            (CurrencyInputFormatter.formatter.parse(text) * 100)
                                .floor();
                      });
                    },
                    onSubmitted: (_) => toValue == 0 && fromValue == 0
                        ? null
                        : {_addTransaction()},
                    readOnly: fromValue != 0,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Você',
                    ),
                  ),
                ),
                IconButton(
                  color: toValue == 0 && fromValue == 0
                      ? Colors.grey
                      : Theme.of(context).colorScheme.primary,
                  constraints: BoxConstraints(),
                  onPressed: toValue == 0 && fromValue == 0
                      ? null
                      : () => _addTransaction(),
                  icon: Icon(
                    toValue == 0 && fromValue == 0
                        ? Icons.remove
                        : toValue == 0
                        ? Icons.arrow_back
                        : Icons.arrow_forward,
                  ),
                  iconSize: 25,
                  padding: EdgeInsets.zero,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 75,
                  child: TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyInputFormatter(),
                    ],
                    controller: _fromController,
                    onChanged: (text) {
                      setState(() {
                        fromValue =
                            (CurrencyInputFormatter.formatter.parse(text) * 100)
                                .floor();
                      });
                    },
                    onSubmitted: (_) => toValue == 0 && fromValue == 0
                        ? null
                        : _addTransaction(),
                    readOnly: toValue != 0,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: _contact!.name,
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: text == "" ? null : () => _addTransaction(),
            icon: Icon(Icons.save),
            iconSize: 30,
            color: Theme.of(context).colorScheme.onPrimary,
            padding: EdgeInsetsGeometry.all(15),
          ),
        );
}
