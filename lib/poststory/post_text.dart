import 'dart:io';

import 'package:dash_mement/component/story/image_container.dart';
import 'package:dash_mement/style/mmnt_style.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';

class PostText extends StatefulWidget {
  late File _imageFile;
  late DateTime _now;
  PostText(this._imageFile) {
    _now = DateTime.now();
  }

  @override
  State<StatefulWidget> createState() {
    return _PostText();
  }
}

class _PostText extends State<PostText> {
  void _backButton(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _submit(BuildContext context) {
    print("yes");
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: () => _submit(context),
              child: Center(
                  child: Padding(
                      padding: EdgeInsets.only(right: 8), child: Text("다음"))),
            )
          ],
        ),
        backgroundColor: MmntStyle().mainBlack,
        body: ImageContainer.textInput(
            MediaQuery.of(context).size, this.widget._imageFile));
  }
}
