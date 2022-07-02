import 'dart:io';
import 'package:dash_mement/component/toast/mmnt_toast.dart';
import 'package:dash_mement/poststory/post_text.dart';
import 'package:dash_mement/style/mmnt_style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dash_mement/component/story/image_container.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';

class CheckImage extends StatefulWidget {
  late File _imageFile;
  CheckImage(this._imageFile) {}

  @override
  State<StatefulWidget> createState() {
    return _CheckImage();
  }
}

class _CheckImage extends State<CheckImage> {
  late FToast _ftoast;

  void _nextButton() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => PostText(this.widget._imageFile)));
  }

  @override
  void initState() {
    super.initState();
    _ftoast = FToast();
    _ftoast.init(context);

    WidgetsBinding.instance.addPostFrameCallback((_) => _showToast());
  }

  _showToast() {
    Widget toast = MnmtToast(message: "사진 불러오기 성공!", width: 160, radius: 20);
    _ftoast.showToast(
        child: toast,
        toastDuration: Duration(seconds: 3),
        positionedToastBuilder: (context, child) =>
            Positioned(bottom: 80, left: 0.0, right: 0.0, child: child));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MmntStyle().mainBlack,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: MmntStyle().mainWhite,
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
                                color: MmntStyle().mainWhite,
                                fontWeight: FontWeight.bold)))))
          ],
          backgroundColor: MmntStyle().mainBlack,
          shadowColor: Colors.transparent,
        ),
        body: ImageContainer.file(
            MediaQuery.of(context).size, this.widget._imageFile));
  }
}
