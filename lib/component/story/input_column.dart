import 'package:dash_mement/component/story/date_widget.dart';
import 'package:dash_mement/component/story/username_widget.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputColumn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InputColumn();
  }

  String test() {
    return "hi";
  }
}

class _InputColumn extends State<InputColumn> {
  late DateWidget _dateWidget;
  late UserNameWidget _userNameWidget;
  late TextEditingController _titleController;
  late TextEditingController _contextController;
  late final FocusNode _titlleFocus;
  late final FocusNode _contextFocus;
  String _titleHint = "제목을 입력해주세요";
  String _contextHint = '텍스트를 입력해주세요\n글자수는 100글자 까지\n 입력 가능합니다.';

  @override
  void initState() {
    super.initState();
    _dateWidget = DateWidget();
    _userNameWidget = UserNameWidget("23번째 익명");
    _titleController = TextEditingController();
    _contextController = TextEditingController();
    _titlleFocus = FocusNode()
      ..addListener(() {
        if (_titlleFocus.hasFocus) {
          setState(() {
            _titleHint = '';
          });
        } else {
          setState(() {
            _titleHint = '제목을 입력해주세요';
          });
        }
      });
    _contextFocus = FocusNode()
      ..addListener(() {
        if (_contextFocus.hasFocus) {
          setState(() {
            _contextHint = '';
          });
        } else {
          setState(() {
            _contextHint = '텍스트를 입력해주세요\n글자수는 100글자 까지\n 입력 가능합니다.';
          });
        }
      });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contextController.dispose();
    _titlleFocus.dispose();
    _contextFocus.dispose();
    super.dispose();
  }

  String test() {
    return _titleController.text;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Column(children: [
        Column(children: [
          Padding(
              padding: EdgeInsets.only(bottom: 4, top: 32), child: _dateWidget),
          _userNameWidget
        ]),
        Container(height: MediaQuery.of(context).size.height * 0.18), //spacer
        Form(
          child: Container(
              width: MediaQuery.of(context).size.width * 0.64,
              child: Column(children: <TextFormField>[
                TextFormField(
                  controller: _titleController,
                  cursorColor: Colors.white,
                  textAlign: TextAlign.center,
                  focusNode: _titlleFocus,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(16)
                  ], //일단 16글자 제한
                  style: StoryTextStyle().title,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_contextFocus),
                  decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      hintText: _titleHint,
                      hintStyle: TextStyle(color: Colors.white)),
                ),
                TextFormField(
                  controller: _contextController,
                  cursorColor: Colors.white,
                  textAlign: TextAlign.center,
                  focusNode: _contextFocus,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80)
                  ], //일단 80제한
                  style: StoryTextStyle().message,
                  decoration: InputDecoration(
                      fillColor: Color(0xBD000000),
                      filled: true,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.all(20),
                      hintText: _contextHint,
                      hintStyle: TextStyle(color: Colors.white)),
                ),
              ])),
        )
      ])
    ]));
  }
}
