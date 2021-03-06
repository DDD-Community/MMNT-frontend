import 'dart:ui';

import 'package:dash_mement/style/mmnt_style.dart';
import 'package:flutter/material.dart';

/*
스토리에 관한 텍스트 스타일 모음
Singleton임
*/
class StoryTextStyle {
  late TextStyle _dateTime;
  late TextStyle _user;
  late TextStyle _title;
  late TextStyle _message;
  late TextStyle _trackName;
  late TextStyle _artist;
  late TextStyle _appBarBlack;
  late TextStyle _appBarWhite;
  late TextStyle _buttonBlack;
  late TextStyle _buttonWhite;

  static final StoryTextStyle _instance = StoryTextStyle._internal();

  factory StoryTextStyle() => _instance;

  StoryTextStyle._internal() {
    _dateTime = TextStyle(
        fontFamily: "Pretendard",
        letterSpacing: -0.1,
        color: MmntStyle().mainWhite,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        height: 1.2 // 수정 필요
        );

    _user = TextStyle(
        fontFamily: "Pretendard",
        letterSpacing: -0.1,
        color: MmntStyle().mainWhite,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.2 // 수정 필요
        );
    _title = TextStyle(
        fontSize: 18,
        fontFamily: "Pretendard",
        fontWeight: FontWeight.bold,
        letterSpacing: -0.41,
        color: MmntStyle().mainWhite);
    _message = TextStyle(
      fontSize: 14,
      fontFamily: "Pretendard",
      fontWeight: FontWeight.w500,
      letterSpacing: -0.1,
      color: MmntStyle().mainWhite,
      height: 1.6, // 수정 필요
    );
    _trackName = TextStyle(
        fontSize: 16,
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
        color: MmntStyle().mainWhite);
    _artist = TextStyle(
        fontSize: 12,
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        letterSpacing: -0.43,
        color: Color(0xFF9E9FA9));
    _appBarBlack = TextStyle(
        fontSize: 18,
        fontFamily: 'Pretendard',
        letterSpacing: -0.41,
        fontWeight: FontWeight.w700,
        color: MmntStyle().mainBlack);
    _appBarWhite = TextStyle(
        fontSize: 18,
        fontFamily: 'Pretendard',
        letterSpacing: -0.41,
        fontWeight: FontWeight.w700,
        color: MmntStyle().mainWhite);
    _buttonBlack = TextStyle(
        fontSize: 17,
        fontFamily: 'Pretendard',
        letterSpacing: -0.41,
        fontWeight: FontWeight.w600,
        color: MmntStyle().mainBlack);
    _buttonWhite = TextStyle(
        fontSize: 17,
        fontFamily: 'Pretendard',
        letterSpacing: -0.41,
        fontWeight: FontWeight.w600,
        color: MmntStyle().mainWhite);
  }

  get dateTime => _dateTime;
  get user => _user;
  get title => _title;
  get message => _message;
  get trackName => _trackName;
  get artist => _artist;
  get appBarBlack => _appBarBlack;
  get appBarWhite => _appBarWhite;
  get buttonBlack => _buttonBlack;
  get buttonWhite => _buttonWhite;
}
