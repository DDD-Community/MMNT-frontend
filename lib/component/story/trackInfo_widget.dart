import 'package:dash_mement/style/mmnt_style.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_overflow/animated_overflow.dart';

class TrackInfoWidget extends StatelessWidget {
  late final String _trackName;
  late final String _artist;
  late Widget _trackInfoColumn;
  static const double _limitWidth = 150;

  TrackInfoWidget(String trackName, String artist) {
    _trackName = trackName;
    _artist = artist;
    _trackInfoColumn = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AnimatedOverflow(
              maxWidth: _limitWidth,
              animatedOverflowDirection: AnimatedOverflowDirection.HORIZONTAL,
              child: Text(
                _trackName,
                style: StoryTextStyle().trackName,
              )),
          Container(height: 4, width: 4),
          AnimatedOverflow(
              maxWidth: _limitWidth,
              animatedOverflowDirection: AnimatedOverflowDirection.HORIZONTAL,
              child: Text(
                _artist,
                style: StoryTextStyle().artist,
              )),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.76,
        height: 78,
        decoration: BoxDecoration(
            color: MmntStyle().secondBlack,
            borderRadius: BorderRadius.circular(8)),
        child: Padding(
            padding: EdgeInsets.only(left: 22, right: 22),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _trackInfoColumn,
                  Container(
                      width: 40,
                      height: 40,
                      child: Lottie.asset("assets/json/equalizer.json"))
                ])));
  }
}
