import 'package:dash_mement/constants/style_constants.dart';
import 'package:dash_mement/screens/account_manage_screen.dart';
import 'package:dash_mement/screens/login_screen.dart';
import 'package:dash_mement/screens/web_view_screen.dart';
import 'package:dash_mement/style/mmnt_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  static const routeName = '/setting-screen';
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앱 설정'),
        backgroundColor: MmntStyle().secondBlack,
        elevation: 0,
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          const SettingMenuBar(
              icon: Icons.person_pin,
              title: '내 계정 관리',
              routeName: AccountManageScreen.routeName),
          const SizedBox(height: 20),
          const SettingMenuBar(
              icon: Icons.security, title: '개인정보 처리방침', routeName: WebViewScreen.routeName, url: 'https://dash-ddd.notion.site/c9c3409bcc0a41c7bd4fb1ec805e7347',),
          const SettingMenuBar(icon: Icons.info, title: '이용약관', routeName: WebViewScreen.routeName, url: 'https://dash-ddd.notion.site/b907307f0fa446e899793fe997436772',),
          const SettingMenuBar(
              icon: Icons.chat_rounded, title: '서비스 소개', routeName: WebViewScreen.routeName, url: 'https://dash-ddd.notion.site/f0f02067116f43f58c4c5ff8e300175f',),
          const SettingMenuBar(
              icon: Icons.record_voice_over_sharp,
              title: 'VOC 피드백',
              routeName: '/'),
          TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Center(child: Text('로그아웃 하시겠습니까?')),
                        content: Row(
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: MmntStyle().primaryDisable,
                                    fixedSize: Size(102.w, 48.h)),
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("취소", style: kWhiteBold15)),
                            SizedBox(
                              width: 12.w,
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: MmntStyle().primary,
                                    fixedSize: Size(102.w, 48.h)),
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.remove('token');
                                  Navigator.popUntil(
                                      context,
                                      ModalRoute.withName(
                                          LoginScreen.routeName));
                                },
                                child: Text("확인", style: kWhiteBold15))
                          ],
                        ),
                      );
                    });
              },
              child: Text(
                '로그아웃',
                style: kGrayBold18.copyWith(
                    color: MmntStyle().secondError, height: 2),
              )),
          SizedBox(
            height: 12.h,
          ),
          Center(
              child: Text(
            '현재버전 0.0.0',
            style: kGray12,
          )),
        ],
      ),
    );
  }
}

class SettingMenuBar extends StatelessWidget {
  final String title;
  final String routeName;
  final IconData? icon;
  final String? url;
  
  const SettingMenuBar({
    Key? key,
    required this.title,
    this.icon,
    this.url,
    required this.routeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: MmntStyle().secondDisable),
      tileColor: MmntStyle().secondBlack,
      title: Text(title, style: kGray14),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: MmntStyle().secondDisable,
        size: 15,
      ),
      onTap: () {
        Navigator.pushNamed(context, routeName, arguments: WebViewScreenArguments(url, title));
      },
    );
  }
}
