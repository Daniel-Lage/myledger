import 'package:flutter/material.dart';
import 'package:myledger/models/contact_model.dart';

class MainContactComponent extends StatelessWidget {
  final ContactObject? contact;

  const MainContactComponent({super.key, this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: ColorScheme.of(context).secondary,
        border: BoxBorder.all(
          color: ColorScheme.of(context).onSecondary,
          width: 2,
        ),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 310,
            height: 50,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 17),
              child: contact == null
                  ? null
                  : Text(
                      contact!.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ColorScheme.of(context).onSecondary,
                        fontSize: 20,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
