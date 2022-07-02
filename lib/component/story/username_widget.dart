import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';

class UserNameWidget extends StatelessWidget {
  late String _userName;

  UserNameWidget(String userName) {
    this._userName = '${userName}의 기록';
  }

  @override
  Widget build(BuildContext context) {
    return Text(_userName, style: StoryTextStyle().basicInfo);
  }
}
