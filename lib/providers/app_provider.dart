import 'dart:io';

import 'package:flutter/material.dart';

enum AppStatus {
  initial,
  loading,
  loaded,
  error,
}

class AppProvider with ChangeNotifier {
  AppStatus appStatus = AppStatus.initial;

  void updateAppState(AppStatus newappStatus) {
    appStatus = newappStatus;
    notifyListeners();
  }
}

