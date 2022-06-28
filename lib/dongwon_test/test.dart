import 'package:dash_mement/component/story/image_container.dart';
import 'package:dash_mement/style/story_textstyle.dart';
import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  GlobalKey _globalKey = GlobalKey();

  getSize(GlobalKey key) {
    RenderBox b = key.currentContext!.findRenderObject() as RenderBox;
    print(b.size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: Container(
              key: _globalKey,
              child: Center(
                  child: ImageContainer(MediaQuery.of(context).size,
                      './assets/test/h1_test.jpg')))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => getSize(_globalKey),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
      ),
    );
  }
}
