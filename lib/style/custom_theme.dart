import 'package:dash_mement/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/*
현재는 dark모드만 지원하고 있음

- MMNT Design System과의 비교
NAME         SIZE  WEIGHT  SPACING   장표
headline1    34.0  regular    1   => Large Title
headline2    18.0  bold      -2   => Headline 1
headline3    21.0  semiBold  -2   => Title 2, Headlind 2
headline4    20.0  semiBold  -2   => Title 3
headline5    28.0  regular    1   => Title 1
headline6    14.0  regular   -1   => Sub Headline, Card body
subtitle1    16.0  semiBold  -3   => Callout
subtitle2    13.0  regular   -3   => Footnote
body1        17.0  regular   -3   => Body 1
body2(기본)   15.0  regular   -3   => Body 2
button       14.0  medium    -2   => Toast
caption      12.0  regular   -3   => Caption 1
overline     11.0  medium    -4   => Caption 2
*/

/*
Regular: w.400
Medium: w.500
SemiBold: w.600
Bold: w.700
 */

TextTheme _customDarkThemesTextTheme(TextTheme base) {
  return base.copyWith(
    headline1: base.headline1?.copyWith(
      fontFamily: "Pretendard",
      fontSize: 34.0.sp,
      color: Colors.white,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.0,
    ),
    headline2: base.headline2?.copyWith(
      fontFamily: "Pretendard",
      fontSize: 18.0.sp,
      color: Colors.white,
      fontWeight: FontWeight.w700,
      letterSpacing: -2.0,
    ),
    headline3: base.headline3?.copyWith(
        fontFamily: "Pretendard",
        fontSize: 21.0.sp,
        color: Colors.white,
        fontWeight: FontWeight.w600,
        letterSpacing: -2.0,
    ),
    headline4: base.headline4?.copyWith(
        fontFamily: "Pretendard",
        fontSize: 20.0.sp,
        color: Colors.white,
        fontWeight: FontWeight.w600,
        letterSpacing: -2.0,
    ),
    headline5: base.headline5?.copyWith(
        fontFamily: "Pretendard",
        fontSize: 28.0.sp,
        color: Colors.white,
        fontWeight: FontWeight.w400,
        letterSpacing: 1,
    ),
    headline6: base.headline6?.copyWith(
        fontFamily: "Pretendard",
        fontSize: 14.0.sp,
        color: Colors.white,
        fontWeight: FontWeight.w400,
        letterSpacing: -1,
    ),
    subtitle1: base.subtitle1?.copyWith(
      fontFamily: "Pretendard",
      fontSize: 16.0.sp,
      color: Colors.white,
      fontWeight: FontWeight.w600,
      letterSpacing: -1,
    ),
    subtitle2: base.subtitle2?.copyWith(
      fontFamily: "Pretendard",
      fontSize: 13.0.sp,
      color: Colors.white,
      fontWeight: FontWeight.w400,
      letterSpacing: -3,
    ),
    bodyText1: base.bodyText1?.copyWith(
      fontFamily: "Pretendard",
      fontSize: 17.0.sp,
      color: Colors.white,
      fontWeight: FontWeight.w400,
      letterSpacing: -3,
    ),
    bodyText2: base.bodyText2?.copyWith(
      fontFamily: "Pretendard",
      fontSize: 15.0.sp,
      color: Colors.white,
      fontWeight: FontWeight.w400,
      letterSpacing: -1,
    ),
    button: base.button?.copyWith(
      fontFamily: "Pretendard",
      fontSize: 14.0.sp,
      color: Colors.white,
      fontWeight: FontWeight.w500,
      letterSpacing: -2,
    ),
    caption: base.caption?.copyWith(
      fontFamily: "Pretendard",
      fontSize: 12.0.sp,
      color: Colors.white,
      fontWeight: FontWeight.w400,
      letterSpacing: -3,
    ),
    overline: base.overline?.copyWith(
      fontFamily: "Pretendard",
      fontSize: 11.0.sp,
      color: Colors.white,
      fontWeight: FontWeight.w400,
      letterSpacing: -4,
    ),
  );
}

ThemeData customDarkTheme() {
  final ThemeData darkTheme = ThemeData.dark();
  return darkTheme.copyWith(
      textTheme: _customDarkThemesTextTheme(darkTheme.textTheme),
      highlightColor: Colors.yellow,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
          centerTitle: true,
          // TODO: Theme.of(context).textTheme.headline2가 안됨
          // titleTextStyle: kGrayBold18,
          color: Colors.black,
          iconTheme: IconThemeData(
            color: kAppbarIconColor,
          )),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF1E5EFF),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(primary: kPrimaryColor)),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              primary: const Color(0xFF707077),
              textStyle: TextStyle(fontSize: 15.sp))),
      inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
              borderSide:
              BorderSide(color: kTextFormFieldUnderlineColor, width: 1.5)))
  );
}


ThemeData customLightTheme() {
  TextTheme _customLightThemesTextTheme(TextTheme base) {
    return base.copyWith(
      headline1: base.headline1?.copyWith(
        fontFamily: "Pretendard",
        fontSize: 22.0,
        color: Colors.green,
      ),
      headline6: base.headline6?.copyWith(fontSize: 15.0, color: Colors.orange),
      headline4: base.headline1?.copyWith(
        fontSize: 24.0,
        color: Colors.white,
      ),
      headline3: base.headline1?.copyWith(
        fontSize: 22.0,
        color: Colors.grey,
      ),
      caption: base.caption?.copyWith(
        color: Color(0xFFCCC5AF),
      ),
      // bodyText2가 기본 텍스트 스타일
      bodyText2: base.bodyText2?.copyWith(color: Color(0xFF807A6B)),
      bodyText1: base.bodyText1?.copyWith(color: Colors.brown),
    );
  }

  final ThemeData lightTheme = ThemeData.light();
  return lightTheme.copyWith(
    textTheme: _customLightThemesTextTheme(lightTheme.textTheme),
    primaryColor: Color(0xffce107c),
    indicatorColor: Color(0xFF807A6B),
    scaffoldBackgroundColor: Color(0xFFF5F5F5),
    accentColor: Color(0xFFFFF8E1),
    primaryIconTheme: lightTheme.primaryIconTheme.copyWith(
      color: Colors.white,
      size: 20,
    ),
    iconTheme: lightTheme.iconTheme.copyWith(
      color: Colors.white,
    ),
    buttonColor: Colors.white,
    backgroundColor: Colors.white,
    tabBarTheme: lightTheme.tabBarTheme.copyWith(
      labelColor: Color(0xffce107c),
      unselectedLabelColor: Colors.grey,
    ),
    buttonTheme: lightTheme.buttonTheme.copyWith(buttonColor: Colors.red),
    // cursorColor: Colors.deepPurple,
    errorColor: Colors.red,
  );
}

