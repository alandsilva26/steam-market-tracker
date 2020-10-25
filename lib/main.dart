import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steam_market_tracker/models/steam_item.dart';
import 'package:steam_market_tracker/providers/item_manager.dart';
import 'package:steam_market_tracker/views/add_item.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preference = await SharedPreferences.getInstance();
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
      initialRoute: MyHomePage.routeName,
      routes: {
        MyHomePage.routeName: (context) => MyHomePage(),
        AddItem.routeName: (context) => AddItem(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const routeName = "my-home-page";

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> rebuild() async {
    setState(() {});
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Market Listings"),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: rebuild),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: rebuild,
        key: _refreshIndicatorKey,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            // decoration: BoxDecoration(
            // border: Border.all(
            // color: Colors.red, width: 1, style: BorderStyle.solid),
            // ),
            child: Column(
              children: [
                Column(
                  children: Provider.of<ItemManager>(context)
                      .items
                      .map(
                        (item) => FutureBuilder(
                          future: Provider.of<ItemManager>(context)
                              .fetchIndividualItem(item),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                child: Card(
                                  color: Color.fromRGBO(16, 24, 34, 1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text("Loading...",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    child: ListTile(
                                      title: Text(
                                        "ERROR: " + snapshot.error.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      trailing: IconButton(
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(Icons.close),
                                        color: Colors.white54,
                                        onPressed: () async {
                                          await Provider.of<ItemManager>(
                                            context,
                                            listen: false,
                                          ).removeItem(item["id"]);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (snapshot.hasData) {
                              SteamItem steamItem = snapshot.data;
                              return Card(
                                color: Color.fromRGBO(16, 24, 34, 1),
                                // child: Padding(
                                //   padding: const EdgeInsets.all(16.0),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(8),
                                  trailing: IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(Icons.close),
                                    color: Colors.white54,
                                    onPressed: () async {
                                      await Provider.of<ItemManager>(
                                        context,
                                        listen: false,
                                      ).removeItem(steamItem.id);
                                    },
                                  ),
                                  title: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      steamItem.name,
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ),
                                  subtitle: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              "Lowest Price:  ",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                    color: Colors.white54,
                                                  ),
                                            ),
                                            Text(
                                              "${steamItem.lowestPrice}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              "Volume:  ",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                    color: Colors.white54,
                                                  ),
                                            ),
                                            Text(
                                              steamItem.volume != null
                                                  ? "${steamItem.volume}"
                                                  : "Could not find volume",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    //  https://steamcommunity.com/market/listings/
                                    String url =
                                        "https://steamcommunity.com/market/listings/${steamItem.gameId.toString()}/${steamItem.name}";
                                    _launchURL(url);
                                  },
                                ),
                                // child: Column(
                                //   crossAxisAlignment:
                                //       CrossAxisAlignment.stretch,
                                //   children: <Widget>[
                                //     Padding(
                                //       padding: const EdgeInsets.symmetric(
                                //           horizontal: 0, vertical: 8.0),
                                //       child: Text(
                                //         steamItem.name,
                                //         style: Theme.of(context)
                                //             .textTheme
                                //             .bodyText2,
                                //       ),
                                //     ),
                                //     Text(
                                //       "Lowest Price:  ${steamItem.lowestPrice}",
                                //       style: Theme.of(context)
                                //           .textTheme
                                //           .bodyText1,
                                //     ),
                                //   ],
                                // ),
                              );
                            }
                            return Text(
                                "There was an error displaying details.");
                          },
                        ),
                      )
                      .toList(),
                ),
                // FutureBuilder(
                //   future:
                //       Provider.of<ItemManager>(context).fetchMarketDetails(),
                //   builder: (context, snapshot) {
                //     print("BUILDING THIS________________");
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return Container(
                //         width: MediaQuery.of(context).size.width,
                //         child: Card(
                //           color: Color.fromRGBO(16, 24, 34, 1),
                //           child: Padding(
                //             padding: const EdgeInsets.all(16.0),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               mainAxisSize: MainAxisSize.min,
                //               children: <Widget>[
                //                 Text("Loading...",
                //                     style:
                //                         Theme.of(context).textTheme.bodyText2),
                //               ],
                //             ),
                //           ),
                //         ),
                //       );
                //     }
                //
                //     if (snapshot.hasError) {
                //       return Center(
                //         child: Padding(
                //           padding: const EdgeInsets.all(8.0),
                //           child: Container(
                //             child: Text("ERROR: " + snapshot.error.toString()),
                //           ),
                //         ),
                //       );
                //     }
                //     if (snapshot.hasData) {
                //       List<SteamItem> steamItems = snapshot.data;
                //       return Container(
                //         width: MediaQuery.of(context).size.width,
                //         child: Column(
                //           children: steamItems
                //               .map(
                //                 (item) => Card(
                //                   color: Color.fromRGBO(16, 24, 34, 1),
                //                   child: Padding(
                //                     padding: const EdgeInsets.all(16.0),
                //                     child: Column(
                //                       crossAxisAlignment:
                //                           CrossAxisAlignment.stretch,
                //                       children: <Widget>[
                //                         Padding(
                //                           padding: const EdgeInsets.symmetric(
                //                               horizontal: 0, vertical: 8.0),
                //                           child: Text(
                //                             item.name,
                //                             style: Theme.of(context)
                //                                 .textTheme
                //                                 .bodyText2,
                //                           ),
                //                         ),
                //                         Text(
                //                           "Lowest Price:  ${item.lowestPrice}",
                //                           style: Theme.of(context)
                //                               .textTheme
                //                               .bodyText1,
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                 ),
                //               )
                //               .toList(),
                //         ),
                //       );
                //     }
                //     return Text("HELLO");
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddItem.routeName);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
