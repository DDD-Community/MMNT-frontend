import 'package:dash_mement/style/mmnt_style.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:dash_mement/userpage/change_password.dart';
import 'package:dash_mement/userpage/userinfo_arguments.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserSetting extends StatefulWidget {
  static const String routeName = "user-setting-screen";

  @override
  State<StatefulWidget> createState() {
    return _UserSetting();
  }
}

class _UserSetting extends State<UserSetting> {
  String _imgUrl = "";
  String _email = "";
  String _nickname = "";

  void _changeImage() {
    print("test");
  }

  String _getCurrentUserToken() {
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjMxIiwiZW1haWwiOiJkb25nd29uMDAwMTAzQGdtYWlsLmNvbSIsImlhdCI6MTY2MTA5NDI5MSwiZXhwIjoxNjYyMzAzODkxfQ.UdoMioa1Sh5pRB-5WPzclnwsXpP4KkhjkS37BnDGDoc";
  }

  Future<Map<String, dynamic>> _getCurrentUser() async {
    final url = Uri.parse("https://dev.mmnt.link/user/profile-info");
    final token = await _getCurrentUserToken();
    final response = await http.get(url, headers: {
      "accept": "aplication/json",
      "Authorization": "Bearer $token"
    });

    Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
    print(json);

    return json["result"];
  }

  Widget _loginInfoButton(
      String title, String description, String buttonText, Function function) {
    return Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            Text(description,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF707077)))
          ]),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Color(0xFF2E2F35),
                  fixedSize: Size(64, 32),
                  textStyle:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              onPressed: () => function(),
              child: Text(buttonText))
        ]));
  }

  void _test() {
    print("test");
    print(_email);
  }

  void _setPassword() {
    Navigator.pushNamed(context, ChangePassword.routeName,
        arguments: UserInfoArguments(email: _email, nickname: _nickname));
  }

  void _withdrawal() {
    print("withdrawl");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MmntStyle().mainBlack,
      appBar: AppBar(
        backgroundColor: MmntStyle().mainBlack,
        centerTitle: true,
        title: Text("내 계정 관리", style: StoryTextStyle().appBarWhite),
        shadowColor: Colors.transparent,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error");
          } else if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            _imgUrl = snapshot.data!["profileUrl"];
            _email = snapshot.data!["email"];
            _nickname = snapshot.data!["nickname"];
            return Column(children: [
              Stack(children: [
                Padding(
                    padding: EdgeInsets.all(24),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(400),
                        child: Image.network(_imgUrl,
                            width: 105, height: 105, fit: BoxFit.cover))),
                Positioned(
                    bottom: 20,
                    right: MediaQuery.of(context).size.width * 0.05,
                    child: GestureDetector(
                        onTap: () => _changeImage(),
                        child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: MmntStyle().mainBlack, width: 3),
                                borderRadius: BorderRadius.circular(20)),
                            child: Image.asset("assets/images/change.png"))))
              ]),
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("닉네임",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16)),
                        Text(snapshot.data!["nickname"],
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFFD9D9D9)))
                      ])),
              Divider(
                thickness: 20,
                color: Colors.black,
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("로그인 정보",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18)),
                        Container(
                          width: 1,
                        )
                      ])),
              _loginInfoButton("이메일 주소", snapshot.data!["email"], "재인증", _test),
              _loginInfoButton("비밀번호", "***********", "변경", _setPassword),
              Container(
                  color: Colors.black,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: GestureDetector(
                          onTap: () => _withdrawal(),
                          child: Text("회원 탈퇴하기",
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14,
                                  color: Color(0xFF707077)))))),
              Expanded(
                child: Container(
                  color: Colors.black,
                ),
              )
            ]);
          }
        },
      ),
    );
  }
}

// class UserSetting extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: MmntStyle().mainBlack,
//         appBar: AppBar(
//           backgroundColor: MmntStyle().mainBlack,
//           centerTitle: true,
//           title: Text("내 계정 관리", style: StoryTextStyle().appBarWhite),
//           shadowColor: Colors.transparent,
//         ),
//         body: Column(children: [
//           UserInfoSetting(),
//           Divider(
//             thickness: 20,
//             color: Colors.black,
//           ),
//         ]));
//   }
// }

class UserInfoSetting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserInfoSetting();
  }
}

class _UserInfoSetting extends State<UserInfoSetting> {
  String _imgUrl = "";

  String _getCurrentUserToken() {
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjMxIiwiZW1haWwiOiJkb25nd29uMDAwMTAzQGdtYWlsLmNvbSIsImlhdCI6MTY2MTA5NDI5MSwiZXhwIjoxNjYyMzAzODkxfQ.UdoMioa1Sh5pRB-5WPzclnwsXpP4KkhjkS37BnDGDoc";
  }

  Future<Map<String, dynamic>> _getCurrentUser() async {
    final url = Uri.parse("https://dev.mmnt.link/user/profile-info");
    final token = await _getCurrentUserToken();
    final response = await http.get(url, headers: {
      "accept": "aplication/json",
      "Authorization": "Bearer $token"
    });

    Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
    print(json);

    return json["result"];
  }

  void _changeImage() {
    print("test");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        } else if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          _imgUrl = snapshot.data!["profileUrl"];
          return Column(children: [
            Stack(children: [
              Padding(
                  padding: EdgeInsets.all(24),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(400),
                      child: Image.network(_imgUrl,
                          width: 105, height: 105, fit: BoxFit.cover))),
              Positioned(
                  bottom: 20,
                  right: MediaQuery.of(context).size.width * 0.05,
                  child: GestureDetector(
                      onTap: () => _changeImage(),
                      child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: MmntStyle().mainBlack, width: 3),
                              borderRadius: BorderRadius.circular(20)),
                          child: Image.asset("assets/images/change.png"))))
            ]),
            Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("닉네임",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      Text(snapshot.data!["nickname"],
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFFD9D9D9)))
                    ]))
          ]);
        }
      },
    );
  }
}
