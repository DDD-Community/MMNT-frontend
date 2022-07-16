import 'dart:io';
import 'package:dash_mement/poststory/check_image.dart';
import 'package:dash_mement/providers/pushstory_provider.dart';
import 'package:dash_mement/style/mmnt_style.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PostImage extends StatelessWidget {
  Widget _inform = Image.asset("assets/images/check_image.png");
  final ImagePicker _picker = ImagePicker();
  late Function _backButton;
  double? lat_y;
  double? lng_x;

  PostImage(this._backButton) {}

  PostImage.newPin({required double latitude_y, required double longitude_x}) {
    lat_y = latitude_y;
    lng_x = longitude_x;
  }

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

  void _popWidget(BuildContext context) {
    _backButton();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Size _buttonSize = Size(MediaQuery.of(context).size.width * 0.9,
        MediaQuery.of(context).size.height * 0.075);
    if (lat_y != null && lng_x != null) {
      PushStoryProvider pushStory = Provider.of<PushStoryProvider>(context);
      pushStory.latitude_y = lat_y!;
      pushStory.longitude_x = lng_x!;
    }

    return Scaffold(
        backgroundColor: MmntStyle().mainBlack,
        appBar: AppBar(
          shadowColor: Colors.transparent,
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: MmntStyle().mainBlack,
          title: Text("모먼트 추가하기", style: StoryTextStyle().appBarWhite),
          actions: [
            IconButton(
              icon: Icon(Icons.close_outlined),
              onPressed: () => _popWidget(context),
            ),
          ],
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
                    primary: MmntStyle().primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
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
                    primary: MmntStyle().primaryDisable,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
                child: Text("새로운 사진 촬영하기", style: StoryTextStyle().buttonWhite),
                onPressed: () => _pickImage(context),
              ))
        ]));
  }
}
