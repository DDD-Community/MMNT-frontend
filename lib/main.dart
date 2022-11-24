import 'package:dash_mement/providers/app_provider.dart';
import 'package:dash_mement/providers/map_provider.dart';
import 'package:dash_mement/providers/pushstory_provider.dart';
import 'package:dash_mement/screens/account_manage_screen.dart';
import 'package:dash_mement/screens/password_change_screen.dart';
import 'package:dash_mement/screens/pin_create_screen.dart';
import 'package:dash_mement/screens/map_screen.dart';
import 'package:dash_mement/screens/setting_screen.dart';
import 'package:dash_mement/screens/sign_in_screen.dart';
import 'package:dash_mement/screens/sign_up_screen.dart';
import 'package:dash_mement/screens/web_view_screen.dart';
import 'package:dash_mement/showstory/show_story_arguments.dart';
import 'package:dash_mement/showstory/show_story_test.dart';
import 'package:dash_mement/style/custom_theme.dart';
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

    if (kDebugMode) {
      return const MmntApp();
    }
    return FutureBuilder(
      future: Init.instance.initialize(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Splash(),
          );
        } else {
          return const MmntApp();
        }
      },
    );
  }
}

class MmntApp extends StatelessWidget {
  const MmntApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (BuildContext context, Widget? child) {
        return MultiProvider(
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
            darkTheme: customDarkTheme(),
            theme: customDarkTheme(),
            themeMode: ThemeMode.dark,
            initialRoute: LoginScreen.routeName,
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
              SettingScreen.routeName: (context) => const SettingScreen(),
              AccountManageScreen.routeName: (context) =>const AccountManageScreen(),
              PasswordChangeScreen.routeName: (context) =>const PasswordChangeScreen(),
              WebViewScreen.routeName: (context) => const WebViewScreen(),
            },
          ),
        );
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
        kDebugMode ? const Duration(seconds: 4) : const Duration(seconds: 4));
  }
}
