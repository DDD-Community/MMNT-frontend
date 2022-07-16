import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  static const id = '/splash';

  @override
  Widget build(BuildContext context) {
    bool lightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
        backgroundColor: const Color(0xff000000),
        body: Center(child: Image.asset('assets/gif/MMNT_logo animation.gif')));
  }
}
