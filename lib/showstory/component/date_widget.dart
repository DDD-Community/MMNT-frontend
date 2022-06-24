import 'package:dash_mement/domain/story.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';

class DateWidget extends StatelessWidget {
  late String _date;
  late String _time;

  DateWidget([DateTime? dateTime]) {
    final DateTime now;
    if (dateTime == null) {
      now = DateTime.now();
    } else {
      now = dateTime;
    }
    _date = "${now.year}년 ${now.month}월 ${now.day}일";
    _time = now.hour > 12
        ? "오후 ${now.hour - 12}시 ${now.minute}분"
        : "오전 ${now.hour}시 ${now.minute}분";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      Text(_date, style: StoryTextStyle().basicInfo),
      Text(_time, style: StoryTextStyle().basicInfo)
    ]));
  }
}
