import 'package:flutter/material.dart';
import 'package:flutter_project/models/contact_model.dart';
import 'package:flutter_project/services/database_service.dart';

class NewContactPage extends StatefulWidget {
  const NewContactPage({super.key});

  @override
  State<NewContactPage> createState() => _NewContactPageState();
}

class _NewContactPageState extends State<NewContactPage> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseService _databaseService = DatabaseService.instance;

  String text = "";

  void _addContact() {
    final contact = ContactObject(name: text);
    _databaseService.addContact(contact);
    Navigator.pop(context, {"contact": contact});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      title: Text(
        'Criar Contato',
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
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
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      onPressed: text == "" ? null : () => _addContact(),
      icon: Icon(Icons.save),
      iconSize: 30,
      color: Theme.of(context).colorScheme.onPrimary,
      padding: EdgeInsetsGeometry.all(15),
    ),
  );
}
