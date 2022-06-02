import 'package:dash_mement/providers/map_provider.dart';
import 'package:dash_mement/screens/map_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => MapProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            title: 'dash_moment',
            debugShowCheckedModeBanner: false,
            home: MapScreen(),

            // Dark theme 기반
            theme: ThemeData(
              fontFamily: 'Pretendard',
              brightness: Brightness.dark,
              highlightColor: Colors.yellow,
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Color(0xFFFD6744),
              ),
              textTheme: TextTheme(

                // bodyText2가 기본 텍스트 스타일
                bodyText2: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
            ),
          );
        },
      ),
    );
  }
}