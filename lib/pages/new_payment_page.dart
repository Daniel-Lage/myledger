import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myledger/currency_input_formatter.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';

class NewPaymentPage extends StatefulWidget {
  const NewPaymentPage({super.key});

  @override
  State<NewPaymentPage> createState() => _NewPaymentPageState();
}

class _NewPaymentPageState extends State<NewPaymentPage> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final String initialText = CurrencyInputFormatter.formatter.format(0);

  ContactObject? _contact;

  int sendingValue = 0;
  int receivingValue = 0;
  int descriptionValue = 0;

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

  Future<void> _addPayment() async {
    if (_contact == null) return;

    final value = sendingValue == 0 ? receivingValue : -sendingValue;

    final payment = PaymentObject(
      contactName: _contact!.name,
      value: value.abs(),
      type: sendingValue == 0 ? PaymentType.receiving : PaymentType.sending,
      createdAt: DateTime.now(),
      description: _descriptionController.text,
    );

    setState(() {
      sendingValue = 0;
      receivingValue = 0;
    });

    _toController.text = initialText;
    _fromController.text = initialText;

    Navigator.of(context).pop(NewPaymentResult(payment: payment));
  }

  String text = "";

  Widget loading() => Scaffold(
    appBar: AppBar(
      backgroundColor: ColorScheme.of(context).primary,
      iconTheme: IconThemeData(color: ColorScheme.of(context).onPrimary),
    ),
  );

  @override
  Widget build(BuildContext context) => _contact == null
      ? loading()
      : Scaffold(
          appBar: AppBar(
            backgroundColor: ColorScheme.of(context).primary,
            iconTheme: IconThemeData(color: ColorScheme.of(context).onPrimary),
            title: Text(
              'Registrar Pagamento',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ColorScheme.of(context).onPrimary,
              ),
            ),
            leading: BackButton(
              onPressed: () {
                Navigator.of(context).pop(NewPaymentResult(payment: null));
              },
            ),
          ),
          body: Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 10),

            child: Column(
              spacing: 20,
              children: [
                Row(
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
                            sendingValue =
                                (CurrencyInputFormatter.formatter.parse(
                                          text == "" ? "0" : text,
                                        ) *
                                        100)
                                    .floor();
                          });
                        },
                        onSubmitted: sendingValue == 0 && receivingValue == 0
                            ? null
                            : (_) => _addPayment(),
                        readOnly: receivingValue != 0,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Você',
                        ),
                      ),
                    ),
                    Icon(
                      sendingValue == 0 && receivingValue == 0
                          ? Icons.remove
                          : sendingValue == 0
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
                            receivingValue =
                                (CurrencyInputFormatter.formatter.parse(text) *
                                        100)
                                    .floor();
                          });
                        },
                        onSubmitted: sendingValue == 0 && receivingValue == 0
                            ? null
                            : (_) => _addPayment(),
                        readOnly: sendingValue != 0,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: _contact!.name,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 105,

                  child: TextField(
                    controller: _descriptionController,
                    onSubmitted: sendingValue == 0 && receivingValue == 0
                        ? null
                        : (_) => _addPayment(),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Descrição (opcional)',
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: ColorScheme.of(context).primary,
            ),
            onPressed: sendingValue == 0 && receivingValue == 0
                ? null
                : () => _addPayment(),
            icon: Icon(Icons.save),
            iconSize: 30,
            color: ColorScheme.of(context).onPrimary,
            padding: EdgeInsetsGeometry.all(15),
          ),
        );
}
