import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordCheckController = TextEditingController();
  final verificationController = TextEditingController();
  bool isVerificationMailSent = false;
  bool isVerificationMatch = false;


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordCheckController.dispose();
    super.dispose();
  }

  void emailVerification() async {
    try {
      var response = await Dio().post('https://dev.mmnt.link/auth', data: {'email': emailController.text});

      print(response);
      if(response.data['isSuccess']) {
        setState(() {
          isVerificationMailSent = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void checkVerification() async {
    try {
      var response = await Dio().post('https://dev.mmnt.link/auth/verification', data: {'email': emailController.text, 'value': verificationController.text});

      print(response);
      if(response.data['isSuccess']) {
        setState(() {
          isVerificationMatch = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void postSignup() async {
    try {
      var response = await Dio().post('https://dev.mmnt.link/user/sign-up', data: {'email': emailController.text, 'value': passwordController.text});

      print(response);
      if(response.data['isSuccess']) {
        // 회원가입 완료, 로그인 페이지로 이동
      }
    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('회원가입'),
            leading: GestureDetector(
              child: const Icon( Icons.arrow_back_ios,),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 0,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        validator: (value) => EmailValidator.validate(value!) ? null : "Please enter a valid email",
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: '이메일 주소를 입력해 주세요',
                          ),
                      ),
                    ),
                    ElevatedButton(
                        child: const Text('인증 받기'),
                        onPressed: () {
                          emailVerification();
                        }, )
                  ],
                ),


                Visibility(
                  visible: isVerificationMailSent,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: verificationController,
                        decoration: InputDecoration(
                            hintText: '인증번호 입력'
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text(
                          '인증 번호 확인',
                        ),
                        onPressed: () {
                          checkVerification();
                        },
                      ),
                    ],
                  ),

                ),


                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                      hintText: '비밀번호 (영문+숫자+특수문자 10자 이상)'
                  ),

                ),
                TextFormField(
                  controller: passwordCheckController,
                  decoration: InputDecoration(
                      hintText: '비밀번호 확인'
                  ),

                ),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: isVerificationMatch ? null : Colors.grey,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text(
                        '회원가입',
                      ),
                      onPressed: () {
                        if(! isVerificationMatch) return;

                      },
                    ),
                    SizedBox(height: 50.h,)
                  ],
                ))
              ],
            ),
          )),
    );
  }
}

