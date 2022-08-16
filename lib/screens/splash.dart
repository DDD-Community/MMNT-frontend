import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  static const id = '/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff000000),
        // backgroundColor: Colors.red,
        body: Center(child: Image.asset('assets/gif/splash.gif')));
  }
}
