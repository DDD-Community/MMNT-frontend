import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dash_mement/component/story/image_container.dart';
import 'package:dash_mement/component/story/story_column.dart';
import 'package:dash_mement/domain/story.dart';
import 'package:dash_mement/style/mmnt_style.dart';
import 'package:dash_mement/userpage/user_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../constants/token_temp_file.dart' as Token;

class UserHistory extends StatefulWidget {
  static const routeName = "user-history-page";

  @override
  State<StatefulWidget> createState() {
    return _UserHistory();
  }
}

class _UserHistory extends State<UserHistory> {
  List<HistoryWidget> _storyWidgetList = [];
  List<int> _deleteItemIndex = [];
  int _loadValue = 1;
  int _currentValue = 1;
  String _appBarText = "로딩중..";

  String _getCurrentToken() {
    return Token.jwt_token;
  }

  void _initItem() async {
    final token = _getCurrentToken();
    final url = Uri.parse(
        'https://dev.mmnt.link/moment/my-history?page=1&limit=3&type=detail');
    final response = await http.get(url, headers: {
      "accept": "aplication/json",
      "Authorization": "Bearer $token"
    });
    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body)["result"];

      final List<Story> list =
          json.map<Story>((js) => Story.fromJsonHistory(js)).toList();

      for (int i = 0; i < list.length; i++) {
        setState(() {
          _storyWidgetList.add(HistoryWidget(HistoryWidgetArguments(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              index: i,
              checked: _deleteItemIndex.contains(i),
              story: list[i],
              selectFunction: _selectItem,
              checkoutFunction: _checkoutItem)));
        });
      }
      _getAddress(0);
    } else {
      print(response.statusCode.toString());
      throw Exception;
    }
  }

  void _getAddress(int _widgetNumber) async {
    String? API_KEY = dotenv.env["TMAP_KEY"];
    double latY = _storyWidgetList[_widgetNumber].getLatY();
    double lngX = _storyWidgetList[_widgetNumber].getLngX();
    final url_main = Uri.parse(
        "https://apis.openapi.sk.com/tmap/geo/reversegeocoding?version=1&lat=$latY&lon=$lngX&coordType=WGS84GEO&addressType=A03&newAddressExtend=Y");
    final response_main = await http.get(url_main,
        headers: {"Accept": "aplication/json", "appKey": API_KEY!});

    if (response_main.statusCode == 200) {
      setState(() {
        _appBarText =
            "${jsonDecode(response_main.body)["addressInfo"]['fullAddress']}";
      });
    } else {
      print("플러터: ${response_main.statusCode}");
      throw Exception();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initItem());
    super.initState();
  }

  void _backButton() {
    Navigator.pushNamedAndRemoveUntil(
        context, UserPage.routeName, (_) => false);
  }

  void _acceptButton() async {
    final token = _getCurrentToken();

    _deleteItemIndex.forEach((index) async {
      String momentIdx = _storyWidgetList[index].getMomentIdx();
      final url = Uri.parse('https://dev.mmnt.link/moment/$momentIdx');
      final response = await http.delete(url, headers: {
        "accept": "aplication/json",
        "Authorization": "Bearer $token"
      });
      if (response.statusCode == 200) {
        print("삭제완료");
      }
      setState(() {
        _storyWidgetList.removeAt(index);
        _deleteItemIndex.clear();
      });
    });
  }

  void _deleteButton() {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return ScreenAlert(acceptButton: _acceptButton);
        }));
  }

  void _selectItem(int index) {
    setState(() {
      _deleteItemIndex.add(index);
      print(_deleteItemIndex);
    });
  }

  void _checkoutItem(int index) {
    setState(() {
      _deleteItemIndex.remove(index);
      print(_deleteItemIndex);
    });
  }

  void _addMoment() async {
    final token = _getCurrentToken();
    final url = Uri.parse(
        'https://dev.mmnt.link/moment/my-history?page=$_loadValue&limit=1&type=detail');
    final response = await http.get(url, headers: {
      "accept": "aplication/json",
      "Authorization": "Bearer $token"
    });
    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body)["result"];

      final List<Story> list =
          json.map<Story>((js) => Story.fromJsonHistory(js)).toList();
      if (list.length >= 1) {
        setState(() {
          _storyWidgetList.add(HistoryWidget(HistoryWidgetArguments(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              index: _storyWidgetList.length,
              checked: false,
              story: list[0],
              selectFunction: _selectItem,
              checkoutFunction: _checkoutItem)));
        });
      }
    } else {
      print(response.statusCode.toString());
      throw Exception;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            title: Text(_appBarText),
            actions: [
              _deleteItemIndex.length == 0
                  ? Center(
                      child: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Text("삭제",
                              style: TextStyle(
                                  color: MmntStyle().primaryDisable,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600))))
                  : GestureDetector(
                      onTap: () => _deleteButton(),
                      child: Center(
                          child: Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Text("삭제",
                                  style: TextStyle(
                                      color: MmntStyle().primaryError,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))))
            ]),
        body: Stack(children: [
          CarouselSlider(
            items: _storyWidgetList,
            options: CarouselOptions(
                onPageChanged: (index, reason) {
                  if (index >= 1 && _loadValue < index + 3) {
                    int loadindex = 3 + index;
                    _loadValue = loadindex;
                    _addMoment();
                  }
                  _getAddress(index);
                },
                height: MediaQuery.of(context).size.height *
                    0.92, // carousel height
                enableInfiniteScroll: false, // 무한 스크롤
                viewportFraction: 0.9),
          )
        ]));
  }
}

class HistoryWidgetArguments {
  final Story story;
  final double height;
  final double width;
  final int index;
  bool checked;
  final Function selectFunction;
  final Function checkoutFunction;
  HistoryWidgetArguments(
      {required this.story,
      required this.height,
      required this.width,
      required this.index,
      required this.checked,
      required this.selectFunction,
      required this.checkoutFunction}) {}
}

class HistoryWidget extends StatefulWidget {
  final HistoryWidgetArguments _args;
  const HistoryWidget(this._args, {Key? key}) : super(key: key);

  double getLngX() {
    return this._args.story.lngX;
  }

  double getLatY() {
    return this._args.story.latY;
  }

  String getMomentIdx() {
    return this._args.story.momentIdx;
  }

  @override
  State<StatefulWidget> createState() {
    return _HistoryWidget();
  }
}

class _HistoryWidget extends State<HistoryWidget> {
  late StoryColumn _storyColumn = StoryColumn(this.widget._args.story);
  // bool _checked = false;
  Widget _check_before = Image.asset("assets/images/check_circle_before.png");
  Widget _check_after = Image.asset("assets/images/check_circle_after.png");

  void _click_check() {
    if (!this.widget._args.checked) {
      this.widget._args.selectFunction(this.widget._args.index);
    } else {
      this.widget._args.checkoutFunction(this.widget._args.index);
    }
    setState(() {
      this.widget._args.checked = !this.widget._args.checked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          margin: EdgeInsets.fromLTRB(10, 24, 10, 24),
          height: this.widget._args.height,
          width: this.widget._args.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                  image: NetworkImage(this.widget._args.story.img),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4), BlendMode.darken))),
          child: _storyColumn),
      Positioned(
          top: 30,
          right: 18,
          child: GestureDetector(
              onTap: () => _click_check(),
              child: Container(
                child: this.widget._args.checked ? _check_after : _check_before,
              ))),
    ]);
  }
}

class ScreenAlert extends StatelessWidget {
  Function acceptButton;
  ScreenAlert({required this.acceptButton}) {}
  void _acceptButtonClick(BuildContext context) {
    acceptButton();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.7),
        body: Center(
            child: Container(
                width: 272,
                height: 174,
                decoration: BoxDecoration(
                  color: MmntStyle().mainBlack,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(children: [
                      Text("선택한 모먼트를 삭제하시겠습니까?",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 24),
                          child: Text("삭제한 모먼트는 복구되지 않습니다",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF9E9FA9)))),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: MmntStyle().primaryDisable,
                                    fixedSize: Size(102, 48)),
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  "취소",
                                  style: TextStyle(
                                      color: Color(0xFFD9D9D9),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                )),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: MmntStyle().primaryError,
                                    fixedSize: Size(102, 48)),
                                onPressed: () => _acceptButtonClick(context),
                                child: Text("확인",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15)))
                          ])
                    ])))));
  }
}
