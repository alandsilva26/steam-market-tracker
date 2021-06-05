import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceManager with ChangeNotifier {
  bool volumePreference;

  PreferenceManager(volPref) {
    print("HERE in preference manager");
    this.volumePreference = volPref;
  }

  Future<bool> setVolumePreference(volPref) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("volPref", volPref);
    this.volumePreference = volPref;
    notifyListeners();
    return this.volumePreference;
  }
}
