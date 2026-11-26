import 'package:flutter/material.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/viewmodels/new_contact_viewmodel.dart';

class NewContactView extends StatefulWidget {
  const NewContactView({super.key});

  @override
  State<NewContactView> createState() => _NewContactViewState();
}

class _NewContactViewState extends State<NewContactView> {
  final TextEditingController _controller = TextEditingController();
  final NewContactViewModel _viewModel = NewContactViewModel();

  void _addContact() {
    final contact = _viewModel.createContact();
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
              onSubmitted: (_) => _viewModel.canSubmit ? _addContact() : null,
              onChanged: _viewModel.setName,
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
      onPressed: _viewModel.canSubmit ? _addContact : null,
      icon: Icon(Icons.save),
      iconSize: 30,
      color: ColorScheme.of(context).onPrimary,
      padding: EdgeInsetsGeometry.all(15),
    ),
  );
}
