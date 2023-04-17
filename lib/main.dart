import 'package:chatme/firebase_options.dart';
import 'package:chatme/helper/globalNotification.dart';
import 'package:chatme/helper/helper_function.dart';
import 'package:chatme/pages/auth/login_page.dart';
import 'package:chatme/pages/home_page.dart';
import 'package:chatme/shared/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!kIsWeb) {
    await GlobalNotificationSetup().registerNotification();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isSignedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        theme: ThemeData(primaryColor: Constants().primaryColor, scaffoldBackgroundColor: Colors.white),
        debugShowCheckedModeBanner: false,
        home: _isSignedIn ? const HomePage() : const LoginPage(),
      ),
    );
  }
}
