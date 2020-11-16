
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> updateStatus = {
  "isUpdateAvailable": false,
  "downloadUrl": "",
  "acknowledged": false,
  "necessary": 0,
  "releaseNotesUrl": "",
};

Map<String, dynamic> newVersion;

Future<void> getUpdateStatus() async {
  bool isUpdateAvailable = false;

  updateStatus["isUpdateAvailable"] = await compareVersions();
  if (updateStatus["isUpdateAvailable"]) {
    updateStatus["downloadUrl"] = newVersion["downloadUrl"];
    updateStatus["necessary"] = newVersion["necessary"];
    updateStatus["releaseNotesUrl"] = newVersion["releaseNotesUrl"];
  }

}

Future<Map<String, dynamic>> fetchLatestVersion() async {

  Map<String, dynamic> newVersion = {
    "version": "",
    "necessary": 0,
    "downloadUrl": "",
    "releaseNotesUrl": "",
  };
  const String _url =
      "https://alandsilva26.github.io/steam-market-tracker/version.json";
  try {
    final response = await http.get(_url);
    if (response.statusCode == 200) {
      final extractedData = json.decode(response.body);
      newVersion["version"] = extractedData["version"];
      newVersion["necessary"] = extractedData["necessary"];
      newVersion["downloadUrl"] = extractedData["downloadUrl"];
      newVersion["releaseNotesUrl"] = extractedData["releaseNotesUrl"];
    }
    return newVersion;
  } on SocketException catch (_) {
    print("Error while fetching latest app version");
    return newVersion;
  }
}

compareVersions() async {
  bool isUpdateAvailable = false;

  // get current version
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;

  // get new version details
  newVersion = await fetchLatestVersion() ?? "";
  if (newVersion["version"].isEmpty || newVersion["version"] == null) {
    return isUpdateAvailable;
  }
  // split details into array
  List currentV = currentVersion.split(".");
  List newV = newVersion["version"].split(".");

  if (currentV.length == newV.length) {
    Map<String, int> currentVNumbers = {
      "major": int.parse(currentV[0]),
      "update": int.parse(currentV[1]),
      "patch": int.parse(currentV[2]),
    };
    Map<String, int> newVNumbers = {
      "major": int.parse(newV[0]),
      "update": int.parse(newV[1]),
      "patch": int.parse(newV[2]),
    };
    if (currentVNumbers["major"] < newVNumbers["major"]) {
      isUpdateAvailable = true;
    } else if (currentVNumbers["update"] < newVNumbers["update"]) {
      isUpdateAvailable = true;
    } else if (currentVNumbers["patch"] < newVNumbers["patch"]) {
      isUpdateAvailable = true;
    }
  }
  print("HERE AND RETURNING" + isUpdateAvailable.toString());
  return isUpdateAvailable;
}