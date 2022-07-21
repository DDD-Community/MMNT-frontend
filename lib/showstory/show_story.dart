import 'dart:convert';

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
showStory는 유튜브 처음 링크 필요
나머지 데이터는 provider로 생성

Issue: story text 크기 제한
Issue: location에 대한 재정의 필요, dependency: story, pushstory_provider 이하 위젯 
*/
class ShowStory extends StatefulWidget {
  final ShowStoryArguments _args;
  const ShowStory(this._args, {Key? key}) : super(key: key);
  // late String _initialVideoLink;

  static const routeName = "/show-story-screen";

  @override
  State<StatefulWidget> createState() {
    return _ShowStory();
  }
}

class _ShowStory extends State<ShowStory> {
  late StoryListProvider _storyList;
  late PushStoryProvider _pushStory;
  List<ImageContainer> _storyWidgetList = [];
  late double _percent;
  int _currentValue = 1;

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

  @override
  void initState() {
    _youtubePlayerController = YoutubePlayerController(
        initialVideoId:
            YoutubePlayer.convertUrlToId(this.widget._args.firstUrl) ?? "error",
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
    _storyList = Provider.of<StoryListProvider>(context);
    _pushStory = Provider.of<PushStoryProvider>(context);
    //storywidget 생성 / urlList 생성
    _storyWidgetList = [];
    for (int i = 0; i < _storyList.getLength(); i++) {
      _storyWidgetList.add(ImageContainer.story(
          MediaQuery.of(context).size, _storyList.getStoryAt(i)));
      _urlList.add(
          YoutubePlayer.convertUrlToId(_storyList.getStoryAt(i).link) ?? "");
    }

    _percent = _currentValue / _storyList.getLength();

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
              future:
                  _getAddress(this.widget._args.lat_y, this.widget._args.lng_x),
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
          width: MediaQuery.of(context).size.width * 0.4,
        ),
        builder: (context, player) => SafeArea(
            child: Stack(alignment: Alignment.center, children: [
          Positioned(child: player),
          Positioned(
              child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.width * 0.4,
            color: MmntStyle().mainBlack,
          )),
          CarouselSlider(
            items: _storyWidgetList,
            options: CarouselOptions(
                onPageChanged: (index, reason) {
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
                  )))
        ])),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _postStory(
              this.widget._args.lat_y, this.widget._args.lng_x, _pushStory),
          backgroundColor: MmntStyle().primary,
          child: Icon(
            Icons.add,
            color: MmntStyle().mainWhite,
          )),
    );
  }
}
