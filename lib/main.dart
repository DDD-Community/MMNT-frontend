import 'package:dash_mement/providers/app_provider.dart';
import 'package:dash_mement/providers/map_provider.dart';
import 'package:dash_mement/providers/pushstory_provider.dart';
import 'package:dash_mement/screens/pin_create_screen.dart';
import 'package:dash_mement/screens/map_screen.dart';
import 'package:dash_mement/screens/sign_in_screen.dart';
import 'package:dash_mement/screens/sign_up_screen.dart';
import 'package:dash_mement/showstory/show_story_arguments.dart';
import 'package:dash_mement/showstory/show_story_test.dart';
import 'package:dash_mement/userpage/user_history.dart';
import 'package:dash_mement/userpage/user_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/style_constants.dart';
import 'providers/sliidng_panel_provider.dart';
import 'providers/storylist_provider.dart';
import 'screens/login_screen.dart';
import 'screens/splash.dart';
import 'showstory/show_story.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  await dotenv.load(fileName: "assets/config/.env");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return FutureBuilder(
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
                return
                  MultiProvider(
                    providers: [
                      ChangeNotifierProvider(create: (_) => AppProvider()),
                      ChangeNotifierProvider(create: (_) => MapProvider()),
                      ChangeNotifierProvider(create: (_) => SlidingPanelProvider()),
                      ChangeNotifierProvider(create: (_) => StoryListProvider()),
                      ChangeNotifierProvider(create: (_) => PushStoryProvider())
                    ],
                    child: MaterialApp(
                    title: 'dash_moment',
                    debugShowCheckedModeBanner: false,

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
                    initialRoute: MapScreen.routeName,
                    routes: {
                      LoginScreen.routeName: (context) => const LoginScreen(),
                      SignUpScreen.routeName: (context) => const SignUpScreen(),
                      SignInScreen.routeName: (context) => const SignInScreen(),
                      MapScreen.routeName: (context) => MapScreen(),
                      ShowStory.routeName: (context) => ShowStory(
                          ModalRoute.of(context)!.settings.arguments
                              as ShowStoryArguments),
                      UserPage.routeName: (context) => UserPage(),
                      ShowStoryTest.routeName: (context) => ShowStoryTest(),
                      UserHistory.routeName: (context) => UserHistory(),
                      PinCreateScreen.routeName: (context) => PinCreateScreen(),
                    },
                ),
                  );
              },
            );
          }
        },
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
