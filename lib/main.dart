import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steam_market_tracker/providers/item_manager.dart';
import 'package:steam_market_tracker/providers/preference_manager.dart';
import 'package:steam_market_tracker/views/add_item.dart';
import 'package:steam_market_tracker/views/home.dart';
import 'package:steam_market_tracker/views/update_screen.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences preference = await SharedPreferences.getInstance();

  /**
   * Check if item list exists
   */
  List<String> itemList = preference.getStringList("itemList") ?? [];
  // preference.remove("priceArchiveList");
  // print(preference.getStringList("priceArchiveList"));
  List<String> priceArchiveList =
      preference.getStringList("priceArchiveList") ?? [];
  bool volPref = preference.getBool("volPref") ?? true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ItemManager>(
          create: (_) => ItemManager(
            itemList,
            priceArchiveList,
          ),
        ),
        ChangeNotifierProvider<PreferenceManager>(
          create: (_) => PreferenceManager(volPref),
        )
      ],
      child: MyApp(),
    ),
  );
}

// void callbackDispatcher() {
//   Workmanager.executeTask((task, inputData) {
//     // initialise the plugin of flutterlocalnotifications.
//     FlutterLocalNotificationsPlugin flip =
//         new FlutterLocalNotificationsPlugin();
//
//     // app_icon needs to be a added as a drawable
//     // resource to the Android head project.
//     var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     // initialise settings for both Android and iOS device.
//     var settings = new InitializationSettings(android: android);
//     flip.initialize(settings);
//     _showNotificationWithDefaultSound(flip);
//     return Future.value(true);
//   });
// }

Future _showNotificationWithDefaultSound(flip) async {
  // Show a notification after every 15 minute with the first
  // appearance happening a minute after invoking the method
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    'your channel description',
    importance: Importance.max,
    priority: Priority.high,
  );
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

  // initialise channel platform for both Android and iOS device.
  var platformChannelSpecifics =
      new NotificationDetails(android: androidPlatformChannelSpecifics);
  await flip.show(
      0,
      'GeeksforGeeks',
      'Your are one step away to connect with GeeksforGeeks',
      platformChannelSpecifics,
      payload: 'Default_Sound');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steam Market Tracker',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(27, 40, 56, 1),
        brightness: Brightness.dark,
        backgroundColor: Color.fromRGBO(27, 40, 56, 1),
        canvasColor: Color.fromRGBO(27, 40, 56, 1),
        textTheme: TextTheme(
          bodyText1: TextStyle(
            color: Colors.white,
          ),
          bodyText2: TextStyle(
            color: Colors.white,
            fontSize: 16,
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
