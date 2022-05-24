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
        ),
        home: MapScreen(),
      ),
    );
  }
}