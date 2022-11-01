import 'package:dash_mement/constants/style_constants.dart';
import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../component/error_dialog.dart';
import '../models/error_model.dart';
import '../providers/app_provider.dart';


import 'package:dash_mement/screens/sign_in_screen.dart';
import '../apis/api_manager.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({Key? key}) : super(key: key);
  static const routeName = '/password-change-screen';

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
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

  void changePassword() async {
    Provider.of<AppProvider>(context, listen: false).updateAppState(AppStatus.loading);
    String email =  Provider.of<AppProvider>(context, listen: false).userEmail;


    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    Options options = Options(
        headers: {'Authorization':'Bearer $token'}
    );

    Map<String, dynamic> map = {
      "email": email,
      'password': passwordController.text,
    };
    try {
      var response = await Dio().patch('https://dev.mmnt.link/user',data: map, options: options);

      if (response.data['isSuccess']) {
        Fluttertoast.showToast(
            msg: '비밀번호가 변경되었습니다.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
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
            title: const Text('비밀번호 변경'),
            leading:  GestureDetector(
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
                Text('새 비밀번호를 입력하세요', style: kWhiteBold15,),


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
                            primary: Colors.grey,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text(
                            '비밀번호 변경하기',
                          ),
                          onPressed: () {

                            if (_formKey.currentState!.validate()) {
                              changePassword();
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





