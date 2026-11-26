import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myledger/currency_input_formatter.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/viewmodels/payment_viewmodels.dart';

class EditPaymentView extends StatefulWidget {
  const EditPaymentView({super.key});

  @override
  State<EditPaymentView> createState() => _EditPaymentViewState();
}

class _EditPaymentViewState extends State<EditPaymentView> {
  EditPaymentPageAction _action = EditPaymentPageAction.none;

  final TextEditingController _toController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final String initialText = CurrencyInputFormatter.formatter.format(0);

  PaymentObject? _payment;

  int sendingValue = 0;
  int receivingValue = 0;

  EditPaymentViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _toController.text = initialText;
    _fromController.text = initialText;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      EditPaymentArguments args =
          ModalRoute.of(context)?.settings.arguments as EditPaymentArguments;

      setState(() {
        _payment = args.payment;

        _viewModel = EditPaymentViewModel(args.payment);

        if (args.payment.type == PaymentType.sending) {
          sendingValue = args.payment.value;
          _toController.text = CurrencyInputFormatter.formatter.format(
            args.payment.value / 100,
          );
        } else {
          receivingValue = args.payment.value;

          _fromController.text = CurrencyInputFormatter.formatter.format(
            args.payment.value / 100,
          );
        }

        if (args.payment.description != null) {
          _descriptionController.text = args.payment.description!;
        }
      });
    });
  }

  Future<void> _editPayment() async {
    _viewModel!.setSendingValue(sendingValue);
    _viewModel!.setReceivingValue(receivingValue);
    _viewModel!.setDescription(_descriptionController.text);
    final payment = _viewModel!.createEditedPayment();

    setState(() {
      sendingValue = 0;
      receivingValue = 0;
    });

    _toController.text = initialText;
    _fromController.text = initialText;

    Navigator.of(
      context,
    ).pop(EditPaymentResult(payment: payment, action: _action));
  }

  String text = "";

  Widget loading() => Scaffold(
    appBar: AppBar(
      backgroundColor: ColorScheme.of(context).primary,
      iconTheme: IconThemeData(color: ColorScheme.of(context).onPrimary),
    ),
  );

  @override
  Widget build(BuildContext context) => _payment == null
      ? loading()
      : Scaffold(
          appBar: AppBar(
            backgroundColor: ColorScheme.of(context).primary,
            iconTheme: IconThemeData(color: ColorScheme.of(context).onPrimary),
            title: Text(
              'Alterar Pagamento',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ColorScheme.of(context).onPrimary,
              ),
            ),
            leading: BackButton(
              onPressed: () {
                Navigator.of(context).pop(
                  EditPaymentResult(
                    payment: null,
                    action: EditPaymentPageAction.none,
                  ),
                );
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
                          final newSendingValue =
                              (CurrencyInputFormatter.formatter.parse(
                                        text == "" ? "0" : text,
                                      ) *
                                      100)
                                  .floor();

                          if (newSendingValue != sendingValue) {
                            setState(() {
                              _action = EditPaymentPageAction.value;
                              sendingValue = newSendingValue;
                            });
                          }
                        },
                        onSubmitted: sendingValue == 0 && receivingValue == 0
                            ? null
                            : (_) => _editPayment(),
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
                          final newReceivingValue =
                              (CurrencyInputFormatter.formatter.parse(text) *
                                      100)
                                  .floor();
                          if (receivingValue != newReceivingValue) {
                            setState(() {
                              _action = EditPaymentPageAction.value;
                              receivingValue = newReceivingValue;
                            });
                          }
                        },
                        onSubmitted: sendingValue == 0 && receivingValue == 0
                            ? null
                            : (_) => _editPayment(),
                        readOnly: sendingValue != 0,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: _payment!.contactName,
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
                        : (_) => _editPayment(),
                    onChanged: (text) {
                      if (_action == EditPaymentPageAction.none) {
                        setState(() {
                          _action = EditPaymentPageAction.description;
                        });
                      }
                    },
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
                : () => _editPayment(),
            icon: Icon(Icons.save),
            iconSize: 30,
            color: ColorScheme.of(context).onPrimary,
            padding: EdgeInsetsGeometry.all(15),
          ),
        );
}
