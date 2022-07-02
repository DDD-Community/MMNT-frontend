import 'package:flutter/material.dart';

class MnmtToast extends StatelessWidget {
  late String _message;
  late double _width;
  late double _radius;

  MnmtToast(
      {required String message,
      required double width,
      required double radius}) {
    this._message = message;
    this._width = width;
    this._radius = radius;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: _width,
        decoration: BoxDecoration(
            color: Color(0xFF262626),
            borderRadius: BorderRadius.circular(_radius)),
        child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(_message,
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600)),
                Icon(
                  Icons.check_circle_sharp,
                  color: Color(0xFF5894FC),
                  size: 18,
                ),
              ],
            )));
  }
}
