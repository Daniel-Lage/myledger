import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myledger/routing/routes.dart';
import 'package:myledger/viewmodels/new_contact_viewmodel.dart';

class NewContactView extends StatefulWidget {
  final NewContactViewModel viewModel;
  const NewContactView({super.key, required this.viewModel});

  @override
  State<NewContactView> createState() => _NewContactViewState();
}

class _NewContactViewState extends State<NewContactView> {
  final TextEditingController _controller = TextEditingController();

  void _addContact() {
    final contact = widget.viewModel.createContact();

    context.pop<NewContactResult>(NewContactResult(contact: contact));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.viewModel,
    builder: (context, child) => Scaffold(
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
                onSubmitted: (_) =>
                    widget.viewModel.canSubmit ? _addContact() : null,
                onChanged: widget.viewModel.setName,
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
        onPressed: widget.viewModel.canSubmit ? _addContact : null,
        icon: Icon(Icons.save),
        iconSize: 30,
        color: ColorScheme.of(context).onPrimary,
        padding: EdgeInsetsGeometry.all(15),
      ),
    ),
  );
}
