import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/style_constants.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({Key? key}) : super(key: key);

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 50.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 88.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 18.w),
                    child: Text(
                      '앱 서비스 접근 권한 안내',
                      style: kWhiteBold24,
                    ),
                  ),
                  SizedBox(
                    height: 48.h,
                  ),
                  const CenteredLeadingListTile(
                    icon: Icons.phone_android,
                    title: '기기 및 앱 기록',
                    subtitle: '서비스 개선 및 오류 확인',
                  ),
                  const CenteredLeadingListTile(
                    icon: Icons.camera_alt_outlined,
                    title: '카메라',
                    subtitle: '서비스 개선 및 오류 확인',
                  ),
                  const CenteredLeadingListTile(
                    icon: Icons.gps_fixed_outlined,
                    title: '(선택)사진',
                    subtitle: '서비스 개선 및 오류 확인',
                  ),
                  const CenteredLeadingListTile(
                    icon: Icons.photo,
                    title: '기기 및 앱 기록',
                    subtitle: '기기 및 앱 기록',
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  ListTile(
                    title: Text(
                      '접근 권한 변경',
                      style: kGrayBold16.copyWith(color: Colors.white),
                    ),
                    subtitle: Text(
                      '마이페이지 > 앱설정 > 내 계정 관리',
                      style: kGray13,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            )),
            SizedBox(
                height: 54.h,
                width: 335.w,
                child: ElevatedButton(onPressed: () {}, child: const Text('확인'))),
          ],
        ),
      ),
    );
  }
}

class CenteredLeadingListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const CenteredLeadingListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Color(0xffBABABA),),
      ],
      ),
      title: Text(title, style: kGrayBold16.copyWith(color: Colors.white),),
      subtitle: Text(subtitle, style: kGray14,),
    );
  }
}
