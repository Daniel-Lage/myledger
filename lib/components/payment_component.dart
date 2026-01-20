import 'package:flutter/material.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/currency_input_formatter.dart';

class PaymentComponent extends StatelessWidget {
  final PaymentObject payment;

  const PaymentComponent({super.key, required this.payment});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsGeometry.directional(top: 10),

    child: Row(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          width: MediaQuery.of(context).size.width - 100,
          height: 50,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  payment.type == PaymentType.minus ? Icons.remove : Icons.add,
                  size: 25,
                ),
                Text(
                  CurrencyInputFormatter.formatter.format(payment.value / 100),
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
