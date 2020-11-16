import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steam_market_tracker/providers/item_manager.dart';
import 'package:steam_market_tracker/views/add_item.dart';
import 'package:steam_market_tracker/views/home.dart';
import 'package:steam_market_tracker/views/update_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences preference = await SharedPreferences.getInstance();

  /**
   * Check if item list exists
   */
  String itemList = preference.getString("itemList") != null
      ? preference.getString("itemList")
      : "[]";
  List<dynamic> item = json.decode(itemList);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ItemManager>(
          create: (_) => ItemManager(item),
        )
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steam Market Tracker',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(27, 40, 56, 1),
        backgroundColor: Color.fromRGBO(27, 40, 56, 1),
        canvasColor: Color.fromRGBO(27, 40, 56, 1),
        textTheme: TextTheme(
          bodyText1: TextStyle(
            color: Colors.white,
          ),
          bodyText2: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Home.routeName,
      routes: {
        Home.routeName: (context) => Home(),
        AddItem.routeName: (context) => AddItem(),
        UpdateScreen.routeName: (context) => UpdateScreen(),
      },
    );
  }
}
