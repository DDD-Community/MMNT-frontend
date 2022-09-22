import 'dart:convert';
import 'dart:io';
import 'package:dash_mement/apis/api_manager.dart';
import 'package:dash_mement/component/story/image_container.dart';
import 'package:dash_mement/component/toast/mmnterror_toast.dart';
import 'package:dash_mement/domain/story.dart';
import 'package:dash_mement/providers/app_provider.dart';
import 'package:dash_mement/providers/pushstory_provider.dart';
import 'package:dash_mement/screens/map_screen.dart';
import 'package:dash_mement/style/mmnt_style.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../showstory/show_story.dart';

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
  late AppProvider _appProvider = Provider.of<AppProvider>(context, listen: false);
  late FToast _ftoast;

  @override
  void initState() {
    _youtubePlayerController = YoutubePlayerController(
        initialVideoId: this.widget._youtubeId,
        flags: YoutubePlayerFlags(autoPlay: true, loop: true, endAt: 60));
    _ftoast = FToast();
    _ftoast.init(context);
    super.initState();
  }

  _showToast(String message, double width) {
    Widget toast = MnmtErrorToast(message: message, width: width);
    _ftoast.showToast(
        child: toast,
        toastDuration: Duration(milliseconds: 3000),
        positionedToastBuilder: (context, child) =>
            Positioned(bottom: 80, left: 0.0, right: 0.0, child: child));
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

  String _getCurrenttUser() {
    return "Test_User";
  }

  Future<String> _getCurrentUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    return token;
  }

  void _submit() async {
    final state = Provider.of<AppProvider>(context, listen: false);
    if(state.appStatus == AppStatus.loading) {
      return;
    }
    Provider.of<AppProvider>(context, listen: false).updateAppState(AppStatus.loading);
    String imageUrl = await _uploadUrl(_pushStoryProvider.path!);
    if (imageUrl == "ERROR") {
      _showToast("사진 업로드 실패!", 200); // 에러 처리 해줘야함
    } else {
      final postUrl = Uri.parse("https://dev.mmnt.link/moment");
      final token = await _getCurrentUserToken();
      try {
        var data = <String, dynamic>{
          "pinX": _pushStoryProvider.longitude_x,
          "pinY": _pushStoryProvider.latitude_y,
          "title": _pushStoryProvider.title,
          "description": _pushStoryProvider.context,
          "imageUrl": imageUrl,
          "youtubeUrl": _pushStoryProvider.link,
          "music": _pushStoryProvider.track,
          "artist": _pushStoryProvider.artist
        };
        var body = json.encode(data);
        await ApiManager().postPin(_appProvider.userEmail, data);
        http.Response response = await http.post(postUrl,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'bearer $token'
            },
            body: body);
        print("flutter post test: ${response.body}");
        // _pushStoryProvider.clear();
        if(_pushStoryProvider.postMode == PostMode.moment) {
          // TODO 모먼트 추가후 추가된것 바로 확인할 수 있게 수정
          // Navigator.popUntil(context, ModalRoute.withName(ShowStory.routeName));
          // Navigator.pushNamedAndRemoveUntil(context, ShowStory.routeName, (route) => false);

          Navigator.pushNamedAndRemoveUntil(context, MapScreen.routeName, (route) => false);
        } else {
          // Navigator.popUntil(context, ModalRoute.withName(MapScreen.routeName));
          Navigator.pushNamedAndRemoveUntil(context, MapScreen.routeName, (route) => false);
        }
      } catch (e) {
        print("flutter_error: ${e.toString()}");
        _showToast("업로드 실패", 180);
      }
    }
  }

  Future<String> _uploadUrl(File file) async {
    final url = Uri.parse("https://dev.mmnt.link/upload");

    var dio = new Dio();
    var formData =
        FormData.fromMap({'file': await MultipartFile.fromFile(file.path)});
    try {
      final response =
          await dio.post("https://dev.mmnt.link/upload", data: formData);
      String imageUrl = response.data["result"]["imageUrl"];
      print("플러터 테스트: ${imageUrl}");
      return imageUrl;
    } catch (e) {
      return "ERROR";
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>();
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
        body: Stack(

          children: [
            YoutubePlayerBuilder(
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
                      _pushStoryProvider.title!,
                      _getCurrenttUser(), // user
                      _pushStoryProvider.dateTime!,
                      _pushStoryProvider.link!,
                      "", // img
                      _pushStoryProvider.context,
                      _pushStoryProvider.track!,
                      _pushStoryProvider.artist!,),)
                ])),
            state.appStatus == AppStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : Container(),
          ],
        ));
  }
}
