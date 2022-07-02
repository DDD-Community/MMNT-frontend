//singleTon
import 'package:flutter/material.dart';

class MmntStyle {
  late Color _mainBlackColor;
  late Color _mainWhiteColor;
  late Color _primaryColor;
  late Color _secondColor;
  late Color _primaryDisable;
  late Color _secondDisable;
  late Color _primaryError;
  late Color _secondError;
  late Color _secondBlack;

  static final MmntStyle _instance = MmntStyle._internal();
  factory MmntStyle() => _instance;

  MmntStyle._internal() {
    _mainBlackColor = Color(0xFF181818);
    _mainWhiteColor = Color(0xFFFFFFFF);
    _primaryColor = Color(0xFF1E5EFF);
    _secondColor = Color(0xFF5894FC);
    _primaryDisable = Color(0xFF707077);
    _secondDisable = Color(0xFFD9D9D9);
    _primaryError = Color(0xFFFD6744);
    _secondError = Color(0xFFFF6060);
    _secondBlack = Color(0xFF1E1E21);
  }

  get mainBlack => _mainBlackColor;
  get mainWhite => _mainWhiteColor;
  get primary => _primaryColor;
  get second => _secondColor;
  get primaryDisable => _primaryDisable;
  get secondDisable => _secondDisable;
  get primaryError => _primaryError;
  get secondError => _secondError;
  get secondBlack => _secondBlack;
}
