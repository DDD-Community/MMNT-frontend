import 'package:dash_mement/domain/story.dart';
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

  Widget _moment(Size size, int index, int length, StorySub story) {
    length -= 1;
    String _date =
        "${story.time.year}년 ${story.time.month}월 ${story.time.day}일";
    String _time = story.time.hour > 12
        ? "오후 ${story.time.hour - 12}시 ${story.time.minute}분"
        : "오전 ${story.time.hour}시 ${story.time.minute}분";
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
                image: NetworkImage(story.image_url),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4), BlendMode.darken))),
        child: Column(children: [
          Padding(
              padding: EdgeInsets.only(top: 14, bottom: 2),
              child: Text(_date,
                  style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.4))),
          Text(_time,
              style: TextStyle(
                  fontFamily: "Pretendard",
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.4)),
          Expanded(
              child: Center(
                  child: Text(story.title,
                      style: TextStyle(
                          fontFamily: "Pretendard",
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.41))))
        ]));
  }

  Future<String> _getCurrentUserToken() async {
    Future.delayed(Duration(milliseconds: 100));
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjE1IiwiZW1haWwiOiJkb25nd29uMDEwM0BuYXZlci5jb20iLCJpYXQiOjE2NjA1MzczMjUsImV4cCI6MTY2MTc0NjkyNX0.Sh63lxc7Bu1dizWa36ZdgbCDnxxrXYZ-74SmfEI5Buo";
  }

  Future<List<StorySub>> _getMoment() async {
    final token = await _getCurrentUserToken();
    final String totalPage = "5";
    final url = Uri.parse(
        'https://dev.mmnt.link/moment/my-history?page=1&limit=$totalPage&type=main');
    final response = await http.get(url, headers: {
      "accept": "aplication/json",
      "Authorization": "Bearer $token"
    });
    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body)["result"];

      final List<StorySub> storylist =
          json.map<StorySub>((js) => StorySub.fromJson(js)).toList();
      print("hi");
      return storylist;
    } else {
      throw Exception();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _title(),
      Container(
          height: MediaQuery.of(context).size.height * 0.4,
          child: FutureBuilder<List<StorySub>>(
              future: _getMoment(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("${snapshot.error}"));
                } else if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) => _moment(
                          MediaQuery.of(context).size,
                          index,
                          snapshot.data!.length,
                          snapshot.data![index]));
                }
              }))
    ]);
  }
}

class StorySub {
  late String title;
  late String image_url;
  late DateTime time;
  StorySub(this.title, this.image_url, this.time) {}

  factory StorySub.fromJson(Map<String, dynamic> parsedJson) {
    return StorySub(parsedJson["title"], parsedJson["image_url"],
        DateTime.parse(parsedJson["updated_at"]));
  }
}
