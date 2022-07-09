import 'dart:io';

import 'package:dash_mement/component/story/image_container.dart';
import 'package:dash_mement/providers/pushstory_provider.dart';
import 'package:dash_mement/style/mmnt_style.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PostText extends StatefulWidget {
  late File _imageFile;
  PostText(this._imageFile) {}

  @override
  State<StatefulWidget> createState() {
    return _PostText();
  }
}

class _PostText extends State<PostText> with SingleTickerProviderStateMixin {
  late ImageContainer _imageContainer;
  late PushStoryProvider _pushStory;
  late PanelController _panelController;
  late TextEditingController _linkEditController;
  late YoutubePlayerController _playerController;
  late AnimationController _animationController;
  late Animation _animation;
  String _youtubeGoButtonString = "유튜브에서 링크 가져오기";
  String _inputSongInfoButton = "음악 정보 입력하기";
  bool _youtubeCheck = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _imageContainer = ImageContainer.textInput(
          MediaQuery.of(context).size, this.widget._imageFile);
    });
    _panelController = PanelController();
    _linkEditController = TextEditingController();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() {
        setState(() {});
      });

    _animation =
        ColorTween(begin: MmntStyle().primaryDisable, end: MmntStyle().primary)
            .animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _linkEditController.dispose();
    super.dispose();
  }

  void _backButton(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _submit(BuildContext context, PushStoryProvider pushStory) {
    print("yes");
    _pushStory.path = this.widget._imageFile; // 파일 설정

    print(_pushStory.dateTime);
    print(_pushStory.path.toString());
    print(_pushStory.location);
    print(_pushStory.title);
    print(_pushStory.context);
    FocusScope.of(context).unfocus();
    _panelController.open();
  }

  void _pannelButtonClick() {
    if (_youtubeCheck) {
    } else {
      _youtubeOpen();
    }
  }

  void _youtubeOpen() async {
    await LaunchApp.openApp(
        androidPackageName: "com.google.android.youtube",
        iosUrlScheme: "http://www.youtube.com/");
  }

  void _rightUrl(String text) async {
    String? url = await YoutubePlayer.convertUrlToId(text);
    if (url != null) {
      setState(() {
        _youtubeCheck = true;
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _pushStory = Provider.of<PushStoryProvider>(context);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: MmntStyle().mainBlack,
          shadowColor: Colors.transparent,
          title: Text("텍스트 추가하기", style: StoryTextStyle().appBarWhite),
          leading: IconButton(
              onPressed: () => _backButton(context),
              icon: Icon(Icons.arrow_back_ios)),
          actions: [
            GestureDetector(
              onTap: () => _submit(context, _pushStory),
              child: Center(
                  child: Padding(
                      padding: EdgeInsets.only(right: 8), child: Text("다음"))),
            )
          ],
        ),
        backgroundColor: MmntStyle().mainBlack,
        body: SlidingUpPanel(
          controller: _panelController,
          backdropEnabled: true,
          minHeight: 0,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          panel: Container(
              decoration: BoxDecoration(
                  color: MmntStyle().mainBlack,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.fromLTRB(20, 40, 0, 12),
                        child: Text("음악추가하기",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.41,
                                height: 1.2,
                                color: Colors.white))),
                    Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text("유튜브에서 원하는 음악의 링크를 복사 후 붙여넣으면",
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.41,
                                height: 1.2,
                                color: Color(0xCCFFFFFF)))),
                    Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: RichText(
                            text: TextSpan(
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.41,
                                    height: 1.2,
                                    color: Color(0xCCFFFFFF)),
                                children: [
                              TextSpan(
                                  text: "00:00 ~ 1:00",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  )),
                              TextSpan(text: " 구간이 스토리에 삽입됩니다.")
                            ]))),
                    Container(
                        width: MediaQuery.of(context).size.width - 20,
                        padding: EdgeInsets.only(left: 20, top: 24),
                        child: TextFormField(
                          cursorColor: Colors.white,
                          onChanged: (text) => _rightUrl(text),
                          decoration: InputDecoration(
                              fillColor: Color(0xFF262626),
                              hintText: "이곳에 링크 주소를 입력해주세요",
                              filled: true,
                              suffixIcon: Icon(
                                Icons.check_circle,
                                color: _animation.value,
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(4))),
                        )),
                    Padding(
                        padding: EdgeInsets.only(left: 20, top: 24, right: 20),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size(
                                    MediaQuery.of(context).size.width - 20,
                                    MediaQuery.of(context).size.height * 0.08),
                                primary: MmntStyle().primary),
                            onPressed: () => _pannelButtonClick(),
                            child: Text(
                                !_youtubeCheck
                                    ? _youtubeGoButtonString
                                    : _inputSongInfoButton,
                                style: StoryTextStyle().buttonWhite)))
                  ])),
          body: ImageContainer.textInput(
              MediaQuery.of(context).size, this.widget._imageFile),
        ));
  }
}
