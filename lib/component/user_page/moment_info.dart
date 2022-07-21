import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MomentInfo extends StatelessWidget {
  static const double _padding = 20;

  Widget _title() {
    return Padding(
        padding: EdgeInsets.fromLTRB(20, 14, 10, 20),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            "나의 모먼트 피드",
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Pretendard',
                fontSize: 16,
                letterSpacing: -0.03,
                fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 14,
            ),
            onPressed: () => print("hi"),
          )
        ]));
  }

  Widget _moment(Size size, int index, int length, Map<String, dynamic> json) {
    length -= 1;
    EdgeInsets positionMargin;
    if (index == 0) {
      positionMargin = EdgeInsets.only(left: 20);
    } else if (index == length) {
      positionMargin = EdgeInsets.only(left: 12, right: 20);
    } else {
      positionMargin = EdgeInsets.only(left: 12);
    }

    return Container(
        margin: positionMargin,
        width: size.width * 0.42,
        height: size.height * 0.4,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            image: DecorationImage(
                image: NetworkImage(json["image_url"]),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4), BlendMode.darken))),
        child: Column(children: [
          Padding(
              padding: EdgeInsets.only(top: 14, bottom: 2),
              child: Text("2022년 5월 6알",
                  style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.4))),
          Text("오후 6시 3분",
              style: TextStyle(
                  fontFamily: "Pretendard",
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.4)),
          Expanded(
              child: Center(
                  child: Text(json["title"],
                      style: TextStyle(
                          fontFamily: "Pretendard",
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.41))))
        ]));
  }

  Future<String> _getCurrentUserToken() async {
    Future.delayed(Duration(milliseconds: 100));
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjE1IiwiZW1haWwiOiJkb25nd29uMDEwM0BuYXZlci5jb20iLCJpYXQiOjE2NTgyMDU1OTUsImV4cCI6MTY1ODIwOTE5NX0.AT8v6-8WqNr0lHqqdDiUSo2fnhl9UKUak0fhHFadT-Q";
  }

  Future<List<Map<String, dynamic>>> _getMoment() async {
    final token = await _getCurrentUserToken();
    final String totalPage = await _getTotalPage(token);
    final url = Uri.parse(
        'https://dev.mmnt.link/moment/my-history?page=1&limit=$totalPage&type=main');
    final response = await http.get(url, headers: {
      "accept": "aplication/json",
      "Authorization": "Bearer $token"
    });
    Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));

    List<Map<String, dynamic>> result = [];
    List list = json["result"];
    list.forEach((element) {
      result.add(jsonDecode(element));
    });

    return result;
  }

  Future<String> _getTotalPage(String token) async {
    final url = Uri.parse("https://dev.mmnt.link/user/profile-info");
    final response = await http.get(url, headers: {
      "accept": "aplication/json",
      "Authorization": "Bearer $token"
    });
    print(response.body);
    Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
    return json["result"]["finCount"];
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _title(),
      Container(
          height: MediaQuery.of(context).size.height * 0.4,
          child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getMoment(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("${snapshot.error}"));
                } else if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  List<Map<String, dynamic>> list = snapshot.data!;
                  return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (BuildContext context, int index) => _moment(
                          MediaQuery.of(context).size,
                          index,
                          list.length,
                          list[index]));
                }
              }))
    ]);
  }
}
