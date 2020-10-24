import "package:flutter/material.dart";

class AddByUrlForm extends StatefulWidget {
  @override
  _AddByUrlFormState createState() => _AddByUrlFormState();
}

class _AddByUrlFormState extends State<AddByUrlForm> {
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
          // key: _formUrl,
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
                  // controller: _marketUrlController,
                  // validator: (value) {
                  //   if (_authData["marketHash"].toString().isEmpty) {
                  //     if (value.isEmpty) {
                  //       return "Please enter item's market url";
                  //     }
                  //   }
                  //   return null;
                  // },
                  // onSaved: (value) {
                  //   _authData['marketUrl'] = value;
                  // },
                  // onFieldSubmitted: (value) {
                  //   _submit();
                  // },
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
                  // onPressed: _disableSubmit
                  //     ? null
                  //     : _authData["marketUrl"].toString().isEmpty ||
                  //             _authData["marketUrl"].toString() == ""
                  //         ? null
                  //         : () {
                  //             FocusScope.of(context).unfocus();
                  //             _submit();
                  //           },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
