import 'dart:io';
import 'package:dash_mement/poststory/check_image.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostImage extends StatelessWidget {
  Widget _inform = Container();
  final ImagePicker _picker = ImagePicker();

  void _getImage(BuildContext context) async {
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => CheckImage(File(image.path))));
    }
  }

  void _pickImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) {
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => CheckImage(File(image.path))));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size _buttonSize = Size(MediaQuery.of(context).size.width * 0.9,
        MediaQuery.of(context).size.height * 0.06);
    return Scaffold(
        backgroundColor: Color(0x1E000000),
        appBar: AppBar(
          backgroundColor: Color(0x1E000000),
          title: Text("모먼트 추가하기", style: StoryTextStyle().appBarWhite),
        ),
        body: Column(children: [
          Expanded(
              child: Container(
            child: _inform,
          )),
          Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    fixedSize: _buttonSize,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: Text(
                  "갤러리에서 사진 불러오기",
                  style: StoryTextStyle().buttonWhite,
                ),
                onPressed: () => _getImage(context),
              )),
          Padding(
              padding: EdgeInsets.only(bottom: 52),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    fixedSize: _buttonSize,
                    primary: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: Text("새로운 사진 촬영하기", style: StoryTextStyle().buttonBlack),
                onPressed: () => _pickImage(context),
              ))
        ]));
  }
}
