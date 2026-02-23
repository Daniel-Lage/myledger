import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentObject? _payment;
  ContactObject? _contact;

  int sendingValue = 0;
  int receivingValue = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PaymentArguments args =
          ModalRoute.of(context)?.settings.arguments as PaymentArguments;

      setState(() {
        _payment = args.payment;
        _contact = args.contact;
      });
    });
  }

  Future<void> _deletePaymentDialogBuilder(BuildContext context) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: ColorScheme.of(context).secondary,
          title: Text("Excluir pagamento?"),
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
                Navigator.of(
                  context,
                ).pop(PaymentResult(action: PaymentPageAction.delete));
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
  Widget build(BuildContext context) => _payment == null
      ? loading()
      : PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, args) {
            if (didPop) return;
            if (args == null) {
              Navigator.of(
                context,
              ).pop(PaymentResult(action: PaymentPageAction.none));
            } else {
              Navigator.of(context).pop(args);
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
                              title: Text("Excluir pagamento"),
                              onTap: () {
                                Navigator.of(context).pop();
                                _deletePaymentDialogBuilder(context);
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
                  Navigator.of(
                    context,
                  ).pop(PaymentResult(action: PaymentPageAction.none));
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
                      "Pagamento ${_payment!.type == PaymentType.receiving ? "de" : "para"} ${_contact!.name}",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  Text(
                    PaymentObject.currencyFormat.format(_payment!.value / 100),
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      formatDate(_payment!.createdAt!),
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
                      _payment!.description! == ""
                          ? "Pagamento sem descrição"
                          : _payment!.description!,
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
}
