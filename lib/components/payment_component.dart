import 'package:flutter/material.dart';
import 'package:myledger/models/payment_model.dart';

class PaymentComponent extends StatelessWidget {
  final PaymentObject payment;
  final VoidCallback onTap;

  const PaymentComponent({
    super.key,
    required this.payment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsetsGeometry.directional(start: 20, end: 20),
        decoration: BoxDecoration(
          color: ColorScheme.of(context).secondary,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              formatSimpleDate(payment.createdAt ?? DateTime.now()),
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),

            Row(
              spacing: payment.type == PaymentType.receiving ? 0 : 3,
              children: [
                Text(
                  (payment.type == PaymentType.receiving ? "+" : "-"),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: payment.type == PaymentType.receiving
                        ? ColorScheme.of(context).primary
                        : ColorScheme.of(context).onPrimary,
                  ),
                ),
                Text(
                  PaymentObject.currencyFormat.format(payment.value / 100),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: payment.type == PaymentType.receiving
                        ? ColorScheme.of(context).primary
                        : ColorScheme.of(context).onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
