import 'package:flutter/material.dart';

class MnmtToast extends StatelessWidget {
  late String _message;
  late double _width;

  MnmtToast({required String message, required double width}) {
    this._message = message;
    this._width = width;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: _width,
        decoration: BoxDecoration(
            color: Color(0xFF262626),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(blurRadius: 50, color: Colors.black.withOpacity(0.4))
            ]),
        child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.asset("assets/images/good_status.png",
                    width: 20, height: 20),
                Text(_message,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600)),
              ],
            )));
  }
}
