import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:steam_market_tracker/models/steam_item.dart';
import 'package:steam_market_tracker/providers/item_manager.dart';
import 'package:steam_market_tracker/utils/launch_url.dart';

class MarketItem extends StatelessWidget {
  final SteamItem steamItem;

  MarketItem({this.steamItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromRGBO(16, 24, 34, 1),
      // child: Padding(
      //   padding: const EdgeInsets.all(16.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(8),

        /**
         * Trailing widget
         */
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
                      steamItem.name,
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
        subtitle: Column(
          children: [
            Padding(
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
                    "${steamItem.lowestPrice}",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Icon(
                        Icons.arrow_drop_up,
                        color: Colors.green,
                      ),
                    ),
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
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                  Text(
                    steamItem.volume != null
                        ? "${steamItem.volume}"
                        : "Could not find volume",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Icon(
                        Icons.arrow_drop_up,
                        color: Colors.green,
                      ),
                    ),
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
          launchURL(url);
        },
      ),
    );
  }
}
