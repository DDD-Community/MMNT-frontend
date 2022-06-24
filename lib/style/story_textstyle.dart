import 'package:flutter/material.dart';

/*
스토리에 관한 텍스트 스타일 모음
Singleton임
*/
class StoryTextStyle {
  late TextStyle _basic_info;
  late TextStyle _title;
  late TextStyle _message;
  late TextStyle _trackName;
  late TextStyle _artist;

  static final StoryTextStyle _instance = StoryTextStyle._internal();

  factory StoryTextStyle() => _instance;

  StoryTextStyle._internal() {
    _basic_info = TextStyle(
        fontFamily: "Pretendard",
        letterSpacing: -0.1,
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 11,
        height: 1.2 // 수정 필요
        );
    _title = TextStyle(
        fontSize: 18,
        fontFamily: "Pretendard",
        fontWeight: FontWeight.bold,
        letterSpacing: -0.41,
        color: Colors.white);
    _message = TextStyle(
      fontSize: 14,
      fontFamily: "Pretendard",
      fontWeight: FontWeight.w500,
      letterSpacing: -0.1,
      color: Colors.white,
      height: 1.6, // 수정 필요
    );
    _trackName = TextStyle(
        fontSize: 20,
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
        color: Color(0xFF000000));
    _artist = TextStyle(
        fontSize: 11,
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        letterSpacing: -0.43,
        color: Color(0xFF000000));
  }

  get basicInfo => _basic_info;
  get title => _title;
  get message => _message;
  get trackName => _trackName;
  get artist => _artist;
}
