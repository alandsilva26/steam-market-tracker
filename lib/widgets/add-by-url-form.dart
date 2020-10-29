import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:steam_market_tracker/providers/item_manager.dart';

class AddByUrlForm extends StatefulWidget {
  @override
  _AddByUrlFormState createState() => _AddByUrlFormState();
}

class _AddByUrlFormState extends State<AddByUrlForm> {
  final _form = GlobalKey<FormState>();
  final _marketUrlController = TextEditingController();
  bool _disableSubmit = false;
  bool _error = false;

  Map<String, dynamic> _authData = {
    "rawUrl": "",
  };

  void _submit() async {
    if (!_form.currentState.validate()) {
      setState(() {
        _error = true;
      });
      return;
    }
    _form.currentState.save();
    setState(() {
      _disableSubmit = true;
      _error = false;
    });

    await Provider.of<ItemManager>(
      context,
      listen: false,
    ).addByUrl(_authData["rawUrl"]);
    // await Provider.of<ItemManager>(context, listen: false)
    //     .addManual(_authData["gameId"], _authData["marketHash"]);
    // Navigator.of(context).pushReplacementNamed(MyHomePage.routeName);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8),
          child: Center(
            child: Text("OR"),
          ),
        ),
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text("Enter Market Url"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Market Item url shown in browser",
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
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                  controller: _marketUrlController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please enter item's market url";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['rawUrl'] = value;
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
                      horizontal: 20,
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
                          _submit();
                        },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
