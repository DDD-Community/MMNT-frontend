import 'dart:io';

import 'package:flutter/material.dart';

enum AppStatus {
  initial,
  loading,
  loaded,
  error,
}

class AppProvider with ChangeNotifier {
  String userEmail = '';
  AppStatus appStatus = AppStatus.initial;

  void updateAppState(AppStatus status) {
    appStatus = status;
    notifyListeners();
  }

  void updateUserEmail(String email) {
    userEmail = email;
    notifyListeners();
  }
}

