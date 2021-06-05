import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../providers/preference_manager.dart";

class SideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
            child: ListTile(
              title: Text(
                'Preferences',
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
          ),
          Divider(
            color: Colors.grey[700],
          ),
          SwitchListTile(
            value: Provider.of<PreferenceManager>(context).volumePreference,
            onChanged: (value) async {
              bool changedValue =
                  await Provider.of<PreferenceManager>(context, listen: false)
                      .setVolumePreference(value);
              SnackBar snackBar;
              if (changedValue) {
                snackBar = SnackBar(
                  content: Text('Displaying volume'),
                  duration: Duration(
                    seconds: 3,
                  ),
                );
              } else {
                snackBar = SnackBar(
                  content: Text('Not Displaying volume'),
                  duration: Duration(
                    seconds: 3,
                  ),
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            title: Text("Display Volume"),
          )
        ],
      ),
    );
  }
}
