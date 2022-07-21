import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserNameWidget extends StatelessWidget {
  late String _userName;

  UserNameWidget(String userName) {
    this._userName = '${userName}의 기록';
  }

  UserNameWidget.fromId(String userId) {
    this._userName = "${userId}번째 익명이의 기록";
  }

  @override
  Widget build(BuildContext context) {
    return Text(_userName, style: StoryTextStyle().user);
  }
}
