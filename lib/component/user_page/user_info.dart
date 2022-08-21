import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserInfo extends StatelessWidget {
  Widget _userImage(String url) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(400),
        child: Image.network(url, width: 105, height: 105, fit: BoxFit.cover));
  }

  Widget _currentUser(String user) {
    return Text(user);
  }

  Widget _columnComponent(String value, String text) {
    return Container(
        width: 60,
        height: 50,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$value",
                  style: TextStyle(
                      color: Color(0xFFD9D9D9),
                      fontFamily: 'Pretendard',
                      fontSize: 24,
                      letterSpacing: -0.41,
                      fontWeight: FontWeight.w600)),
              Text("나의 $text",
                  style: TextStyle(
                      color: Color(0xFF9E9FA9),
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      letterSpacing: -0.41,
                      fontWeight: FontWeight.w400))
            ]));
  }

  Widget _momentWidget(String pinCount, String momentCount) {
    Widget pin = _columnComponent(pinCount, "핀");
    Widget moment = _columnComponent(momentCount, "모먼트");

    return Container(
        width: 172,
        height: 60,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          pin,
          Container(
              height: 44, child: VerticalDivider(color: Color(0x4D7474744D))),
          moment
        ]));
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
    Future.delayed(const Duration(milliseconds: 100));
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjMxIiwiZW1haWwiOiJkb25nd29uMDAwMTAzQGdtYWlsLmNvbSIsImlhdCI6MTY2MTA5NDI5MSwiZXhwIjoxNjYyMzAzODkxfQ.UdoMioa1Sh5pRB-5WPzclnwsXpP4KkhjkS37BnDGDoc";
  }

  @override
  Widget build(BuildContext context) {
    _getCurrentUser();
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
            return Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                  Padding(
                      padding: EdgeInsets.all(16), child: _userImage(imgUrl)),
                  _currentUser(user),
                  Padding(
                      padding: EdgeInsets.all(22),
                      child: _momentWidget(pinCount, momentCount))
                ]));
          }
        });
  }
}
