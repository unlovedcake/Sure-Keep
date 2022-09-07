import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_view/splash_view.dart';
import 'package:splash_view/utils/done.dart';
import 'package:sure_keep/All-Constants/all_constants.dart';
import 'package:sure_keep/Pages/home/home-screen.dart';
import 'package:sure_keep/Pages/sign_in/sigin_screen.dart';
import 'Models/user-model.dart';
import 'Provider/auth-provider.dart';
import 'Provider/chat-provider.dart';
import 'Provider/theme-provider.dart';
import 'Theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String email = prefs.getString('email') ?? "";
  int duration = prefs.getInt('duration') ?? 30;
  bool? isBackGround = prefs.getBool('isBackGroundMode');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MyApp(email: email, duration: duration, isBackGround: isBackGround!),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String email;
  final int duration;
  final bool isBackGround;

  MyApp({required this.email,required this.duration,required this.isBackGround, Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {

      print("RESUME");

    } else if (state == AppLifecycleState.inactive && widget.isBackGround == true) {

       Future.delayed(Duration(seconds: widget.duration)).then((value) {
         print("INACTIVE");
         context.read<AuthProvider>().setAppActive(true);
       });

    } else if (state == AppLifecycleState.paused  && widget.isBackGround == true) {
      Future.delayed(Duration(seconds: widget.duration)).then((value) {
        print("PAUSE");
        context.read<AuthProvider>().setAppActive(true);
      });

    } else if (state == AppLifecycleState.detached  && widget.isBackGround == true) {
      Future.delayed(Duration(seconds: widget.duration)).then((value) {
        print("DETACHED");
        context.read<AuthProvider>().setAppActive(true);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      home: SplashView(
          gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Colors.white, AppColors.logoColor]),
          loadingIndicator: const RefreshProgressIndicator(),

          logo: SizedBox(
            height: 150,
            width: 150,
            child: Image.asset('assets/images/logo.png'),
          ),
          done: widget.email == "" ? Done(const SignInScreen(), animationDuration: Duration(seconds: 2),
            curve: Curves.easeInOut,) : Done(const Home(), animationDuration: Duration(seconds: 2),
            curve: Curves.easeInOut,)),
      //home:  email == "" ? const SignInScreen() : Home(),
      debugShowCheckedModeBanner: false,
      //color: Colors.indigo[900],
    );
  }
}
