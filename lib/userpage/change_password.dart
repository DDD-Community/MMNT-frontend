import 'package:dash_mement/component/toast/mmnterror_toast.dart';
import 'package:dash_mement/style/mmnt_style.dart';
import 'package:dash_mement/userpage/userinfo_arguments.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../style/story_textstyle.dart';

class ChangePassword extends StatefulWidget {
  static const routeName = 'change-password-screen';
  final UserInfoArguments _args;

  const ChangePassword(this._args, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChangePassword();
  }
}

class _ChangePassword extends State<ChangePassword> {
  final _formPasswordKey = GlobalKey<FormState>();
  final _passwordFirstController = TextEditingController();
  final _passwordSecondController = TextEditingController();
  late FocusNode _secondFocus;
  late FToast _ftoast;

  bool _firstObscure = true;
  bool _secondObscure = true;
  bool _inputAll = false;

  @override
  void initState() {
    _secondFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _secondFocus.dispose();
    _passwordFirstController.dispose();
    _passwordSecondController.dispose();
    super.dispose();
  }

  void _checkInputAll() {
    if (_passwordFirstController.text != "" &&
        _passwordSecondController.text != "") {
      setState(() {
        _inputAll = true;
      });
    } else {
      setState(() {
        _inputAll = false;
      });
    }
  }

  void _showErrorToast(String text, double width) {
    Widget toast = MnmtErrorToast(message: text, width: width);
    final viewInsets = EdgeInsets.fromWindowPadding(
        WidgetsBinding.instance.window.viewInsets,
        WidgetsBinding.instance.window.devicePixelRatio);
    _ftoast.showToast(
        child: toast,
        gravity: ToastGravity.TOP,
        toastDuration: Duration(milliseconds: 1500),
        positionedToastBuilder: (context, child) => Positioned(
            bottom: viewInsets.bottom + 80,
            left: 0.0,
            right: 0.0,
            child: child));
  }

  String _getCurrentUserToken() {
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjMxIiwiZW1haWwiOiJkb25nd29uMDAwMTAzQGdtYWlsLmNvbSIsImlhdCI6MTY2MTA5NDI5MSwiZXhwIjoxNjYyMzAzODkxfQ.UdoMioa1Sh5pRB-5WPzclnwsXpP4KkhjkS37BnDGDoc";
  }

  void _updatePassword() async {
    final url = Uri.parse('https://dev.mmnt.link/user');
    final token = _getCurrentUserToken();
    var data = <String, dynamic>{
      "email": this.widget._args.email,
      "password": _passwordFirstController.text,
      "nickname": this.widget._args.nickname
    };
    var body = json.encode(data);

    final response = await http.patch(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'bearer $token'
        },
        body: body);

    // 추가적인 반응 없나요?
    Navigator.of(context).pop();

    try {} catch (e) {
      _ftoast = FToast();
      _ftoast.init(context);
      _showErrorToast("비밀번호 수정에 실패했습니다.", 300);
    }
  }

  void _checkPassword() {
    _ftoast = FToast();
    _ftoast.init(context);
    //"^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?&])[A-Za-z\d$@$!%*#?&]{8,}$"
    RegExp passwordReg = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?&])[A-Za-z\d$@$!%*#?&]{8,}$');
    if (!_inputAll) {
      _showErrorToast("비밀번호화 비밀번호 확인까지 모두 작성해주세요", 340);
    } else if (_passwordFirstController.text !=
        _passwordSecondController.text) {
      _showErrorToast("비밀번호 확인을 제대로 작성해주세요", 300);
    } else if (!passwordReg.hasMatch(_passwordFirstController.text)) {
      _showErrorToast("영문,숫자,특수문자를 포함해 10자 이상 작성해주세요", 380);
    } else {
      _updatePassword();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MmntStyle().mainBlack,
        appBar: AppBar(
          backgroundColor: MmntStyle().mainBlack,
          centerTitle: true,
          title: Text("비밀번호 변경", style: StoryTextStyle().appBarWhite),
          shadowColor: Colors.transparent,
        ),
        body: SafeArea(
            child: Form(
                key: _formPasswordKey,
                child: CustomScrollView(slivers: [
                  SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(children: [
                        Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("새 비밀번호를 입력하세요"),
                                  TextFormField(
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: _firstObscure,
                                    autofocus: true,
                                    controller: _passwordFirstController,
                                    cursorColor: Colors.white,
                                    decoration: InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        hintText: "비밀번호 (영문+숫자+특수문자 10자 이상)",
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _firstObscure
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () => setState(() {
                                            _firstObscure = !_firstObscure;
                                          }),
                                        )),
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context)
                                            .requestFocus(_secondFocus),
                                    onChanged: (value) => _checkInputAll(),
                                  ),
                                  TextFormField(
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      obscureText: _secondObscure,
                                      focusNode: _secondFocus,
                                      controller: _passwordSecondController,
                                      cursorColor: Colors.white,
                                      decoration: InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        hintText: "비밀번호 확인",
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _secondObscure
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () => setState(() {
                                            _secondObscure = !_secondObscure;
                                          }),
                                        ),
                                      ),
                                      onChanged: (value) => _checkInputAll())
                                ])),
                        const Spacer(),
                        ElevatedButton(
                            onPressed: () => _checkPassword(),
                            style: ElevatedButton.styleFrom(
                                primary: _inputAll
                                    ? MmntStyle().primary
                                    : MmntStyle().primaryDisable,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0)),
                                fixedSize: Size(
                                    MediaQuery.of(context).size.width, 54)),
                            child: Text(
                              "비밀번호 변경하기",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ))
                      ])),
                ]))));
  }
}
