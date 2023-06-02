import 'package:chatme/helper/helper_function.dart';
import 'package:chatme/pages/home_page.dart';
import 'package:chatme/res/custom_colors.dart';
import 'package:chatme/res/fire_assets.dart';
import 'package:chatme/service/auth_service.dart';
import 'package:chatme/service/check_internet_connectivity.dart';
import 'package:chatme/service/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

  @override
  GoogleSignInButtonState createState() => GoogleSignInButtonState();
}

class GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;
   bool isConnected = true;
  CheckInternetConnectivity c = CheckInternetConnectivity();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _isSigningIn
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Palette.firebaseOrange),
            )
          : OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: () async {
                isConnected = await c.checkInternetConnection();
                if (isConnected) {
                  setState(() {
                    _isSigningIn = true;
                  });
                  User? user =
                      await AuthService.signInWithGoogle(context: context);
                  QuerySnapshot snapshot = await DatabaseService(uid: user!.uid)
                      .gettingUserData(user.email!);

                  if (snapshot.docs.isEmpty) {
                    await DatabaseService(uid: user.uid)
                        .savingUserData(user.displayName!, user.email!);
                  }
                  // saving the values to our shared preferences
                  await HelperFunctions.saveUserLoggedInStatus(true);
                  await HelperFunctions.saveUserEmailSF(user.email!);
                  await HelperFunctions.saveUserNameSF(user.displayName!);
                  setState(() {
                    _isSigningIn = false;
                  });

                  // ignore: unnecessary_null_comparison
                  if (user != null) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  }
                } else {
                  const snackBar = SnackBar(
                    content: Text('No internet connection'),
                    backgroundColor: Colors.red,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage(FireAssets.googleLogo),
                      height: 24.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
