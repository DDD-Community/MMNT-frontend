import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../component/error_dialog.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  void postSignin() async {
    try {
      var response = await Dio().post('https://dev.mmnt.link/user/sign-in', data: {'email': emailController.text.trim(), 'password': passwordController.text.trim()});

      print(response);
      if(response.data['isSuccess']) {
        Navigator.pushNamed(context, '/map-screen');
      }
    } catch (e) {
      print(e);
      errorDialog(context, '${e.toString()}');
    }
  }


  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('로그인'),
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 0,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      '이메일',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  validator: (value) => EmailValidator.validate(value!) ? null : "Please enter a valid email",
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: '이메일 주소를 입력해 주세요',
                  ),
                ),

                SizedBox(height: 28.h,),

                Row(
                  children: [
                    Text(
                      '비밀번호',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                      hintText: '비밀번호 (영문+숫자+특수문자 10자 이상)'
                  ),

                ),

                Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 50.h,),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text(
                            '로그인',
                          ),
                          onPressed: () {
                            postSignin();
                          },
                        ),
                      ],
                    ))
              ],
            ),
          )),
    );
  }
}

