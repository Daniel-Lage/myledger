import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myledger/currency_input_formatter.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/services/database_service.dart';

class NewPaymentPage extends StatefulWidget {
  const NewPaymentPage({super.key});

  @override
  State<NewPaymentPage> createState() => _NewPaymentPageState();
}

class _NewPaymentPageState extends State<NewPaymentPage> {
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
      NewPaymentArguments args =
          ModalRoute.of(context)?.settings.arguments as NewPaymentArguments;

      setState(() {
        _contact = args.contact;
      });
    });
  }

  void _addPayment() {
    if (_contact == null) return;

    final value = toValue == 0 ? fromValue : -toValue;

    final payment = PaymentObject(
      contactName: _contact!.name,
      value: value.abs(),
      type: toValue == 0 ? PaymentType.plus : PaymentType.minus,
    );

    setState(() {
      _contact?.debt -= value;
      toValue = 0;
      fromValue = 0;
    });

    _databaseService.updateContact(_contact!);
    _databaseService.addPayment(payment);
    _toController.text = initialText;
    _fromController.text = initialText;

    Navigator.of(context).pop(NewPaymentResults(payment: payment));
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
              'Registrar Pagamento',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            leading: BackButton(
              onPressed: () {
                Navigator.of(context).pop(NewPaymentResults(payment: null));
              },
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
                            (CurrencyInputFormatter.formatter.parse(
                                      text == "" ? "0" : text,
                                    ) *
                                    100)
                                .floor();
                      });
                    },
                    onSubmitted: toValue == 0 && fromValue == 0
                        ? null
                        : (_) => _addPayment(),
                    readOnly: fromValue != 0,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Você',
                    ),
                  ),
                ),
                Icon(
                  toValue == 0 && fromValue == 0
                      ? Icons.remove
                      : toValue == 0
                      ? Icons.arrow_back
                      : Icons.arrow_forward,
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
                    onSubmitted: toValue == 0 && fromValue == 0
                        ? null
                        : (_) => _addPayment(),
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
            onPressed: toValue == 0 && fromValue == 0
                ? null
                : () => _addPayment(),
            icon: Icon(Icons.save),
            iconSize: 30,
            color: Theme.of(context).colorScheme.onPrimary,
            padding: EdgeInsetsGeometry.all(15),
          ),
        );
}
