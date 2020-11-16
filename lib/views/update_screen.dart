import 'package:flutter/material.dart';
import 'package:steam_market_tracker/utils/update_services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/update_services.dart';

class UpdateScreen extends StatelessWidget {
  static const routeName = "update-screen";

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    String initialRoute = ModalRoute.of(context).settings.arguments.toString();
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        elevation: 0,
        brightness: Brightness.dark,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: IconButton(
              onPressed: () {
                if (initialRoute != null && initialRoute != "") {
                  Navigator.of(context).popUntil(
                    ModalRoute.withName(initialRoute),
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: Icon(
                Icons.close,
                size: 50,
                semanticLabel: "Close",
              ),
              color: Colors.white,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          ),
        ],
      ),
      body: Container(
        // color: Update,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      "A new update is available!!",
                      style: TextStyle(
                        fontFamily: "Roboto",
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    child: FlatButton(
                      onPressed: () async {
                        print(updateStatus["downloadUrl"]);
                        await _launchURL(updateStatus["downloadUrl"]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Download",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                      ),
//                      shape: RoundedRectangleBorder(
//                        borderRadius: BorderRadius.circular(18.0),
//                      ),
                      color: Colors.blue,
                    ),
                  ),
                  // Text(
                  //   "This update includes bug fixes and improvements.",
                  //   style: TextStyle(color: Colors.white),
                  // ),
//                   Text(
//                     "You can read the release notes here",
//                     style: TextStyle(
//                       color: Colors.white,
//                     ),
//                   ),
//                   Container(
//                     margin: EdgeInsets.only(top: 10),
//                     child: FlatButton(
// //                      padding:
// //                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                       color: Colors.blue,
//                       onPressed: () async {
//                         await _launchURL(updateStatus["releaseNotesUrl"]);
//                       },
//                       child: Text(
//                         "See What's New",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
