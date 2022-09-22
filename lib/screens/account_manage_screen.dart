import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dash_mement/constants/style_constants.dart';
import 'package:dash_mement/screens/password_change_screen.dart';
import 'package:dash_mement/screens/setting_screen.dart';
import 'package:dash_mement/style/mmnt_style.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AccountManageScreen extends StatelessWidget {
  static const routeName = '/account-manage-screen';

  const AccountManageScreen({super.key});
  void _backButton(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: MmntStyle().mainBlack,
          shadowColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => _backButton(context),
          ),
          centerTitle: true,
          title: Text(
            "내 계정 관리",
            style: StoryTextStyle().appBarWhite,
          ),
        ),
        body: Column(
          children: [
            UserInfo(),
            Divider(
              thickness: 20,
              color: Colors.black,
            ),
            const SettingMenuBar(icon: Icons.password_outlined ,title: '비밀번호 변경', routeName: PasswordChangeScreen.routeName),
            // MomentInfo()
          ],
        ));
  }
}

class UserInfo extends StatelessWidget {
  Widget _userImage(String url) {
    return Container(
      color: MmntStyle().secondBlack,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(400),
          child: SizedBox(
            height: 105,
            width: 105,
            child: CachedNetworkImage(
              imageUrl: url,
              placeholder: (context, url) => const SizedBox(
                  height: 105, width: 105, child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          )),
    );
    // child: Image.network(url, width: 105, height: 105, fit: BoxFit.cover));
  }

  Widget _currentUser(String user) {
    return ListTile(
      tileColor: MmntStyle().secondBlack,
      leading: Text(
        '닉네임',
        style: kWhiteBold15,
      ),
      trailing: Text(user, style: kWhiteBold15),
    );
  }

  Future<Map<String, dynamic>> _getCurrentUser() async {
    final url = Uri.parse("https://dev.mmnt.link/user/profile-info");
    final token = await _getCurrentUserToken();
    final response = await http.get(url, headers: {
      "accept": "aplication/json",
      "Authorization": "Bearer $token"
    });

    Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));

    return json["result"];
  }

  Future<String> _getCurrentUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    return token;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: _getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("ERROR"));
          } else if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            final String imgUrl = snapshot.data!["profileUrl"];
            final String user = snapshot.data!["nickname"];
            final String pinCount = snapshot.data!["finCount"];
            final String momentCount = snapshot.data!["momentCount"];
            return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _userImage(imgUrl),
                  _currentUser(user),
                ]);
          }
        });
  }
}
