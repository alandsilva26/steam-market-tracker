import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:steam_market_tracker/models/steam_item.dart';
import 'package:steam_market_tracker/providers/item_manager.dart';
import 'package:steam_market_tracker/providers/preference_manager.dart';
import 'package:steam_market_tracker/utils/launch_url.dart';

enum Status { HIGH, LOW, SAME }

class MarketItem extends StatelessWidget {
  final SteamItem steamItem;
  final String error;

  MarketItem({
    this.steamItem,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromRGBO(16, 24, 34, 1),
      // child: Padding(
      //   padding: const EdgeInsets.all(16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        trailing: Container(
          child: IconButton(
            alignment: Alignment.topCenter,
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
        ),

        /**
         * Title widget
         */
        title: Container(
          // decoration: BoxDecoration(
          //   border: Border.all(
          //     color: Colors.red,
          //   ),
          // ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
            child: Row(
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    child: Text(
                      steamItem.name ?? "null",
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        /**
         * Subtitle
         */
        subtitle: this.error == null
            ? Column(
                children: [
                  PriceItem(
                    lowestPrice: steamItem.lowestPrice,
                    archivePrice: steamItem.archivePrice,
                  ),
                  Consumer<PreferenceManager>(
                    builder: (_, preferenceManager, child) {
                      return Visibility(
                        visible: preferenceManager.volumePreference,
                        child: VolumeItem(
                          volume: steamItem.volume,
                          archiveVolume: steamItem.archiveVolume,
                        ),
                      );
                    },
                  ),
                ],
              )
            : MarketErrorWidget(error: this.error),
        onTap: () {
          https: //steamcommunity.com/market/listings/
          String url =
              "https://steamcommunity.com/market/listings/${steamItem.gameId.toString()}/${steamItem.name}";
          launchURL(url);
        },
      ),
    );
  }
}

class PriceItem extends StatelessWidget {
  PriceItem({
    @required this.lowestPrice,
    @required this.archivePrice,
  });

  final lowestPrice;
  final archivePrice;

  Status comparePrice(a, b) {
    try {
      a = double.parse(a.substring(2));
      b = double.parse(b.substring(2));
    } catch (e) {
      return Status.SAME;
    }
    if (a > b) {
      // print("YES LARGER");
      return Status.HIGH;
    } else if (a < b) {
      return Status.LOW;
    } else {
      return Status.SAME;
    }
  }

  String getDiff(Status status) {
    if (status != Status.SAME) {
      double a = double.parse(lowestPrice.substring(2));
      double b = double.parse(archivePrice.substring(2));
      if (status == Status.HIGH) {
        return "+ " + (a - b).toStringAsFixed(2);
      } else {
        return "- " + (b - a).toStringAsFixed(2);
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    Status status = comparePrice(lowestPrice, archivePrice);
    String diff = getDiff(status);
    print(diff);
    return Visibility(
      visible: lowestPrice != "",
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Text(
              "Lowest Price:  ",
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Colors.white54,
                  ),
            ),
            Text(
              "${this.lowestPrice}",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: AnimatedOpacity(
                  // If the widget is visible, animate to 0.0 (invisible).
                  // If the widget is hidden, animate to 1.0 (fully visible).
                  opacity: status != Status.SAME ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: Visibility(
                    visible: status != Status.SAME,
                    child: status == Status.HIGH
                        ? Row(
                            children: [
                              Icon(
                                Icons.arrow_drop_up,
                                color: Colors.green[300],
                              ),
                              Text(
                                diff,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green[300],
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.red[300],
                              ),
                              Text(
                                diff,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red[300],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VolumeItem extends StatelessWidget {
  VolumeItem({
    @required this.volume,
    @required this.archiveVolume,
  });

  final volume;
  final archiveVolume;

  Status compareVolume(a, b) {
    try {
      a = double.parse(a.replaceAll(",", ""));
      b = double.parse(b.replaceAll(",", ""));
    } catch (e) {
      return Status.SAME;
    }
    if (a > b) {
      // print("YES LARGER");
      return Status.HIGH;
    } else if (a < b) {
      return Status.LOW;
    } else {
      return Status.SAME;
    }
  }

  String getDiff(Status status) {
    if (status != Status.SAME) {
      double a = double.parse(volume.replaceAll(",", ""));
      double b = double.parse(archiveVolume.replaceAll(",", ""));
      print(a);
      print(b);
      if (status == Status.HIGH) {
        return "+ " + (a - b).toStringAsFixed(2);
      } else {
        return "- " + (b - a).toStringAsFixed(2);
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    Status status = compareVolume(volume, archiveVolume);
    String diff = getDiff(status);
    return Visibility(
      visible: volume != "",
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Text(
              "Volume:  ",
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Colors.white54,
                  ),
            ),
            Text(
              volume != null ? "${volume}" : "Could not find volume",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: AnimatedOpacity(
                  opacity: status != Status.SAME ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: Visibility(
                    visible: status != Status.SAME,
                    child: status == Status.HIGH
                        ? Row(
                            children: [
                              Icon(
                                Icons.arrow_drop_up,
                                color: Colors.green[300],
                              ),
                              Text(
                                diff,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green[300],
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.red[300],
                              ),
                              Text(
                                diff,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red[300],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MarketErrorWidget extends StatelessWidget {
  final String error;

  MarketErrorWidget({@required this.error});

  String getErrorMessage() {
    if (this.error == "No such item could be found") {
      return "Error: This item seems to be invalid. Please try adding again.";
    } else if (this.error == "There is an error with the endpoint") {
      return "Error: Server error please try again later";
    } else if (this.error == "Please check your internet connection") {
      return "Error: Please check your internet connection";
    } else {
      return "Unexpected Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        getErrorMessage(),
        style: TextStyle(
          color: Color.fromRGBO(255, 0, 0, 0.7),
        ),
      ),
    );
  }
}
