import 'package:flutter/material.dart';
import 'package:myledger/models/contact_model.dart';

class NewContactPage extends StatefulWidget {
  const NewContactPage({super.key});

  @override
  State<NewContactPage> createState() => _NewContactPageState();
}

class _NewContactPageState extends State<NewContactPage> {
  final TextEditingController _controller = TextEditingController();

  String text = "";

  void _addContact() {
    final contact = ContactObject(name: text);
    Navigator.of(context).pop(NewContactResult(contact: contact));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: ColorScheme.of(context).primary,
      iconTheme: IconThemeData(color: ColorScheme.of(context).onPrimary),
      title: Text(
        'Criar Contato',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: ColorScheme.of(context).onPrimary,
        ),
      ),
    ),
    body: Padding(
      padding: EdgeInsetsGeometry.directional(top: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width - 100,
            child: TextField(
              autofocus: true,
              controller: _controller,
              onSubmitted: (_) => text.isEmpty ? null : _addContact(),
              onChanged: (value) {
                setState(() {
                  (text = value);
                });
              },
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nome',
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
      onPressed: text == "" ? null : () => _addContact(),
      icon: Icon(Icons.save),
      iconSize: 30,
      color: ColorScheme.of(context).onPrimary,
      padding: EdgeInsetsGeometry.all(15),
    ),
  );
}
