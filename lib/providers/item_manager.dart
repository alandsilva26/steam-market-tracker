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
    /**
     * For version above version 1.0.0 transfer all from shared preferences to sqlite
     * Steps to be followed
     * Get list of items from shared preferences
     * Create database file
     * Create ItemList table with list of class names
     * Create individual table for each
     * On initial load display last of each table
     * IN background load and insert new
     */
    items = item;
  }

  List<SteamItem> steamItems = [];

  Future<void> fetchIndividualItem(Map<String, dynamic> item) async {
    print(item);
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // preferences.remove("itemList");
    try {
      http.Response response =
          await fetchItemResponse(item["gameId"], item["marketHash"]);

      if (response.statusCode == 200) {
        Map<String, dynamic> extractedData = json.decode(response.body);

        print(extractedData);

        if (extractedData["success"] == false) {
          throw "No such item could be found";
        }

        extractedData["name"] = formatHashToName(item["marketHash"]);
        extractedData["gameId"] = formatHashToName(item["gameId"]);
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

  Future<void> addByUrl(String rawUrl) async {
    var decoded = Uri.decodeFull(rawUrl);
    List urlArray = decoded.split("/");
    String gameId = urlArray[urlArray.length - 2];
    String marketHash = urlArray[urlArray.length - 1];
    print(marketHash);
    await addManual(gameId, marketHash);
    // await addManual(gameId, marketHash)
    // var uri = 'https://steamcommunity.com/market/listings/730/%E2%98%85%20Huntsman%20Knife%20%7C%20Crimson%20Web%20%28Factory%20New%29';
    // print(decoded);
  }

  Future<void> addManual(String gameId, String marketHash) async {
    String id = new DateTime.now().toIso8601String();
    items.add({
      "id": id,
      "gameId": gameId,
      "marketHash": marketHash,
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("itemList", json.encode(items));
    notifyListeners();
  }

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
}
