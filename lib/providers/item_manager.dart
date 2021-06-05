import 'dart:async';
import "dart:convert";
import "dart:core";

import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import "../models/steam_item.dart";
import "../models/price_archive.dart";

class ItemManager with ChangeNotifier {
  final String baseUrl =
      "https://steamcommunity.com/market/priceoverview/?currency=24";
  final url =
      "https://steamcommunity.com/market/listings/440/Mann%20Co.%20Supply%20Crate%20Key";

  List<SteamItem> items = [];
  List<PriceArchive> priceArchiveList = [];

  ItemManager(List<String> itemList, List<String> priceArchiveList) {
    /**
     * NEW:: DO NOT DO THIS AS ENTIRE LOGIC HAS BEEN CHANGED
     * For version above version 1.0.0 transfer all from shared preferences to sqlite
     * Steps to be followed
     * Get list of items from shared preferences
     * Create database file
     * Create ItemList table with list of class names
     * Create individual table for each
     * On initial load display last of each table
     * IN background load and insert new
     */
    print(itemList);
    if (itemList != null) {
      if (itemList.length > 0) {
        List<SteamItem> itemListJson = itemList
            .map((item) => SteamItem.fromJson(json.decode(item)))
            .toList();
        // print(itemListJson);
        this.items = itemListJson;
      } else {
        this.items = [];
      }
    } else {
      this.items = [];
    }

    if (priceArchiveList != null) {
      // print(priceArchiveList);
      if (priceArchiveList.length > 0) {
        List<PriceArchive> itemListJson = priceArchiveList
            .map((item) => PriceArchive.fromJson(json.decode(item)))
            .toList();
        // print(itemListJson);
        this.priceArchiveList = itemListJson;
      } else {
        this.priceArchiveList = [];
      }
    } else {
      this.priceArchiveList = [];
    }
  }

  // ignore: close_sinks
  StreamController<bool> loadingIndicator = StreamController<bool>();

  // Stream stream = controller.stream;

  Future<void> updateItems() async {
    loadingIndicator.add(true);

    // copy of list
    List<SteamItem> copyItems = items;

    for (SteamItem item in copyItems) {
      await fetchIndividualItem(item);
    }
    print("COMPLETED");
    loadingIndicator.add(false);
    notifyListeners();
  }

  /// Fetch individual items
  Future<SteamItem> fetchIndividualItem(SteamItem item) async {
    int index = items.indexOf(item);

    if (index == 0) {
      loadingIndicator.add(true);
    }

    print("Fectching details of " + item.name.toString());

    try {
      http.Response response = await fetchItemResponse(
        item.gameId,
        item.marketHash,
      );

      if (response.statusCode == 200) {
        // print(response.body);
        Map<String, dynamic> extractedData = json.decode(response.body);

        if (extractedData["success"] == false) {
          throw "No such item could be found";
        }

        // await Future.delayed(Duration(seconds: index + index + index + 1));

        SteamItem steamItem = item;
        String archivePrice = item.lowestPrice;
        String archiveVolume = item.volume;

        steamItem.name = formatHashToName(item.marketHash);
        steamItem.lowestPrice = extractedData["lowest_price"];
        steamItem.medianPrice = extractedData["median_price"];
        steamItem.volume = extractedData["volume"];
        steamItem.archivePrice = archivePrice == "" || archivePrice == null
            ? steamItem.lowestPrice
            : archivePrice;
        steamItem.archiveVolume = archiveVolume == "" || archiveVolume == null
            ? steamItem.volume
            : archiveVolume;
        // print(steamItem.lowestPrice.toString() +
        //     " " +
        //     steamItem.archivePrice.toString());

        // Replace and save steam item
        items[index] = steamItem;

        // Add lowest price archive
        // addToArchive(
        //   steamItem.marketHash,
        //   steamItem.lowestPrice,
        //   DateTime.now(),
        // );

        await persistData();

        if (index == items.length - 1) {
          loadingIndicator.add(false);
        }

        return steamItem;
      } else if (response.statusCode == 500) {
        throw "No such item could be found";
      } else if (response.statusCode >= 400 || response.statusCode < 500) {
        throw "There is an error with the endpoint";
      } else {
        throw "Unexpected error";
      }
    } catch (error) {
      print(error.toString());
      if (error.toString().contains("Socket")) {
        throw "Please check your internet connection";
      }

      if (index == items.length - 1) {
        loadingIndicator.add(false);
      }

      throw error;
    }
  }

  Future<void> addToArchive(marketHash, lowestPrice, timeStamp) async {
    // Find the item from archive
    PriceArchive item;
    int index = -1;
    try {
      item = this.priceArchiveList.firstWhere(
            (PriceArchive archive) => archive.marketHash == marketHash,
          );
      index = this.priceArchiveList.indexOf(item);
    } catch (e) {
      item = PriceArchive(
        marketHash: marketHash,
        prices: [],
      );
    }

    item.prices.add(
      new Price(
        price: lowestPrice,
        timeStamp: timeStamp,
      ),
    );

    if (index != -1) {
      this.priceArchiveList[index] = item;
    } else {
      this.priceArchiveList.add(item);
    }

    // print(item.prices);

    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setStringList(
      "priceArchiveList",
      this
          .priceArchiveList
          .map(
            (PriceArchive archive) => jsonEncode(archive.toMap()),
          )
          .toList(),
    );
  }

  String formatHashToName(String hash) {
    String word = hash.replaceAll(r"%20", " ");
    return word;
  }

  String formatNameToHash(String name) {
    String word = name.replaceAll(r" ", "%20");
    return word;
  }

  Future<dynamic> fetchItemResponse(String gameId, String marketHash) async {
    try {
      var url = baseUrl + "&appid=$gameId&market_hash_name=$marketHash";

      // print(url);
      http.Response response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
      );
      return response;
    } catch (error) {
      if (error.toString().contains("Socket")) {
        throw "Please check your internet connection";
      }
      throw error;
    }
  }

  Future<void> removeItem(String id) async {
    items.removeWhere((SteamItem item) => item.id == id);

    await persistData();

    notifyListeners();
  }

  Future<void> addByUrl(String rawUrl) async {
    var decoded = Uri.decodeFull(rawUrl);
    List urlArray = decoded.split("/");
    String gameId = urlArray[urlArray.length - 2];
    String marketHash = urlArray[urlArray.length - 1];
    print(marketHash);

    await addSteamItem(gameId, marketHash);
  }

  /// Both add by url and add manually use this function in the end...
  Future<void> addSteamItem(String gameId, String marketHash) async {
    // Get timestamp
    String id = new DateTime.now().toIso8601String();
    items.add(
      SteamItem.fromJson(
        {
          "id": id,
          "gameId": gameId,
          "marketHash": formatNameToHash(marketHash),
          "name": formatHashToName(marketHash),
        },
      ),
    );

    // print(SteamItem.fromJson({
    //   "id": id,
    //   "gameId": gameId,
    //   "marketHash": marketHash,
    // }).marketHash);

    // Save data
    await persistData();
    notifyListeners();
  }

  Future<void> persistData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // print(items.map((SteamItem item) => json.encode(item.toJson())).toList());
    preferences.setStringList(
      "itemList",
      items.map((SteamItem item) => json.encode(item.toJson())).toList(),
    );
  }

// Future<void> fetchMarketDetails() async {
//   try {
//     steamItems = [];
//     for (Map<String, dynamic> item in items) {
//       http.Response response =
//           await fetchItemResponse(item["gameId"], item["marketHash"]);
//
//       if (response.statusCode == 200) {
//         Map<String, dynamic> extractedData = json.decode(response.body);
//
//         if (extractedData["success"] == false) {
//           continue;
//         }
//
//         extractedData["name"] = formatHashToName(item["marketHash"]);
//
//         SteamItem steamItem = SteamItem.fromJson(extractedData);
//
//         steamItems.add(steamItem);
//       }
//     }
//     return steamItems;
//   } catch (error) {
//     if (error.toString().contains("Socket")) {
//       throw "Please check your internet connection" + error.toString();
//     }
//     throw error;
//   }
// }
}
