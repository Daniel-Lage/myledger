import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myledger/components/payment_component.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/viewmodels/contact_viewmodel.dart';

class ContactView extends StatefulWidget {
  final ContactViewModel viewModel;
  const ContactView({super.key, required this.viewModel});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  Future<void> _goToNewPayment() async {
    final result = await context.push<NewPaymentResult>(
      '/new_payment',
      extra: NewPaymentArguments(contact: widget.viewModel.contact),
    );

    final payment = result?.payment;
    if (payment == null) return;
    await widget.viewModel.addPayment(payment);
  }

  Future<void> _goToPayment(PaymentObject payment) async {
    final result = await context.push<PaymentResult>(
      '/payment',
      extra: PaymentArguments(
        payment: payment,
        contact: widget.viewModel.contact,
      ),
    );

    if (result == null) return;
    if (result.action == PaymentViewAction.none) return;

    if (result.action == PaymentViewAction.delete) {
      await widget.viewModel.deletePayment(payment);
    } else if (result.action == PaymentViewAction.update) {
      await widget.viewModel.updatePayment(result.payment);
    }
  }

  Future<void> _deleteContactDialogBuilder(BuildContext context) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: ColorScheme.of(context).secondary,
          title: Text("Excluir contato?"),
          content: Text("Os pagamentos armazenadas também serão perdidas."),
          actions: [
            GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: ColorScheme.of(context).primary,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: ColorScheme.of(context).onPrimary),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                context.pop();
                context.pop<ContactResult>(
                  ContactResult(
                    contact: widget.viewModel.contact,
                    action: ContactViewAction.delete,
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: ColorScheme.of(context).error,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Text(
                  "Excluir",
                  style: TextStyle(color: ColorScheme.of(context).onError),
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.viewModel,
    builder: (context, child) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (result == null) {
            context.pop<ContactResult>(
              ContactResult(
                contact: widget.viewModel.contact,
                action: widget.viewModel.action,
              ),
            );
          } else {
            context.pop<ContactResult>(result as ContactResult);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: ColorScheme.of(context).primary,
            title: Text(
              "Contato",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ColorScheme.of(context).onPrimary,
              ),
            ),
            iconTheme: IconThemeData(color: ColorScheme.of(context).onPrimary),

            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.delete),
                            title: Text("Excluir contato"),
                            onTap: () {
                              context.pop();
                              _deleteContactDialogBuilder(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.more_vert),
                ),
              ),
            ],

            leading: BackButton(
              onPressed: () {
                context.pop<ContactResult>(
                  ContactResult(
                    contact: widget.viewModel.contact,
                    action: widget.viewModel.action,
                  ),
                );
              },
            ),
          ),
          body: Center(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 10),
                  child: Text(
                    "Saldo com ${widget.viewModel.contact.name}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: ColorScheme.of(context).onSecondary,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    spacing: widget.viewModel.contact.balance >= 0 ? 0 : 3,
                    children: [
                      Text(
                        widget.viewModel.contact.balance >= 0 ? "+" : "-",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        PaymentObject.formatCurrency(
                          widget.viewModel.contact.balance.abs(),
                        ),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 10),
                  child: Text(
                    "Histórico",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                ),

                ...widget.viewModel.payments.map(
                  (payment) => PaymentComponent(
                    payment: payment,
                    onTap: () => _goToPayment(payment),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: ColorScheme.of(context).primary,
            ),
            onPressed: _goToNewPayment,
            icon: Icon(Icons.add),
            iconSize: 40,
            color: ColorScheme.of(context).onPrimary,
            padding: EdgeInsetsGeometry.all(10),
          ),
        ),
      );
    },
  );
}
