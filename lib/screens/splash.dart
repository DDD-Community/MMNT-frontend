import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  static const id = '/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E5EFF),
      body: Center(child: Image.asset('assets/gif/splash.gif')));
  }
}
