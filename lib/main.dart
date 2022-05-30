import 'package:dash_mement/providers/map_provider.dart';
import 'package:dash_mement/screens/map_screen.dart';
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
      child: MaterialApp(

        title: 'dash_moment',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: TextTheme(
            bodyText2: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700),

            // bodyText2가 기본 텍스트 스타일로 적용됨
            // bodyText1: TextStyle(color: Colors.black),
            // headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            // appbar타이틀
            // headline6: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: MapScreen(),
      ),
    );
  }
}