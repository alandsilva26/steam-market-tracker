import "dart:convert";
import "dart:core";

import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import "../models/steam_item.dart";

class ItemManager with ChangeNotifier {
  final String baseUrl =
      "https://steamcommunity.com/market/priceoverview/?currency=24";
  final url =
      "https://steamcommunity.com/market/listings/440/Mann%20Co.%20Supply%20Crate%20Key";

  List<dynamic> items = [];

  ItemManager(List<dynamic> item) {
    items = item;
    // items = [
    //   {
    //     "gameId": "440",
    //     "marketHash": "Mann%20Co.%20Supply%20Crate%20Key",
    //   },
    //   {
    //     "gameId": "730",
    //     "marketHash": "Shattered%20Web%20Case",
    //   },
    //   {
    //     "gameId": "730",
    //     "marketHash": "AWP | Atheris (Field-Tested)",
    //   },
    //   {
    //     "gameId": "730",
    //     "marketHash": "A (Field-Tested)",
    //   },
    // ];
  }

  List<SteamItem> steamItems = [];

  Future<void> fetchMarketDetails() async {
    try {
      steamItems = [];
      for (Map<String, dynamic> item in items) {
        http.Response response =
            await fetchItemResponse(item["gameId"], item["marketHash"]);

        if (response.statusCode == 200) {
          Map<String, dynamic> extractedData = json.decode(response.body);

          if (extractedData["success"] == false) {
            continue;
          }

          extractedData["name"] = formatHashToName(item["marketHash"]);

          SteamItem steamItem = SteamItem.fromJson(extractedData);

          steamItems.add(steamItem);
        }
      }
      return steamItems;
    } catch (error) {
      if (error.toString().contains("Socket")) {
        throw "Please check your internet connection" + error.toString();
      }
      throw error;
    }
  }

  Future<void> fetchIndividualItem(Map<String, dynamic> item) async {
    print(item);
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // preferences.remove("itemList");
    try {
      http.Response response =
          await fetchItemResponse(item["gameId"], item["marketHash"]);

      if (response.statusCode == 200) {
        Map<String, dynamic> extractedData = json.decode(response.body);

        if (extractedData["success"] == false) {
          throw "No such item could be found";
        }

        extractedData["name"] = formatHashToName(item["marketHash"]);
        extractedData["id"] = item["id"];

        SteamItem steamItem = SteamItem.fromJson(extractedData);

        return steamItem;
      } else if (response.statusCode == 500) {
        throw "No such item could be found";
      } else if (response.statusCode >= 400 || response.statusCode < 500) {
        throw "There is an error with the endpoint";
      } else {
        throw "Unexpected error";
      }
    } catch (error) {
      if (error.toString().contains("Socket")) {
        throw "Please check your internet connection" + error.toString();
      }
      throw error;
    }
  }

  String formatHashToName(String hash) {
    String word = hash.replaceAll(r"%20", " ");
    return word;
  }

  Future<dynamic> fetchItemResponse(String gameId, String marketHash) async {
    try {
      var url = baseUrl + "&appid=$gameId&market_hash_name=$marketHash";

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
    SharedPreferences preferences = await SharedPreferences.getInstance();
    items.removeWhere((item) => item["id"] == id);
    preferences.setString("itemList", json.encode(items));
    notifyListeners();
  }

  void addByUrl(String rawUrl) {
    List test = url.split("/");
    String gameId = test[test.length - 2];
    String marketHash = test[test.length - 1];

    items.add({
      "gameId": gameId.toString(),
      "marketHash": marketHash.toString(),
    });
  }

  Future<void> addManual(String gameId, String marketHash) async {
    String id = new DateTime.now().toIso8601String();
    items.add({
      "id": id,
      "gameId": gameId,
      "marketHash": marketHash,
    });
    print(items);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("itemList", json.encode(items));
    notifyListeners();
  }
}
