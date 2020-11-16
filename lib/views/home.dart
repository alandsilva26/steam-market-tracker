import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:steam_market_tracker/models/steam_item.dart';
import 'package:steam_market_tracker/providers/item_manager.dart';
import 'package:steam_market_tracker/widgets/market_item.dart';

import 'add_item.dart';

class Home extends StatefulWidget {
  static const routeName = "my-home-page";

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();

  Future<void> rebuild() async {
    setState(() {});
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
                          return MarketItem(
                            steamItem: steamItem,
                          );
                        }
                        return Text(
                          "There was an error displaying details.",
                        );
                      },
                    ),
                  )
                      .toList(),
                ),
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