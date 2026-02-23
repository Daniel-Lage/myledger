import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myledger/components/payment_component.dart';
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
  ContactObject? _contact;
  List<PaymentObject> _paymentsList = <PaymentObject>[];
  final DatabaseService _databaseService = DatabaseService.instance;

  int sendingValue = 0;
  int receivingValue = 0;

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
    NewPaymentResult result =
        await Navigator.of(context).pushNamed(
              "/new_payment",
              arguments: NewPaymentArguments(contact: _contact!),
            )
            as NewPaymentResult;

    if (result.payment == null) return; // null if payment creation is cancelled

    final newPayment = result.payment!;

    final value = newPayment.type == PaymentType.receiving
        ? newPayment.value
        : -newPayment.value;

    newPayment.id = await _databaseService.addPayment(newPayment);

    setState(() {
      _contact!.balance += value;
      _databaseService.updateContact(_contact!);
      _paymentsList.add(newPayment);
      _updated = true;
    });
  }

  Future<void> _goToPayment(PaymentObject payment) async {
    PaymentResult result =
        await Navigator.of(context).pushNamed(
              "/payment",
              arguments: PaymentArguments(payment: payment, contact: _contact!),
            )
            as PaymentResult;

    if (result.action != PaymentPageAction.delete) return;

    await _databaseService.deletePayment(payment);

    final value = payment.type == PaymentType.receiving
        ? payment.value
        : -payment.value;

    setState(() {
      _contact!.balance -= value;
      _databaseService.updateContact(_contact!);
      _paymentsList.removeWhere((p) => p.id == payment.id);
      _updated = true;
    });
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
                Navigator.of(context).pop();
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
                Navigator.of(context).pop();
                Navigator.of(context).pop(
                  ContactResult(
                    contact: _contact!,
                    action: ContactPageAction.delete,
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

  Widget loading() => Scaffold(
    appBar: AppBar(
      backgroundColor: ColorScheme.of(context).primary,
      iconTheme: IconThemeData(color: ColorScheme.of(context).onPrimary),
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
      : PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (result == null) {
              Navigator.of(context).pop(
                ContactResult(
                  contact: _contact!,
                  action: _updated
                      ? ContactPageAction.update
                      : ContactPageAction.none,
                ),
              );
            } else {
              Navigator.of(context).pop(result);
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
              iconTheme: IconThemeData(
                color: ColorScheme.of(context).onPrimary,
              ),

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
                                Navigator.of(context).pop();
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
                  Navigator.of(context).pop(
                    ContactResult(
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
                padding: EdgeInsets.symmetric(horizontal: 10),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 10),
                    child: Text(
                      "Saldo com ${_contact!.name}",
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
                      spacing: _contact!.balance >= 0 ? 0 : 3,
                      children: [
                        Text(
                          _contact!.balance >= 0 ? "+" : "-",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          PaymentObject.currencyFormat.format(
                            _contact!.balance.abs() / 100,
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  ..._paymentsList.map(
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
}
