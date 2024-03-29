import 'package:dash_mement/screens/sign_in_screen.dart';
import 'package:dash_mement/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/color_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const routeName = "/";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const id = '/';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 50.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: 190.h,
                    width: 190.h,
                    child: Image.asset('assets/images/onboarding.png')),
                Text(
                  '오늘의 모먼트',
                  style: Theme.of(context).textTheme.headline3,
                ),
                SizedBox(
                  height: 15.h,
                ),
                Text('지금 이순간의', style: Theme.of(context).textTheme.bodyText2?.copyWith(color: kDisabledColor)),
                SizedBox(
                  height: 10.h,
                ),
                Text('음악과 풍경을 기록해보세요', style: Theme.of(context).textTheme.bodyText2?.copyWith(color: kDisabledColor)),
              ],
            )),
            SizedBox(
                height: 54.h,
                width: 335.w,
                child: ElevatedButton(
                  child: Text(
                    '이메일 주소로 로그인',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pushNamed(context, SignInScreen.routeName);
                  },
                )),
            SizedBox(
              height: 10.h,
            ),
            SizedBox(
                height: 54.h,
                width: 335.w,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        child: Text('회원가입', style: Theme.of(context).textTheme.subtitle1?.copyWith(color: kDisabledColor)),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pushNamed(context, SignUpScreen.routeName);
                        },
                      ),
                      Container(
                        width: 2,
                        height: 15,
                        color: kDisabledColor,
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                        },
                        child: Text('로그인문의', style: Theme.of(context).textTheme.subtitle1?.copyWith(color: kDisabledColor)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
