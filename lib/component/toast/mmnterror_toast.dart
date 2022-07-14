import 'package:flutter/material.dart';

class MnmtErrorToast extends StatelessWidget {
  late String _message;
  late double _width;
  late double _radius;

  MnmtErrorToast(
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
                Icon(
                  Icons.error,
                  color: Color(0xFFFD6744),
                  size: 20,
                ),
                Text(_message,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600)),
              ],
            )));
  }
}
