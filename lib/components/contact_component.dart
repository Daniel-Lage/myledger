import 'package:flutter/material.dart';
import 'package:flutter_project/models/contact_model.dart';
import 'package:flutter_project/currency_input_formatter.dart';

class ContactComponent extends StatelessWidget {
  final ContactObject contact;
  final void Function()? goTo;

  const ContactComponent({
    super.key,
    required this.contact,
    required this.goTo,
  });

  Color getColor() {
    if (contact.debt > 0) return Colors.green;
    if (contact.debt < 0) return Colors.red;
    return Color(0xFF757A6A);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
    child: GestureDetector(
      onTap: goTo,
      child: Container(
        decoration: BoxDecoration(
          color: getColor(),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        padding: EdgeInsetsGeometry.directional(start: 20, end: 20),
        height: 50,
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              CurrencyInputFormatter.formatter.format(contact.debt.abs() / 100),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}
