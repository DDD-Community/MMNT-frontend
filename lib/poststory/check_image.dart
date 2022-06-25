import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dash_mement/showstory/component/image_container.dart';
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

  void _nextButton() {}

  @override
  void initState() {
    super.initState();
    _ftoast = FToast();
    _ftoast.init(context);

    WidgetsBinding.instance.addPostFrameCallback((_) => _showToast());
  }

  _showToast() {
    Widget toast = Container(
        width: 160,
        decoration: BoxDecoration(
            color: Color(0xFF262626), borderRadius: BorderRadius.circular(8)),
        child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Color(0xFF5894FC),
                  size: 18,
                ),
                Text("사진 불러오기 성공!",
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600))
              ],
            )));

    _ftoast.showToast(
        child: toast,
        toastDuration: Duration(seconds: 3),
        positionedToastBuilder: (context, child) =>
            Positioned(bottom: 80, left: 0.0, right: 0.0, child: child));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              )),
          title: Text(
            "사진 불러오기",
            style: StoryTextStyle().appBarBlack,
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
        body: ImageContainer.file(
            MediaQuery.of(context).size, this.widget._imageFile));
  }
}
