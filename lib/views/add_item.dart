import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:steam_market_tracker/providers/item_manager.dart';
import 'package:steam_market_tracker/widgets/add-by-url-form.dart';

class AddItem extends StatelessWidget {
  static const routeName = "add-item";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new item"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AddItemForm(),
            AddByUrlForm(),
          ],
        ),
      ),
    );
  }
}

class AddItemForm extends StatefulWidget {
  @override
  _AddItemFormState createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm> {
  final _formManual = GlobalKey<FormState>();
  final _gameIdController = TextEditingController();
  final _marketHashController = TextEditingController();
  final _marketUrlController = TextEditingController();
  bool _disableSubmit = false;
  bool _error = false;
  Map<String, dynamic> _authData = {
    "rawUrl": "",
    "gameId": "730",
    "marketHash": "",
  };

  void _submit() async {
    if (!_formManual.currentState.validate()) {
      setState(() {
        _error = true;
      });
      return;
    }
    _formManual.currentState.save();
    setState(() {
      _disableSubmit = true;
      _error = false;
    });
    // Provider.of<ItemManager>(context).addByUrl(_authData["rawUrl"]);
    await Provider.of<ItemManager>(context, listen: false)
        .addSteamItem(_authData["gameId"], _authData["marketHash"]);
    // Navigator.of(context).pushReplacementNamed(MyHomePage.routeName);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formManual,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text("Enter Game Id defaults to 730 (CSGO)"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "Game Id default value 730",
                  labelStyle: TextStyle(
                    color: Colors.white30,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.white60),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.white30),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.red),
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                ),
                keyboardType: TextInputType.number,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                controller: _gameIdController,
                onSaved: (value) {
                  if (value.isEmpty || value == null) {
                    value = "730";
                  }
                  _authData['gameId'] = value;
                },
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                  "Enter Item Name"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "Market Item Name",
                  hintText: "Eg. Shattered Web Case",
                  labelStyle: TextStyle(
                    color: Colors.white30,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.white60),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.white30),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.red),
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                controller: _marketHashController,
                enableSuggestions: true,
                validator: (value) {
                  if (_authData["marketUrl"].toString().isEmpty) {
                    if (value.isEmpty) {
                      return "Please enter item's market name";
                    }
                  }
                  return null;
                },
                onSaved: (value) {
                  _authData['marketHash'] = value;
                },
                onFieldSubmitted: (value) {
                  _submit();
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: RaisedButton(
                color: Colors.blueAccent,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  child: Text(
                    "Add Item",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                onPressed: _disableSubmit
                    ? null
                    : () {
                        FocusScope.of(context).unfocus();
                        _submit();
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}