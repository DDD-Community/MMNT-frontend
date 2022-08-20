import 'dart:convert';

import 'package:dash_mement/domain/story.dart';
import 'package:dash_mement/poststory/post_image.dart';
import 'package:dash_mement/component/story/image_container.dart';
import 'package:dash_mement/providers/pushstory_provider.dart';
import 'package:dash_mement/showstory/show_story_arguments.dart';
import 'package:dash_mement/style/mmnt_style.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../providers/storylist_provider.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/*
필요한 초기값
pinNumber: String도 괜찮고 
length: 최대 길이 필요
lat, lng: 위도 경도
*/

/* 
테스트 모먼트 6개
*/
class ShowStoryTest extends StatefulWidget {
  const ShowStoryTest({Key? key}) : super(key: key);
  // late String _initialVideoLink;

  static const routeName = "/show-story-test";

  @override
  State<StatefulWidget> createState() {
    return _ShowStoryTest();
  }
}

class _ShowStoryTest extends State<ShowStoryTest> {
  late PushStoryProvider _pushStory;
  List<ImageContainer> _storyWidgetList = [];
  late double _percent;
  int _loadValue = 1;
  int _currentValue = 1;
  int _maxIndex = 2;
  String _pinNum = "17"; //test for

  //youtube
  List<String> _urlList = [];
  late YoutubePlayerController _youtubePlayerController;

  void _postStory(double lat_y, double lng_x, PushStoryProvider provider) {
    _youtubePlayerController.pause();
    provider.latitude_y = lat_y;
    provider.longitude_x = lng_x;
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => PostImage(_backFromChild)));
  }

  void _backButton() {}

  //youtube 재생 기능(차일드가 꺼지면...)
  void _backFromChild() {
    _youtubePlayerController.play();
  }

  Future<String> _getAddress(double lat, double lng) async {
    String? API_KEY = dotenv.env["TMAP_KEY"];
    final url_main = Uri.parse(
        "https://apis.openapi.sk.com/tmap/geo/reversegeocoding?version=1&lat=$lat&lon=$lng&coordType=WGS84GEO&addressType=A03&newAddressExtend=Y");
    final url_building = Uri.parse(
        "https://apis.openapi.sk.com/tmap/geo/reversegeocoding?version=1&lat=$lat&lon=$lng&coordType=WGS84GEO&addressType=A04&newAddressExtend=Y");
    final response_main = await http.get(url_main,
        headers: {"Accept": "aplication/json", "appKey": API_KEY!});
    final response_building = await http.get(url_building,
        headers: {"Accept": "aplication/json", "appKey": API_KEY});

    if (response_main.statusCode == 200 &&
        response_building.statusCode == 200) {
      // 도로명 + 건물 번호
      return "${jsonDecode(response_main.body)["addressInfo"]['fullAddress']} ${jsonDecode(response_building.body)["addressInfo"]["buildingIndex"]}";
    } else {
      print("플러터: ${response_main.statusCode}");
      print("플러터: ${response_building.statusCode}");
      throw Exception();
    }
  }

  String _getUserToken() {
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjE1IiwiZW1haWwiOiJkb25nd29uMDEwM0BuYXZlci5jb20iLCJpYXQiOjE2NjAwNTI2MDcsImV4cCI6MTY2MTI2MjIwN30.LFhbrNDnveuI-TSnOTSVyqBcJQTd60Z0o6iFhd7np64";
  }

  void _addMoment(String pinNum, int index) async {
    final url = Uri.parse(
        'https://dev.mmnt.link/moment/pin/${pinNum}?page=$index&limit=1');
    final token = _getUserToken();
    final response = await http.get(url, headers: {
      "accept": 'aplication/json; charset=utf-8',
      "Authorization": "Bearer $token"
    });
    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body)["result"];

      final List<Story> list =
          json.map<Story>((js) => Story.fromJson(js)).toList();

      list.forEach((element) {
        setState(() {
          _storyWidgetList
              .add(ImageContainer.story(MediaQuery.of(context).size, element));
        });
      });
    } else {
      print(response.statusCode.toString());
      throw Exception;
    }
  }

  void _initItem() async {
    final url =
        Uri.parse('https://dev.mmnt.link/moment/pin/${_pinNum}?page=1&limit=3');
    final token = _getUserToken();
    final response = await http.get(url, headers: {
      "accept": 'aplication/json; charset=utf-8',
      "Authorization": "Bearer $token"
    });
    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body)["result"];

      final List<Story> list =
          json.map<Story>((js) => Story.fromJson(js)).toList();

      list.forEach((element) {
        setState(() {
          _storyWidgetList
              .add(ImageContainer.story(MediaQuery.of(context).size, element));

          _urlList.add(YoutubePlayer.convertUrlToId(element.link) ?? "error");
        });
      });
    } else {
      print(response.statusCode.toString());
      throw Exception;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initItem());
    _youtubePlayerController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(
                "https://www.youtube.com/watch?v=rlNEaqtRaXI") ??
            "error",
        flags: YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          loop: true,
        ));
    super.initState();
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _youtubePlayerController.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    _pushStory = Provider.of<PushStoryProvider>(context);
    _percent = _currentValue / _maxIndex;
    return Scaffold(
      backgroundColor: MmntStyle().mainBlack,
      appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Color(0xFFD9D9D9)),
            onPressed: () => _backButton(),
          ),
          backgroundColor: MmntStyle().mainBlack,
          shadowColor: Colors.transparent,
          title: FutureBuilder(
              future: _getAddress(37.6108952, 126.997679), //test for
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    "${snapshot.data.toString()} #${_currentValue}",
                    style: StoryTextStyle().appBarWhite,
                    overflow: TextOverflow.fade,
                  );
                } else if (snapshot.hasError) {
                  return Text("error");
                } else {
                  return Text("로딩중...");
                }
              })),
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
            controller: _youtubePlayerController,
            width: 300 //MediaQuery.of(context).size.width * 0.4,
            ),
        builder: (context, player) => SafeArea(
            child: Stack(alignment: Alignment.center, children: [
          Positioned(child: player),
          Positioned(
              child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: MmntStyle().mainBlack,
          )),
          CarouselSlider(
            items: _storyWidgetList,
            options: CarouselOptions(
                onPageChanged: (index, reason) {
                  if (index >= 1 && _loadValue < index + 3) {
                    int loadindex = 3 + index;
                    _loadValue = loadindex;
                    _addMoment(_pinNum, loadindex);
                  }

                  _youtubePlayerController.load(_urlList[index]);
                  setState(() {
                    _currentValue = index + 1;
                  });
                },
                height: MediaQuery.of(context).size.height *
                    0.92, // carousel height
                enableInfiniteScroll: false, // 무한 스크롤
                autoPlay: true, // 자동 넘김
                autoPlayInterval: const Duration(minutes: 1),
                viewportFraction: 0.9), // viewport
          ),
          // linear indicator
          Positioned(
              top: 0,
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: LinearProgressIndicator(
                    value: _percent,
                    backgroundColor: MmntStyle().secondBlack,
                    valueColor: new AlwaysStoppedAnimation(MmntStyle().second),
                  ))),
        ])),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () =>
              _postStory(37.6084443, 127.008789, _pushStory), //test for
          backgroundColor: MmntStyle().primary,
          child: Icon(
            Icons.add,
            color: MmntStyle().mainWhite,
          )),
    );
  }
}
