import 'dart:io';

import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';

class CheckImage extends StatelessWidget {
  late File _imageFile;

  CheckImage(this._imageFile) {}

  void _nextButton() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
        title: Text(
          "사진 불러오기",
          style: StoryTextStyle().appBarWhite,
        ),
        actions: [
          GestureDetector(
              onTap: () => _nextButton(),
              child: Center(
                  child: Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Text("다음",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)))))
        ],
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
    );
  }
}
