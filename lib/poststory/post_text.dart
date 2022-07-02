import 'dart:io';

import 'package:dash_mement/component/story/image_container.dart';
import 'package:dash_mement/providers/pushstory_provider.dart';
import 'package:dash_mement/style/mmnt_style.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostText extends StatefulWidget {
  late File _imageFile;
  PostText(this._imageFile) {}

  @override
  State<StatefulWidget> createState() {
    return _PostText();
  }
}

class _PostText extends State<PostText> {
  late ImageContainer _imageContainer;
  late PushStoryProvider _pushStory;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _imageContainer = ImageContainer.textInput(
          MediaQuery.of(context).size, this.widget._imageFile);
    });
  }

  @override
  void dispose() {
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
        body: ImageContainer.textInput(
            MediaQuery.of(context).size, this.widget._imageFile));
  }
}
