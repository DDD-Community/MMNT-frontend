import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'login_screen.dart';

class Splash extends StatefulWidget {
  static const routeName = '/splash';

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    int waitTime = kDebugMode ? 1 : 4;
    // method chaining으로 등록과 함께 실행, 이벤트 리스너 등록
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: waitTime))
          ..forward()
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            }
          });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF1E5EFF),
        body: Center(child: Image.asset('assets/gif/splash_logo.gif')));
  }
}
