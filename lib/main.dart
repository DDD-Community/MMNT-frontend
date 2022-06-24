import 'package:dash_mement/domain/story.dart';
import 'package:dash_mement/providers/map_provider.dart';
import 'package:dash_mement/screens/map_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dongwon_test/test.dart';
import 'providers/storylist_provider.dart';
import 'showstory/show_story.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Story> _makeStoryTest() {
    Story _s1 = Story(
        "아주아주 힘든 어느 날",
        "익명1",
        DateTime.parse("2022-04-02 20:18:04Z"),
        "https://www.youtube.com/watch?v=U3BVFY9wnTw",
        "./assets/test/v1_test.jpg",
        "밝게 빛나는 별이 되어 너를 비춰줄게 매일 어두워 헤맬 때도 앞이 두려워도\b 언제나 널 지켜줄게 세상이 널 아프게 할 땐 내가 안아줄게\n 매일포근한 바람으로 따듯한 햇살로난 널 지켜줄게 매일너의 모든 시간 속에 내가 함께할게",
        "SUN GOES DOWN",
        "Lil Nas X",
        "정릉동");
    Story _s2 = Story(
        "기분이 아주 좋아용",
        "익명2",
        DateTime.parse("2022-04-03 12:18:04Z"),
        "https://www.youtube.com/watch?v=yQBImEeXNZ4",
        "./assets/test/v2_test.jpg",
        "내 하드 드라이브엔 히트곡이 가득하지 이런 나랑 같은 날 곡을 내려고? 다시 생각해보셔 너에겐 ‘지방시’가 필요한 게 아니라 예수님이 필요하지",
        "First Class",
        "Jack Harlow",
        "정릉동");
    Story _s3 = Story(
        "여친이랑 원소주 픽업하러 왔어용!",
        "익명3",
        DateTime.parse("2022-04-21 08:20:04Z"),
        "https://www.youtube.com/watch?v=AwCvpQSUMBg",
        "./assets/test/h1_test.jpg",
        "오늘 여친이랑 더현대가서 원소주 사러 갔당가보니 제이팍도 있었다.이런 날은 글 남겨야징~",
        "GANADARA (Feat. IU)",
        "Jay Park",
        "정릉동");
    List<Story> _storyList = [_s1, _s2, _s3];

    return _storyList;
  }

  @override
  Widget build(BuildContext context) {
    List<Story> _storyList = _makeStoryTest();
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => StoryListProvider(_storyList))
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            title: 'dash_moment',
            debugShowCheckedModeBanner: false,
            // home: MapScreen(),  // 기존 코드
            home: ShowStory(_storyList[0].link), // 테스트 홈, 첫 이니셜 링크가 필요

            // Dark theme 기반
            theme: ThemeData(
              fontFamily: 'Pretendard',
              brightness: Brightness.dark,
              highlightColor: Colors.yellow,
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Color(0xFFFD6744),
              ),
              textTheme: TextTheme(
                // bodyText2가 기본 텍스트 스타일
                bodyText2:
                    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
            ),
          );
        },
      ),
    );
  }
}
