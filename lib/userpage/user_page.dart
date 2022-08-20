import 'package:dash_mement/component/user_page/moment_info.dart';
import 'package:dash_mement/component/user_page/user_info.dart';
import 'package:dash_mement/screens/map_screen.dart';
import 'package:dash_mement/style/mmnt_style.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  static const routeName = '/user-page-screen';
  void _backButton(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
        context, MapScreen.routeName, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MmntStyle().mainBlack,
        appBar: AppBar(
          backgroundColor: MmntStyle().mainBlack,
          shadowColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => _backButton(context),
          ),
          centerTitle: true,
          title: Text(
            "마이페이지",
            style: StoryTextStyle().appBarWhite,
          ),
          actions: [
            IconButton(
                onPressed: () => print("option"), icon: Icon(Icons.settings))
          ],
        ),
        body: Column(
          children: [
            UserInfo(),
            Divider(
              thickness: 20,
              color: Colors.black,
            ),
            MomentInfo()
          ],
        ));
  }
}
