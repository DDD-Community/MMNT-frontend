import 'dart:io';

import 'package:flutter/material.dart';

class PushStoryProvider extends ChangeNotifier {
  String? _title = "";
  late String? _user;
  late DateTime? _dateTime;
  late String? _youtubeLink;
  late File? _img;
  String _message = "";
  late String? _trackName;
  late String? _artist;
  late double? _lat_y;
  late double? _lng_x;

  PushStoryProvider() {}

  String? get title => _title;
  String? get user => _user;
  DateTime? get dateTime => _dateTime;
  String? get link => _youtubeLink;
  File? get path => _img;
  String get context => _message;
  String? get track => _trackName;
  String? get artist => _artist;
  double? get latitude_y => _lat_y;
  double? get longitude_x => _lng_x;

  void clear() {
    _title = "";
    _user = null;
    _dateTime = null;
    _youtubeLink = null;
    _img = null;
    String _message = "";
    _trackName = null;
    _artist = null;
    _lat_y = null;
    _lng_x = null;
    ChangeNotifier();
  }

  set title(String? value) {
    _title = value;
    ChangeNotifier();
  }

  set user(String? value) {
    _user = value;
    ChangeNotifier();
  }

  set dateTime(DateTime? value) {
    _dateTime = value;
    ChangeNotifier();
  }

  set link(String? value) {
    _youtubeLink = value;
    ChangeNotifier();
  }

  set path(File? value) {
    _img = value;
    ChangeNotifier();
  }

  set context(String value) {
    _message = value;
    ChangeNotifier();
  }

  set track(String? value) {
    _trackName = value;
    ChangeNotifier();
  }

  set artist(String? value) {
    _artist = value;
    ChangeNotifier();
  }

  set latitude_y(double? value) {
    _lat_y = value;
    ChangeNotifier();
  }

  set longitude_x(double? value) {
    _lng_x = value;
    ChangeNotifier();
  }
}
