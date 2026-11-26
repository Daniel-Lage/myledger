import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:myledger/currency_input_formatter.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/viewmodels/new_payment_viewmodel.dart';

class NewPaymentView extends StatefulWidget {
  final NewPaymentViewModel viewModel;
  const NewPaymentView({super.key, required this.viewModel});

  @override
  State<NewPaymentView> createState() => _NewPaymentViewState();
}

class _NewPaymentViewState extends State<NewPaymentView> {
  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _sendingController = TextEditingController(
    text: CurrencyInputFormatter.formatter.format(0),
  );
  final TextEditingController _receivingController = TextEditingController(
    text: CurrencyInputFormatter.formatter.format(0),
  );
  final String initialText = CurrencyInputFormatter.formatter.format(0);

  Future<void> _addPayment() async {
    widget.viewModel.setDescription(_descriptionController.text);
    final payment = widget.viewModel.createPayment();
    if (payment == null) return;

    context.pop<NewPaymentResult>(NewPaymentResult(payment: payment));
  }

  String text = "";

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.viewModel,
    builder: (context, child) {
      return Scaffold(
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
              context.pop<NewPaymentResult>(NewPaymentResult(payment: null));
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
                      onChanged: (text) {
                        setState(() {
                          widget.viewModel.setSendingValue(
                            (CurrencyInputFormatter.formatter.parse(text) * 100)
                                .floor(),
                          );
                        });
                      },
                      onSubmitted:
                          widget.viewModel.sendingValue == 0 &&
                              widget.viewModel.receivingValue == 0
                          ? null
                          : (_) => _addPayment(),
                      readOnly: widget.viewModel.receivingValue != 0,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Você',
                      ),
                      controller: _sendingController,
                    ),
                  ),
                  Icon(
                    widget.viewModel.sendingValue == 0 &&
                            widget.viewModel.receivingValue == 0
                        ? Icons.remove
                        : widget.viewModel.sendingValue == 0
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
                      onChanged: (text) {
                        setState(() {
                          widget.viewModel.setReceivingValue(
                            (CurrencyInputFormatter.formatter.parse(text) * 100)
                                .floor(),
                          );
                        });
                      },
                      onSubmitted:
                          widget.viewModel.sendingValue == 0 &&
                              widget.viewModel.receivingValue == 0
                          ? null
                          : (_) => _addPayment(),
                      readOnly: widget.viewModel.sendingValue != 0,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: widget.viewModel.payment.contactName,
                      ),
                      controller: _receivingController,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 105,

                child: TextField(
                  controller: _descriptionController,
                  onSubmitted:
                      widget.viewModel.sendingValue == 0 &&
                          widget.viewModel.receivingValue == 0
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
          onPressed:
              widget.viewModel.sendingValue == 0 &&
                  widget.viewModel.receivingValue == 0
              ? null
              : () => _addPayment(),
          icon: Icon(Icons.save),
          iconSize: 30,
          color: ColorScheme.of(context).onPrimary,
          padding: EdgeInsetsGeometry.all(15),
        ),
      );
    },
  );
}
