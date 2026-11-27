import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:myledger/currency_input_formatter.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/routing/routes.dart';
import 'package:myledger/viewmodels/edit_payment_viewmodel.dart';

class EditPaymentView extends StatefulWidget {
  final EditPaymentViewModel viewModel;

  const EditPaymentView({super.key, required this.viewModel});

  @override
  State<EditPaymentView> createState() => _EditPaymentViewState();
}

class _EditPaymentViewState extends State<EditPaymentView> {
  EditPaymentViewAction _action = EditPaymentViewAction.none;

  final TextEditingController _toController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final String initialText = CurrencyInputFormatter.formatter.format(0);

  @override
  void initState() {
    super.initState();
    _toController.text = initialText;
    _fromController.text = initialText;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (widget.viewModel.payment.type == PaymentType.sending) {
          _toController.text = CurrencyInputFormatter.formatter.format(
            widget.viewModel.payment.value / 100,
          );
        } else {
          _fromController.text = CurrencyInputFormatter.formatter.format(
            widget.viewModel.payment.value / 100,
          );
        }

        if (widget.viewModel.payment.description != null) {
          _descriptionController.text = widget.viewModel.payment.description!;
        }
      });
    });
  }

  Future<void> _editPayment() async {
    widget.viewModel.setDescription(_descriptionController.text);

    _toController.text = initialText;
    _fromController.text = initialText;

    context.pop<EditPaymentResult>(
      EditPaymentResult(
        payment: widget.viewModel.createEditedPayment(),
        action: widget.viewModel.action,
      ),
    );
  }

  String text = "";

  Widget loading() => Scaffold(
    appBar: AppBar(
      backgroundColor: ColorScheme.of(context).primary,
      iconTheme: IconThemeData(color: ColorScheme.of(context).onPrimary),
    ),
  );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.viewModel,
    builder: (context, child) {
      return Scaffold(
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
              context.pop<EditPaymentResult>(
                EditPaymentResult(
                  payment: null,
                  action: EditPaymentViewAction.none,
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

                        if (newSendingValue != widget.viewModel.sendingValue) {
                          setState(() {
                            _action = EditPaymentViewAction.value;
                            widget.viewModel.setSendingValue(newSendingValue);
                          });
                        }
                      },
                      onSubmitted:
                          widget.viewModel.sendingValue == 0 &&
                              widget.viewModel.receivingValue == 0
                          ? null
                          : (_) => _editPayment(),
                      readOnly: widget.viewModel.receivingValue != 0,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Você',
                      ),
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
                      controller: _fromController,
                      onChanged: (text) {
                        final newReceivingValue =
                            (CurrencyInputFormatter.formatter.parse(text) * 100)
                                .floor();
                        if (widget.viewModel.receivingValue !=
                            newReceivingValue) {
                          setState(() {
                            _action = EditPaymentViewAction.value;
                            widget.viewModel.setReceivingValue(
                              newReceivingValue,
                            );
                          });
                        }
                      },
                      onSubmitted:
                          widget.viewModel.sendingValue == 0 &&
                              widget.viewModel.receivingValue == 0
                          ? null
                          : (_) => _editPayment(),
                      readOnly: widget.viewModel.sendingValue != 0,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: widget.viewModel.payment.contactName,
                      ),
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
                      : (_) => _editPayment(),
                  onChanged: (text) {
                    if (_action == EditPaymentViewAction.none) {
                      setState(() {
                        _action = EditPaymentViewAction.description;
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
          onPressed:
              widget.viewModel.sendingValue == 0 &&
                  widget.viewModel.receivingValue == 0
              ? null
              : () => _editPayment(),
          icon: Icon(Icons.save),
          iconSize: 30,
          color: ColorScheme.of(context).onPrimary,
          padding: EdgeInsetsGeometry.all(15),
        ),
      );
    },
  );
}
