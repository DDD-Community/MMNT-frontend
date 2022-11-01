import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../style/mmnt_style.dart';

class CustomDialog extends StatelessWidget {
  Function acceptButton;
  CustomDialog({super.key, required this.acceptButton});
  void _acceptButtonClick(BuildContext context) {
    acceptButton();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Center(
        child: Container(
          width: 272.w,
          height: 174.h,
          decoration: BoxDecoration(
            color: MmntStyle().mainBlack,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Text("선택한 모먼트를 삭제하시겠습니까?",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Padding(
                    padding: EdgeInsets.only(top: 10.h, bottom: 24.h),
                    child: Text("삭제한 모먼트는 복구되지 않습니다",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF9E9FA9)))),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: MmntStyle().primaryDisable,
                              fixedSize: Size(102.w, 48.h)),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            "취소",
                            style: TextStyle(
                                color: Color(0xFFD9D9D9),
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                          )),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: MmntStyle().primaryError,
                              fixedSize: Size(102.w, 48.h)),
                          onPressed: () => _acceptButtonClick(context),
                          child: Text("확인",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15)))
                    ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
