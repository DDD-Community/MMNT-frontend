import 'package:dash_mement/domain/story.dart';
import 'package:dash_mement/component/story/date_widget.dart';
import 'package:dash_mement/component/story/storytext_widget.dart';
import 'package:dash_mement/component/story/trackInfo_widget.dart';
import 'package:dash_mement/component/story/username_widget.dart';
import 'package:flutter/material.dart';

class StoryColumn extends StatelessWidget {
  late Story _story;
  late DateWidget _dateWidget;
  late UserNameWidget _userNameWidget;
  late TrackInfoWidget _trackInfoWidget;
  late StoryText _storyText;

  StoryColumn(this._story) {
    _dateWidget = DateWidget(this._story.dateTime);
    _userNameWidget = UserNameWidget.fromId(this._story.user);
    _trackInfoWidget = TrackInfoWidget(this._story.track, this._story.artist);
    _storyText = StoryText(this._story.title, this._story.msg);
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(children: [
        Padding(
            padding: EdgeInsets.only(bottom: 12, top: 28), child: _dateWidget),
        _userNameWidget
      ]),
      _storyText,
      Padding(padding: EdgeInsets.only(bottom: 42), child: _trackInfoWidget)
    ]);
  }
}
