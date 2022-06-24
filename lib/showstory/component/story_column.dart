import 'package:dash_mement/domain/story.dart';
import 'package:dash_mement/showstory/component/date_widget.dart';
import 'package:dash_mement/showstory/component/username_widget.dart';
import 'package:flutter/material.dart';

class StoryColumn extends StatelessWidget {
  late Story _story;
  late DateWidget _dateWidget;
  late UserNameWidget _userNameWidget;

  StoryColumn(this._story) {
    _dateWidget = DateWidget(this._story.dateTime);
    _userNameWidget = UserNameWidget(this._story.user);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: EdgeInsets.only(bottom: 4, top: 32), child: _dateWidget),
      _userNameWidget
    ]);
  }
}
