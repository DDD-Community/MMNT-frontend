import 'package:dash_mement/domain/story.dart';
import 'package:dash_mement/component/story/date_widget.dart';
import 'package:dash_mement/component/story/storytext_widget.dart';
import 'package:dash_mement/component/story/trackInfo_widget.dart';
import 'package:dash_mement/component/story/username_widget.dart';
import 'package:dash_mement/style/mmnt_style.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../screens/map_screen.dart';

class StoryColumn extends StatelessWidget {
  late Story _story;
  late DateWidget _dateWidget;
  late UserNameWidget _userNameWidget;
  late TrackInfoWidget _trackInfoWidget;
  late StoryText _storyText;

  StoryColumn(this._story) {
    _dateWidget = DateWidget(this._story.dateTime);
    _userNameWidget = UserNameWidget.fromId(this._story.user);
    _trackInfoWidget = TrackInfoWidget(this._story.track, this._story.artist);
    _storyText = StoryText(this._story.title, this._story.msg);
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(children: [
        Row(
          children: [
            const Spacer(),
            TextButton(onPressed: () => showReportDialog(context), child: Text("신고하기", style: TextStyle(fontSize: 13, color: Colors.orange.withOpacity(0.8)),)),
            TextButton(onPressed: () => showBlockDialog(context, _story.user), child: Text("차단하기", style: TextStyle(fontSize: 13, color: Colors.orange.withOpacity(0.8)),))
          ],
        ),
        Padding(
            padding: EdgeInsets.only(bottom: 12, top: 28), child: _dateWidget),
        _userNameWidget
      ]),
      _storyText,
      Padding(padding: EdgeInsets.only(bottom: 42), child: _trackInfoWidget)
    ]);
  }
}

void showReportDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("신고하기"),
          content: Column(
            children: [
              Text("3건 이상의 요청이 들어오면 자동 삭제됩니다"),
              SizedBox(height: 10,),
              Text("praconfi@gmail.com 메일 보내주시면,"),
              Text("확인 후 24시간 이내 삭제 조치 됩니다 "),
              ReportCases(),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("취소")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(msg: "신고가 접수되었습니다");
                },
                child: Text("확인", style: TextStyle(color: MmntStyle().primary),))
          ],
        );
      });
}
void showBlockDialog(BuildContext context, String userId) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("차단하기"),
          content: Column(
            children: [
              Text("해당 유저의 글을 더 이상 볼 수 없습니다"),
              SizedBox(height: 10,),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("취소")),
            TextButton(
                onPressed: () {
                  // final prefs = await SharedPreferences.getInstance();
                  // prefs.setStringList("block-user", ["${_story.user}", "test"]);
                  // var blockUser = prefs.getStringList("block-user");
                  // blockUser!.add(userId);
                  // prefs.setString('token', response.data['result']['accessToken']);
                  // Navigator.of(context).pop();
                  Fluttertoast.showToast(msg: "해당 유저가 차단되었습니다.");
                  Navigator.pushNamedAndRemoveUntil(context, MapScreen.routeName, (route) => false);
                },
                child: Text("확인", style: TextStyle(color: MmntStyle().primary),))
          ],
        );
      });
}

enum ReportReason { obscene, hate, violent }
class ReportCases extends StatefulWidget {
  const ReportCases({super.key});

  @override
  State<ReportCases> createState() => _ReportCasesState();
}

class _ReportCasesState extends State<ReportCases> {
  ReportReason? _character = ReportReason.obscene;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile<ReportReason>(
          title: const Text('음란 콘텐츠'),
          value: ReportReason.obscene,
          groupValue: _character,
          onChanged: (ReportReason? value) {
            setState(() {
              _character = value;
            });
          },
        ),
        RadioListTile<ReportReason>(
          title: const Text('증오성 콘텐츠'),
          value: ReportReason.hate,
          groupValue: _character,
          onChanged: (ReportReason? value) {
            setState(() {
              _character = value;
            });
          },
        ),
        RadioListTile<ReportReason>(
          title: const Text('폭력적 콘텐츠'),
          value: ReportReason.violent,
          groupValue: _character,
          onChanged: (ReportReason? value) {
            setState(() {
              _character = value;
            });
          },
        ),
      ],
    );
  }
}
