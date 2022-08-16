import 'package:dash_mement/constants/style_constants.dart';
import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../component/error_dialog.dart';
import '../models/error_model.dart';
import '../constants/token_temp_file.dart' as Token;

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
      Map<String, dynamic> map = {
        "email": emailController.text,
        "password": passwordController.text,
      };

      var response = await Dio().post('https://dev.mmnt.link/user/sign-in', data: map);

      if(response.data['isSuccess']) {
        // TODO shared preference로 토큰 관리
        Token.jwt_token = response.data['result']['accessToken'];
        Navigator.pushNamed(context, '/map-screen');
      }
    } on DioError catch (error) {
      var errorMsg = ErrorModel.fromJson(error.response?.data);
      errorDialog(context, errorMsg.message.toString());
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
                  children: const [
                    Text(
                      '이메일',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => EmailValidator.validate(value!) ? null : "Please enter a valid email",
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: '이메일 주소를 입력해 주세요',
                    hintStyle: kGray14.copyWith(fontWeight: FontWeight.w500,),
                  ),
                ),

                SizedBox(height: 28.h,),

                Row(
                  children: [
                    Text(
                      '비밀번호',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  obscureText: true,
                  // enableSuggestions: false,
                  // autocorrect: false,
                  controller: passwordController,
                  decoration: InputDecoration(
                      hintText: '비밀번호 (영문+숫자+특수문자 10자 이상)',
                      hintStyle: kGray14.copyWith(fontWeight: FontWeight.w500,)
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

