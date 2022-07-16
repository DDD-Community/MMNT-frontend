import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';

class StoryText extends StatelessWidget {
  late String _title;
  late String _message;

  StoryText(this._title, this._message) {}

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.74,
        // decoration: BoxDecoration(color: Color(0x99000000)),
        child: Padding(
            padding: EdgeInsets.all(22),
            child: Column(children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 28),
                  child: Text(
                    _title,
                    style: StoryTextStyle().title,
                    textAlign: TextAlign.center,
                  )),
              Container(
                  decoration: BoxDecoration(
                      color: Color(0x99000000),
                      borderRadius: BorderRadius.circular(4)),
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        _message,
                        style: StoryTextStyle().message,
                        textAlign: TextAlign.center,
                      )))
            ])));
  }
}
