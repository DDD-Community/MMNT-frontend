import 'dart:io';

import 'package:dash_mement/component/story/image_container.dart';
import 'package:dash_mement/component/toast/mmnt_toast.dart';
import 'package:dash_mement/component/toast/mmnterror_toast.dart';
import 'package:dash_mement/poststory/check_all.dart';
import 'package:dash_mement/providers/pushstory_provider.dart';
import 'package:dash_mement/style/mmnt_style.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart'
    as LocalProgressBar;

class PostText extends StatefulWidget {
  late File _imageFile;
  PostText(this._imageFile) {}

  @override
  State<StatefulWidget> createState() {
    return _PostText();
  }
}

class _PostText extends State<PostText> with TickerProviderStateMixin {
  late ImageContainer _imageContainer;
  late PushStoryProvider _pushStory;
  late PanelController _panelController;
  late TextEditingController _linkEditController;
  late TextEditingController _trackNameController;
  late TextEditingController _artistController;
  late YoutubePlayerController _playerController;
  late AnimationController _animationController;
  late Animation _animation;
  late AnimationController _iconAnimationController;
  late FToast _ftoast;

  String _youtubeGoButtonString = "유튜브에서 링크 가져오기";
  String _inputSongInfoButton = "음악 정보 입력하기";
  bool _youtubeCheck = false;
  late String _youtubeId;
  bool _youtubePlay = false;
  bool _inputInfo = false;

  late double _testWidth;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _imageContainer = ImageContainer.textInput(
          MediaQuery.of(context).size, this.widget._imageFile);
    });
    _panelController = PanelController();
    _linkEditController = TextEditingController();
    _trackNameController = TextEditingController();
    _artistController = TextEditingController();
    _playerController = YoutubePlayerController(
        initialVideoId:
            YoutubePlayer.convertUrlToId("wwww.youtube.com/") ?? "");
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() {
        setState(() {});
      });

    _animation =
        ColorTween(begin: MmntStyle().primaryDisable, end: MmntStyle().primary)
            .animate(_animationController);

    _iconAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    _animationController.dispose();
    _linkEditController.dispose();
    _playerController.dispose();
    _artistController.dispose();
    _trackNameController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _playerController.pause();
    super.deactivate();
  }

  void _backButton(BuildContext context) {
    _pushStory.title = "";
    _pushStory.context = "";

    Navigator.of(context).pop();
  }

  void _submit(BuildContext context, PushStoryProvider pushStory) {
    if ((_pushStory.title == "" || _pushStory.context == "")) {
      _ftoast = FToast();
      _ftoast.init(context);
      _showErrorToast("제목과 본문 모두 작성해주세요", 240);
      return;
    } else {
      _pushStory.path = this.widget._imageFile; // 파일 설정

      print(_pushStory.dateTime);
      print(_pushStory.path.toString());
      print(_pushStory.title);
      print(_pushStory.context);
      FocusScope.of(context).unfocus(); // 키보드 내리기
      _panelController.open();
    }
  }

  void _showErrorToast(String text, double width) {
    Widget toast = MnmtErrorToast(message: text, width: width);
    final viewInsets = EdgeInsets.fromWindowPadding(
        WidgetsBinding.instance.window.viewInsets,
        WidgetsBinding.instance.window.devicePixelRatio);
    _ftoast.showToast(
        child: toast,
        gravity: ToastGravity.TOP,
        toastDuration: Duration(milliseconds: 1500),
        positionedToastBuilder: (context, child) => Positioned(
            bottom: viewInsets.bottom + 12,
            left: 0.0,
            right: 0.0,
            child: child));
  }

  void _pannelButtonClick() {
    // 음악 정보 입력하기
    if (_youtubeCheck) {
      setState(() {
        _inputInfo = true;
      });
    }
    // 유튜브 링크 열기
    else {
      _youtubeOpen();
    }
  }

  void _youtubeOpen() async {
    await LaunchApp.openApp(
        androidPackageName: "com.google.android.youtube",
        iosUrlScheme: "http://www.youtube.com/");
  }

  void _rightUrl(String text) async {
    String? id = await YoutubePlayer.convertUrlToId(text);
    if (id != null) {
      FocusScope.of(context).unfocus();
      setState(() {
        _pushStory.link = text;
        _youtubeId = id;
        _playerController = YoutubePlayerController(
            initialVideoId: _youtubeId,
            flags: YoutubePlayerFlags(endAt: 60, autoPlay: true, loop: true));
        _youtubeCheck = true;
        _animationController.forward();
      });
    } else {
      setState(() {
        _youtubeCheck = false;
        _animationController.reverse();
      });
    }
  }

  void _postAll() {
    if ((_trackNameController.text == null && _artistController.text == null) ||
        (_trackNameController.text == "" && _artistController.text == "")) {
      _ftoast = FToast();
      _ftoast.init(context);
      _showErrorToast("제목과 아티스트명을 모두 작성해주세요", 290);
    } else {
      _pushStory.track = _trackNameController.text;
      _pushStory.artist = _artistController.text;
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => CheckAll(_youtubeId)));
    }
  }

  Stream<DurationState> _getDuration() {
    Stream<DurationState> stream =
        Stream.periodic(Duration(microseconds: 1), (_) {
      Duration progress = _playerController.value.position;
      Duration buffered = _playerController.metadata.duration *
          _playerController.value.buffered;
      return DurationState(progress: progress, buffered: buffered);
    });
    return stream;
  }

  @override
  Widget build(BuildContext context) {
    _pushStory = Provider.of<PushStoryProvider>(context);

    double _widgetWidth = MediaQuery.of(context).size.width - 20;
    double _widgetHeight = MediaQuery.of(context).size.height * 0.08;



    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
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
            maxHeight: _inputInfo ? 420 : 380,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            panel: Container(
                decoration: BoxDecoration(
                    color: MmntStyle().mainBlack,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12))),
                child: !_inputInfo
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(top: 20, bottom: 12),
                                child:
                                    Stack(alignment: Alignment.center, children: [
                                  Positioned(
                                      child: Text("음악추가하기",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.41,
                                              height: 1.2,
                                              color: Colors.white))),
                                  Positioned(
                                      right: 12,
                                      child: IconButton(
                                        icon: Icon(Icons.clear_outlined),
                                        onPressed: () => _panelController.close(),
                                      ))
                                ])),
                            Container(
                                width: _widgetWidth,
                                margin: EdgeInsets.only(right: 20, left: 20),
                                child: Divider(
                                    color: Color(0x44747474), thickness: 1.0)),
                            Padding(
                                padding: EdgeInsets.only(left: 20, top: 12),
                                child: Text("유튜브에서 원하는 음악의 링크를",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400))),
                            Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text("복사 후 붙여넣기 해주세요",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400))),
                            Container(
                                width: _widgetWidth,
                                padding: EdgeInsets.only(left: 20, top: 24),
                                child: TextFormField(
                                  controller: _linkEditController,
                                  cursorColor: Colors.white,
                                  onChanged: (text) => _rightUrl(text),
                                  decoration: InputDecoration(
                                      fillColor: Color(0xFF262626),
                                      hintText: "이곳에 링크 주소를 입력해주세요",
                                      contentPadding: EdgeInsets.all(20),
                                      filled: true,
                                      suffixIcon: Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(4, 12, 20, 12),
                                          child: _youtubeCheck
                                              ? Container(
                                                  height: 4,
                                                  width: 4,
                                                  child: Lottie.asset(
                                                      "assets/lottie/check_animation.zip",
                                                      repeat: false,
                                                      height: 4,
                                                      width: 4,
                                                      fit: BoxFit.fill))
                                              : Container(width: 1)),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(4))),
                                )),
                            !_youtubeCheck
                                ? Container(
                                    margin: EdgeInsets.only(
                                        left: 20, top: 12, bottom: 16),
                                    child: Text(
                                      "음악의 00:00~01:00 구간이 삽입됩니다",
                                      style: TextStyle(
                                          color: Color(0xFF5894FC),
                                          fontSize: 13,
                                          fontFamily: "Pretendard",
                                          fontWeight: FontWeight.w400),
                                    ))
                                : YoutubePlayerBuilder(
                                    player: YoutubePlayer(
                                      width: 10,
                                      controller: _playerController,
                                    ),
                                    builder: (context, player) =>
                                        Stack(children: [
                                          Positioned(
                                              left: 10, top: 10, child: player),
                                          Positioned(
                                              child: Container(
                                                  height: 40,
                                                  width: 40,
                                                  color: MmntStyle().mainBlack)),
                                          Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  20, 12, 20, 12),
                                              width: _widgetWidth,
                                              child: StreamBuilder<DurationState>(
                                                  stream: _getDuration(),
                                                  builder: (context, snapshot) {
                                                    final DurationState?
                                                        durationState =
                                                        snapshot.data;
                                                    Duration progress =
                                                        durationState?.progress ??
                                                            Duration.zero;
                                                    Duration buffered =
                                                        durationState?.buffered ??
                                                            Duration.zero;
                                                    if (buffered >
                                                        Duration(
                                                            milliseconds:
                                                                59000)) {
                                                      buffered = Duration(
                                                          milliseconds: 60000);
                                                    }
                                                    return LocalProgressBar
                                                        .ProgressBar(
                                                            progress: progress,
                                                            buffered: buffered,
                                                            barHeight: 4,
                                                            thumbRadius: 6,
                                                            total: const Duration(
                                                                minutes: 1),
                                                            progressBarColor:
                                                                Color(0xFF5894FC),
                                                            thumbColor:
                                                                Color(0xFF5894FC),
                                                            baseBarColor: Colors
                                                                .white
                                                                .withOpacity(
                                                                    0.24),
                                                            bufferedBarColor:
                                                                Colors.white
                                                                    .withOpacity(
                                                                        0.24),
                                                            onSeek: (duration) {
                                                              _playerController
                                                                  .seekTo(
                                                                      duration);
                                                            });
                                                  }))
                                        ])),
                            Padding(
                                padding:
                                    EdgeInsets.only(left: 20, top: 24, right: 20),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        fixedSize:
                                            Size(_widgetWidth, _widgetHeight),
                                        primary: MmntStyle().primary),
                                    onPressed: () => _pannelButtonClick(),
                                    child: Text(
                                        !_youtubeCheck
                                            ? _youtubeGoButtonString
                                            : _inputSongInfoButton,
                                        style: StoryTextStyle().buttonWhite)))
                          ])
                    : Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_back_ios),
                                    onPressed: () => setState(() {
                                      _inputInfo = false;
                                    }),
                                  ),
                                  Text("음악 정보 입력하기"),
                                  IconButton(
                                    icon: Icon(Icons.clear_outlined),
                                    onPressed: () => _panelController.close(),
                                  )
                                ]),
                            Container(
                                width: _widgetWidth,
                                margin: EdgeInsets.only(right: 10, left: 10),
                                child: Divider(
                                    color: Color(0x44747474), thickness: 1.0)),
                            Padding(
                                padding: EdgeInsets.only(left: 10, top: 12),
                                child: Text("음원의 공식적인 곡명과",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400))),
                            Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text("아티스트명을 입력해 주세요",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400))),
                            Container(
                                width: _widgetWidth,
                                padding:
                                    EdgeInsets.only(left: 10, top: 24, right: 10),
                                child: TextFormField(
                                    controller: _trackNameController,
                                    decoration: InputDecoration(
                                        fillColor: Color(0xFF262626),
                                        hintText: "곡 제목을 입력해주세요",
                                        filled: true,
                                        // suffixIcon: Icon(
                                        //   Icons.check_circle,
                                        // ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(4))))),
                            Container(
                                width: _widgetWidth,
                                padding:
                                    EdgeInsets.only(left: 10, top: 12, right: 10),
                                child: TextFormField(
                                    controller: _artistController,
                                    decoration: InputDecoration(
                                        fillColor: Color(0xFF262626),
                                        hintText: "아티스트명을 입력해주세요",
                                        filled: true,
                                        // suffixIcon: Icon(
                                        //   Icons.check_circle,
                                        // ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(4))))),
                            Padding(
                                padding: EdgeInsets.fromLTRB(10, 40, 10, 0),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        fixedSize:
                                            Size(_widgetWidth, _widgetHeight),
                                        primary: MmntStyle().primary),
                                    onPressed: () => _postAll(),
                                    child: Text("완료",
                                        style: StoryTextStyle().buttonWhite)))
                          ],
                        ))),
            body: ImageContainer.textInput(
                MediaQuery.of(context).size, this.widget._imageFile),
          )),
    );
  }
}

class DurationState {
  final Duration progress;
  final Duration buffered;
  const DurationState({required this.progress, required this.buffered});
}
