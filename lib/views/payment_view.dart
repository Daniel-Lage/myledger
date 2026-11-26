import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/viewmodels/payment_viewmodel.dart';

class PaymentView extends StatefulWidget {
  final PaymentViewModel viewModel;
  const PaymentView({super.key, required this.viewModel});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  Future<void> _deletePaymentDialogBuilder(BuildContext context) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: ColorScheme.of(context).secondary,
          title: Text("Excluir pagamento?"),
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
                context.pop(
                  PaymentResult(
                    action: PaymentViewAction.delete,
                    payment: widget.viewModel.payment,
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

  Future<void> _goToEditPayment() async {
    final result = await context.push<EditPaymentResult>(
      '/edit_payment',
      extra: EditPaymentArguments(payment: widget.viewModel.payment),
    );

    if (result?.action == EditPaymentViewAction.none ||
        result?.payment == null) {
      return;
    }

    await widget.viewModel.updatePayment(result!.payment!);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.viewModel,
    builder: (context, child) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, args) {
          if (didPop) return;
          if (args == null) {
            context.pop(
              PaymentResult(
                action: widget.viewModel.action,
                payment: widget.viewModel.payment,
              ),
            );
          } else {
            context.pop(args);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: ColorScheme.of(context).primary,
            title: Text(
              "Pagamento",
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
                            title: Text("Excluir pagamento"),
                            onTap: () {
                              context.pop();
                              _deletePaymentDialogBuilder(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.edit),
                            title: Text("Editar pagamento"),
                            onTap: () {
                              context.pop();
                              _goToEditPayment();
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
                context.pop(
                  PaymentResult(
                    action: widget.viewModel.action,
                    payment: widget.viewModel.payment,
                  ),
                );
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "Pagamento ${widget.viewModel.payment.type == PaymentType.receiving ? "de" : "para"} ${widget.viewModel.contact.name}",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),

                Text(
                  PaymentObject.formatCurrency(widget.viewModel.payment.value),
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    formatDate(widget.viewModel.payment.createdAt!),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: ColorScheme.of(context).onSecondary,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    widget.viewModel.payment.description! == ""
                        ? "Pagamento sem descrição"
                        : widget.viewModel.payment.description!,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 18,
                      color: ColorScheme.of(context).onSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
