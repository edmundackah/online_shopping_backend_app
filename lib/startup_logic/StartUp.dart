import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartUp {

  /*
  Checks to see if a login token session has been saved from a past session.
  If so the login page is skipped, if not user the is prompted to login.

  Returns True if a login session exists, false if there is none
   */

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> checkLoginSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString("userInfo") != null) {
      return true;
    }
    return false;
  }
}