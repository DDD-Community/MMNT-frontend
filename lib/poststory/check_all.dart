import 'dart:io';

import 'package:dash_mement/component/story/image_container.dart';
import 'package:dash_mement/domain/story.dart';
import 'package:dash_mement/providers/pushstory_provider.dart';
import 'package:dash_mement/style/mmnt_style.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class CheckAll extends StatefulWidget {
  String _youtubeId;
  CheckAll(this._youtubeId) {}
  @override
  State<StatefulWidget> createState() {
    return _CheckAll();
  }
}

class _CheckAll extends State<CheckAll> {
  late PushStoryProvider _pushStoryProvider;
  late YoutubePlayerController _youtubePlayerController;

  @override
  void initState() {
    _youtubePlayerController = YoutubePlayerController(
        initialVideoId: this.widget._youtubeId,
        flags: YoutubePlayerFlags(autoPlay: true, loop: true, endAt: 60));
    super.initState();
  }

  @override
  void deactivate() {
    _youtubePlayerController.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    super.dispose();
  }

  String _geCurrenttUser() {
    return "Test_User";
  }

  void _submit() {
    print(_pushStoryProvider.latitude_y);
    print(_pushStoryProvider.longitude_x);
    _uploadUrl(_pushStoryProvider.path);
  }

  Future<String> _uploadUrl(File file) async {
    var dio = new Dio();
    var formData = FormData.fromMap(
        {'image': await MultipartFile.fromFile(_pushStoryProvider.path.path)});
    try {
      dio.options.contentType = 'multipart/form-data';

      var response = await dio.patch(
        "https://dev.mmnt.link/upload",
        data: formData,
      );
      print('성공적으로 업로드했습니다');
      print("플러터: ${response.data}");
    } catch (e) {
      print(e);
    }

    return "hi";
  }

  @override
  Widget build(BuildContext context) {
    _pushStoryProvider = Provider.of<PushStoryProvider>(context);
    return Scaffold(
        backgroundColor: MmntStyle().mainBlack,
        appBar: AppBar(
          backgroundColor: MmntStyle().mainBlack,
          shadowColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text("나의 모먼트", style: StoryTextStyle().appBarWhite),
          actions: [
            GestureDetector(
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text("완료",
                            style: TextStyle(
                                fontFamily: "Pretendard",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.22,
                                color: Color(0xFF5894FC))))),
                onTap: () => _submit())
          ],
        ),
        body: YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: _youtubePlayerController,
              width: 30,
            ),
            builder: (context, player) => Stack(children: [
                  player,
                  Container(
                    width: 40,
                    height: 40,
                    color: MmntStyle().mainBlack,
                  ),
                  ImageContainer.check(
                      MediaQuery.of(context).size,
                      _pushStoryProvider.path,
                      Story(
                          _pushStoryProvider.title,
                          _geCurrenttUser(), // user
                          _pushStoryProvider.dateTime,
                          _pushStoryProvider.link,
                          "", // img
                          _pushStoryProvider.context,
                          _pushStoryProvider.track,
                          _pushStoryProvider.artist,
                          _pushStoryProvider.latitude_y,
                          _pushStoryProvider.longitude_x))
                ])));
  }
}
