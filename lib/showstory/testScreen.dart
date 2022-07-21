import 'package:dash_mement/domain/story.dart';
import 'package:dash_mement/providers/storylist_provider.dart';
import 'package:dash_mement/showstory/show_story.dart';
import 'package:dash_mement/showstory/show_story_arguments.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class TestScreen extends StatelessWidget {
  void _push(BuildContext context, StoryListProvider storyListProvider) async {
    List<Story> storyList = await _getPin();
    if (storyList != null) {
      storyList.forEach((element) => storyListProvider.add(element));
      Navigator.pushNamed(context, ShowStory.routeName,
          arguments:
              ShowStoryArguments(storyList[0].link, 37.5135790, 127.104765));
    } else {}
  }

  Future<List<Story>> _getPin() async {
    final token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjE1IiwiZW1haWwiOiJkb25nd29uMDEwM0BuYXZlci5jb20iLCJpYXQiOjE2NTgzMzIxMTIsImV4cCI6MTY1OTU0MTcxMn0.A7OmjzzmFmuikA6wCJYsRYHvj_ZDaMFvxMSWXDki2TA";

    final url = Uri.parse("https://dev.mmnt.link/moment/pin/2?page=1&limit=4");
    final response = await http.get(url, headers: {
      "accept": "application/json; charset=utf-8",
      "Authorization": "Bearer $token"
    });

    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body)["result"];

      final List<Story> list =
          json.map<Story>((js) => Story.fromJson(js)).toList();

      return list;
    } else {
      print(response.statusCode.toString());
      throw Exception;
    }
  }

  @override
  Widget build(BuildContext context) {
    StoryListProvider _storyList = Provider.of<StoryListProvider>(context);
    return Scaffold(
        body: Center(
            child: ElevatedButton(
      child: Text("클릭"),
      onPressed: () => _push(context, _storyList),
    )));
  }
}
