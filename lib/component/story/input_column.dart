import 'package:dash_mement/component/story/date_widget.dart';
import 'package:dash_mement/component/story/username_widget.dart';
import 'package:flutter/material.dart';

class InputColumn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InputColumn();
  }
}

class _InputColumn extends State<InputColumn> {
  late DateWidget _dateWidget;
  late UserNameWidget _userNameWidget;
  late TextEditingController _titleController;
  late TextEditingController _contextController;

  @override
  void initState() {
    super.initState();
    _dateWidget = DateWidget();
    _userNameWidget = UserNameWidget("23번째 익명");
    _titleController = TextEditingController();
    _contextController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Column(children: [
        Padding(
            padding: EdgeInsets.only(bottom: 4, top: 32), child: _dateWidget),
        _userNameWidget,
        Form(
          child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(children: <TextFormField>[
                TextFormField(
                  controller: _titleController,
                  cursorColor: Colors.white,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      hintText: "testr",
                      hintStyle: TextStyle(color: Colors.white)),
                ),
                TextFormField(
                  controller: _contextController,
                  cursorColor: Colors.white,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      fillColor: Color(0xFFFFFFFF),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.all(20),
                      hintText: "test",
                      hintStyle: TextStyle(color: Colors.white)),
                ),
              ])),
        )
      ])
    ]);
  }
}
