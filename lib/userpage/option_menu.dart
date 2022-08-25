import 'package:dash_mement/style/mmnt_style.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:dash_mement/userpage/user_setting.dart';
import 'package:flutter/material.dart';

class OptionMenu extends StatelessWidget {
  static const String routeName = "/option-menu-screen";

  Widget _menuButton(
      String imgPath, String text, Function function, BuildContext context) {
    return GestureDetector(
      child: Container(
          color: MmntStyle().mainBlack,
          margin: EdgeInsets.fromLTRB(20, 22, 22, 22),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Image.asset(imgPath),
              Container(width: 16), // space
              Text(text,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFFD9D9D9)))
            ]),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
            )
          ])),
      onTap: () => function(context),
    );
  }

  Widget _versionText(String version) {
    return Text("현재버전 $version",
        style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: MmntStyle().primaryDisable));
  }

  void _test(BuildContext context) {
    print(context);
  }

  void _navigateUserSetting(BuildContext context) {
    Navigator.pushNamed(context, UserSetting.routeName);
  }

  void _logout() {
    print("logout test");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MmntStyle().mainBlack,
        appBar: AppBar(
          backgroundColor: MmntStyle().mainBlack,
          centerTitle: true,
          title: Text("앱 설정", style: StoryTextStyle().appBarWhite),
          shadowColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Column(children: [
            _menuButton("assets/images/userprofile.png", "내 계정 관리",
                _navigateUserSetting, context),
            Divider(
              thickness: 20,
              color: Colors.black,
            ),
            _menuButton("assets/images/guard.png", "개인정보처리방침", _test, context),
            _menuButton("assets/images/info.png", "이용약관", _test, context),
            _menuButton("assets/images/chat.png", "서비스 소개", _test, context),
            _menuButton(
                "assets/images/speakerphone.png", "VOC 피드백", _test, context),
            GestureDetector(
                onTap: () => Navigator.of(context).push(PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) {
                      return LogoutAlert(acceptButton: _logout);
                    })),
                child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("로그아웃",
                        style: TextStyle(
                            color: MmntStyle().primaryError,
                            fontWeight: FontWeight.w700,
                            fontSize: 18)))),
            _versionText("0.0.0") // 버전 확인
          ]),
        ));
  }
}

class LogoutAlert extends StatelessWidget {
  Function acceptButton;
  LogoutAlert({required this.acceptButton}) {}
  void _acceptButtonClick(BuildContext context) {
    acceptButton();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.7),
        body: Center(
            child: Container(
                width: 272,
                height: 140,
                decoration: BoxDecoration(
                  color: MmntStyle().mainBlack,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(children: [
                      Text("로그아웃 하시겠습니까?",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      Container(height: 24), // space
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: MmntStyle().primaryDisable,
                                    fixedSize: Size(102, 48)),
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  "취소",
                                  style: TextStyle(
                                      color: Color(0xFFD9D9D9),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                )),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: MmntStyle().primary,
                                    fixedSize: Size(102, 48)),
                                onPressed: () => _acceptButtonClick(context),
                                child: Text("확인",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15)))
                          ])
                    ])))));
  }
}
