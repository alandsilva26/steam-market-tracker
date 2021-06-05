import 'package:connectivity/connectivity.dart';
import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steam_market_tracker/models/steam_item.dart';
import 'package:steam_market_tracker/providers/item_manager.dart';
import 'package:steam_market_tracker/utils/update_services.dart';
import 'package:steam_market_tracker/views/update_screen.dart';
import 'package:steam_market_tracker/widgets/market_item.dart';

import 'add_item.dart';
import "../widgets/side_drawer.dart";

class Home extends StatefulWidget {
  static const routeName = "my-home-page";

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> rebuild() async {
    // Provider.of<ItemManager>(context, listen: false).updateItems();
    setState(() {});
  }

  void initState() {
    super.initState();
    checkUpdates();
  }

  Future<void> checkUpdates() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String convertedDate =
        new DateFormat("yyyy-MM-dd").format(new DateTime.now());
    String lastChecked = preferences.getString("lastCheckedForUpdate") ?? "";

    if (lastChecked.isNotEmpty) {
      DateTime todaysDate = DateTime.parse(convertedDate);
      DateTime lastCheckedDate = DateTime.parse(lastChecked);
      bool value = todaysDate.isAfter(lastCheckedDate);
      if (value) {
        preferences.setBool("ack", false);
      }
    }

    bool ack = preferences.getBool("ack") ?? false;
    // var connectivityResult = await (Connectivity().checkConnectivity());
    print(ack.toString());
    if (!ack) {
      print("Getting update status");
      await getUpdateStatus();
    }
    if (updateStatus["isUpdateAvailable"] && updateStatus["necessary"] == 1) {
      Navigator.of(context).pushNamed(
        UpdateScreen.routeName,
        arguments: Home.routeName,
      );
      preferences.setBool("ack", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Market Listings"),
        actions: [
          RefreshButton(),
        ],
      ),
      drawer: SideDrawer(),
      body: RefreshIndicator(
        onRefresh: rebuild,
        key: _refreshIndicatorKey,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: MarketItemList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        materialTapTargetSize: MaterialTapTargetSize.padded,
        onPressed: () {
          Navigator.of(context).pushNamed(AddItem.routeName);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class RefreshButton extends StatefulWidget {
  @override
  _RefreshButtonState createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton> {
  bool status = false;

  Future<void> action() async {
    setState(() {
      status = true;
    });
    setState(() {
      status = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return status
        ? Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
              heightFactor: 1,
              child: Container(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          )
        : IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              action();
            },
          );
  }
}

class MarketItemList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final itemManager = Provider.of<ItemManager>(context, listen: false);
    return Column(
      children: [
        StreamBuilder(
          initialData: false,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data) {
                return LinearProgressIndicator();
              }
              return Container();
            }
            return Container();
          },
          stream: Provider.of<ItemManager>(
            context,
            listen: false,
          ).loadingIndicator.stream,
        ),

        // print(data == null);

        Visibility(
          visible: Provider.of<ItemManager>(context).items.length < 1,
          child: ListTile(
            title: Text(
              "Add items to track them",
              style: Theme.of(context).textTheme.bodyText2,
            ),
            subtitle: Text(
              "No items in list",
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Colors.white54,
                  ),
            ),
          ),
        ),
        Column(
          children: Provider.of<ItemManager>(context).items.map(
            (item) {
              return FutureBuilder(
                future: Provider.of<ItemManager>(context, listen: false)
                    .fetchIndividualItem(item),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return MarketItem(
                        steamItem: snapshot.data,
                      );
                    }
                    if (snapshot.hasError) {
                      return MarketItem(
                        steamItem: item,
                        error: snapshot.error,
                      );
                    }
                  }
                  return MarketItem(
                    steamItem: item,
                  );
                },
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}
