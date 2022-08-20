import 'package:dash_mement/component/error_dialog.dart';
import 'package:dash_mement/screens/sign_in_screen.dart';
import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../constants/style_constants.dart';
import '../models/error_model.dart';
import '../providers/app_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  static const routeName = '/sign-up-screen';

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
  final _formKey = GlobalKey<FormState>();
  FocusNode _emailFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordCheckController.dispose();
    super.dispose();
  }

  void emailVerification() async {
    try {
      var response = await Dio().post('https://dev.mmnt.link/auth',
          data: {'email': emailController.text.trim()});

      print(response);
      if (response.data['isSuccess']) {
        setState(() {
          isVerificationMailSent = true;
        });
      }
    } on DioError catch (error) {
      var errorMsg = ErrorModel.fromJson(error.response?.data);
      errorDialog(context, errorMsg.message.toString());
    }
  }

  void checkVerification() async {
    try {
      Map<String, dynamic> map = {
        "email": emailController.text.trim(),
        "value": verificationController.text.trim()
      };

      var response =
          await Dio().post('https://dev.mmnt.link/auth/verification', data: map);

      if (response.data['isSuccess']) {
        setState(() {
          isVerificationMatch = true;
        });
      }
    } catch (e) {
      print(e);
      errorDialog(context, '인증 번호가 일치하지 않습니다.');
    }
  }

  void postSignup() async {
    Provider.of<AppProvider>(context, listen: false).updateAppState(AppStatus.loading);
    Map<String, dynamic> map = {
      'email': emailController.text,
      'password': passwordController.text
    };
    try {
      var response = await Dio().post('https://dev.mmnt.link/user/sign-up',data: map);

      if (response.data['isSuccess']) {
        Navigator.pushReplacementNamed(context, SignInScreen.routeName);
      }
    } on DioError catch (error) {
      var errorMsg = ErrorModel.fromJson(error.response?.data);
      errorDialog(context, errorMsg.message.toString());
    } finally {
      Provider.of<AppProvider>(context, listen: false).updateAppState(AppStatus.loaded);
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
              child: const Icon(
                Icons.arrow_back_ios,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              20.h,
              20.w,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => EmailValidator.validate(value!)
                            ? null
                            : "Please enter a valid email",
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: '이메일 주소를 입력해 주세요',
                          hintStyle: kGray14.copyWith(fontWeight: FontWeight.w500,)
                        ),
                      ),
                    ),
                    ElevatedButton(
                      child: const Text('인증 받기'),
                      onPressed: () {
                        emailVerification();
                      },
                    )
                  ],
                ),
                Visibility(
                  visible: isVerificationMailSent,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: verificationController,
                        decoration: InputDecoration(hintText: '인증번호 입력',
                            hintStyle: kGray14.copyWith(fontWeight: FontWeight.w500,)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text(
                          '인증 번호 확인',
                        ),
                        onPressed: () {
                          if (verificationController.text.isEmpty)
                            errorDialog(context, '인증번호를 입력해주세요');
                          checkVerification();
                        },
                      ),
                    ],
                  ),
                ),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        focusNode: _passwordFocus,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        controller: passwordController,
                        decoration: InputDecoration(
                            hintText: '비밀번호 (영문+숫자+특수문자 10자 이상)', hintStyle: kGray14.copyWith(fontWeight: FontWeight.w500,),),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }

                          // RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{10,}$');
                          // if(!regex.hasMatch(value)){
                          //   return '특수문자, 대소문자, 숫자 포함 10자 이상 입력하세요.';
                          // }

                          return null;

                          if (passwordController.text != passwordCheckController.text) {
                            return '비밀번호가 일치하지 않습니다';
                          }

                          return null;
                        },
                      ),
                      TextFormField(
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        controller: passwordCheckController,
                        decoration: InputDecoration(hintText: '비밀번호 확인',
                            hintStyle: kGray14.copyWith(fontWeight: FontWeight.w500,)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          if (passwordController.text != passwordCheckController.text) {
                            return '비밀번호가 일치하지 않습니다';
                          }
                          return null;
                        },
                      ),
                    ],
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
                        // if (!isVerificationMatch) {
                        //   errorDialog(context, '인증 후 회원가입 가능합니다');
                        //   return;
                        // }

                        if (_formKey.currentState!.validate()) {
                          postSignup();
                        }
                      },
                    ),
                    SizedBox(
                      height: 10.h,
                    )
                  ],
                ))
              ],
            ),
          )),
    );
  }
}
