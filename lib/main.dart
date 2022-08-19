import 'package:dash_mement/domain/story.dart';
import 'package:dash_mement/providers/app_provider.dart';
import 'package:dash_mement/poststory/post_image.dart';
import 'package:dash_mement/providers/map_provider.dart';
import 'package:dash_mement/providers/pushstory_provider.dart';
import 'package:dash_mement/screens/map_screen.dart';
import 'package:dash_mement/screens/sign_in_screen.dart';
import 'package:dash_mement/screens/sign_up_screen.dart';
import 'package:dash_mement/showstory/show_story_arguments.dart';
import 'package:dash_mement/showstory/show_story_test.dart';
import 'package:dash_mement/showstory/testScreen.dart';
import 'package:dash_mement/userpage/user_history.dart';
import 'package:dash_mement/userpage/user_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/style_constants.dart';
import 'providers/info_window_provider.dart';
import 'providers/storylist_provider.dart';
import 'screens/login_screen.dart';
import 'screens/permission_screen.dart';
import 'screens/splash.dart';
import 'showstory/show_story.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: "assets/config/.env");
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => InfoWindowProvider()),
        ChangeNotifierProvider(create: (_) => StoryListProvider()),
        ChangeNotifierProvider(create: (_) => PushStoryProvider())
      ],
      child: FutureBuilder(
        future: Init.instance.initialize(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Splash(),
            );
          } else {
            return ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (BuildContext context, Widget? child) {
                return MaterialApp(
                  title: 'dash_moment',
                  debugShowCheckedModeBanner: false,
                  // home: LoginScreen(),  // 기존 코드
                  // home: ShowStory(_storyList[0].link), // 테스트 홈, 첫 이니셜 링크가 필요

                  // Dark theme 기반
                  theme: ThemeData(
                      fontFamily: 'Pretendard',
                      brightness: Brightness.dark,
                      highlightColor: Colors.yellow,
                      scaffoldBackgroundColor: Colors.black,
                      appBarTheme: AppBarTheme(
                          centerTitle: true,
                          titleTextStyle: kGrayBold18,
                          color: Colors.black,
                          iconTheme: IconThemeData(
                            color: kAppbarIconColor,
                          )),
                      floatingActionButtonTheme:
                          const FloatingActionButtonThemeData(
                        backgroundColor: Color(0xFF1E5EFF),
                      ),
                      textTheme: TextTheme(
                        // bodyText2가 기본 텍스트 스타일
                        bodyText2: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w700),
                      ),
                      elevatedButtonTheme: ElevatedButtonThemeData(
                          style: ElevatedButton.styleFrom(
                              primary: kElevatedButtonColor)),
                      textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                              primary: const Color(0xFF707077),
                              textStyle: TextStyle(fontSize: 15.sp))),
                      inputDecorationTheme: InputDecorationTheme(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: kTextFormFieldUnderlineColor,
                                  width: 1.5)))),
                  initialRoute: '/user-page-screen',
                  routes: {
                    '/': (context) => const LoginScreen(),
                    '/sign-up-screen': (context) => const SignUpScreen(),
                    '/sign-in-screen': (context) => const SignInScreen(),
                    '/map-screen': (context) => MapScreen(),
                    ShowStory.routeName: (context) => ShowStory(
                        ModalRoute.of(context)!.settings.arguments
                            as ShowStoryArguments),
                    '/test-screen': (context) => TestScreen(),
                    UserPage.routeName: (context) => UserPage(),
                    ShowStoryTest.routeName: (context) => ShowStoryTest(),
                    UserHistory.routeName: ((context) => UserHistory())
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Init {
  Init._();
  static final instance = Init._();

  Future initialize() async {
    // This is where you can initialize the resources needed by your app while
    await Future.delayed(
        kDebugMode ? const Duration(seconds: 0) : const Duration(seconds: 4));
  }
}
