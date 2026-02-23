import 'package:flutter/material.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';

class ContactComponent extends StatelessWidget {
  final ContactObject contact;
  final void Function()? goTo;

  const ContactComponent({
    super.key,
    required this.contact,
    required this.goTo,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
    child: GestureDetector(
      onTap: goTo,
      child: Container(
        padding: EdgeInsetsGeometry.directional(start: 20, end: 20),
        height: 50,
        decoration: BoxDecoration(
          color: ColorScheme.of(context).secondary,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              spacing: 10,
              children: [
                Icon(Icons.person),
                Text(
                  contact.name,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
              ],
            ),
            if (contact.balance != 0)
              Row(
                spacing: contact.balance > 0 ? 0 : 3,
                children: [
                  Text(
                    (contact.balance > 0 ? "+" : "-"),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: contact.balance > 0
                          ? ColorScheme.of(context).primary
                          : ColorScheme.of(context).onPrimary,
                    ),
                  ),
                  Text(
                    PaymentObject.currencyFormat.format(
                      contact.balance.abs() / 100,
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: contact.balance > 0
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
