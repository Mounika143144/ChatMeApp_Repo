
import 'package:chatme/helper/helper_function.dart';
import 'package:chatme/pages/auth/forgot_password.dart';
import 'package:chatme/pages/auth/register_page.dart';
import 'package:chatme/pages/home_page.dart';
import 'package:chatme/res/custom_colors.dart';
import 'package:chatme/service/auth_service.dart';
import 'package:chatme/service/check_internet_connectivity.dart';
import 'package:chatme/service/database_service.dart';
import 'package:chatme/widgets/common_widgets.dart';
import 'package:chatme/widgets/google_sign_in_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
 
  bool isConnected = true;
  CheckInternetConnectivity c = CheckInternetConnectivity();

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
                child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "assets/chatme.png",
                          height: 60,
                          width: 100,
                        ),
                        // const Text("ChatMe",
                        //     style: TextStyle(
                        //         fontSize: 40, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text("Login now to see what they are talking!",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Pacifico',
                                color: Colors.green)),
                        Image.asset(
                          "assets/login1.jpg",
                          height: 250,
                          width: 250,
                        ),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              labelText: "Email",
                              prefixIcon: Icon(
                                Icons.email,
                                color: Theme.of(context).primaryColor,
                              )),
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                          // check tha validation
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val!)
                                ? null
                                : "Please enter a valid email";
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          obscureText: true,
                          decoration: textInputDecoration.copyWith(
                              labelText: "Password",
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Theme.of(context).primaryColor,
                              )),
                          validator: (val) {
                            if (val!.length < 6) {
                              return "Password must be at least 6 characters";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: GestureDetector(
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 14,
                                      color: Colors.black),
                                ),
                                onTap: () {
                                  nextScreen(context, const ForgotPassword());
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: const Text(
                              "Sign In",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            onPressed: () {
                              login();
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder(
                          future:
                              AuthService.initializeFirebase(context: context),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Error initializing Firebase');
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return const GoogleSignInButton();
                            }
                            return const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Palette.firebaseOrange,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Don\'t have an Account?',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),

                              const WidgetSpan(child: SizedBox(width: 10)),

                              ///this

                              TextSpan(
                                text: 'Register Here',
                                style: TextStyle(
                                   color: Theme.of(context).primaryColor,
                                   decoration: TextDecoration.underline,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                ),
                                  recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, const RegisterPage());
                                  }
                              ),
                            ],
                          ),
                        ),
                        // Text.rich(TextSpan(
                        //   text: "Don't have an account? ",
                        //   style: const TextStyle(
                        //       color: Colors.black, fontSize: 14),
                        //   children: <TextSpan>[
                        //     TextSpan(
                        //         text: "Register here",
                        //         style: const TextStyle(
                        //             color: Colors.black,
                        //             decoration: TextDecoration.underline),
                        //         recognizer: TapGestureRecognizer()
                        //           ..onTap = () {
                        //             nextScreen(context, const RegisterPage());
                        //           }),
                        //   ],
                        // )
                        // ),
                      ],
                    )),
              ),
            ),
    );
  }

  login() async {
    isConnected = await c.checkInternetConnection();
    if (isConnected) {
      if (formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        await authService
            .loginWithUserNameandPassword(email, password)
            .then((value) async {
          if (value == true) {
            print(value);
            QuerySnapshot snapshot = await DatabaseService(
                    uid: FirebaseAuth.instance.currentUser!.uid)
                .gettingUserData(email);
            // saving the values to our shared preferences
            await HelperFunctions.saveUserLoggedInStatus(true);
            await HelperFunctions.saveUserEmailSF(email);
            await HelperFunctions.saveUserNameSF(snapshot.docs[0]['fullName']);
            nextScreenReplace(context, const HomePage());
             showSnackbar(
                          context, Colors.green, "Successfully Logged In");
          } else {
            showSnackbar(context, Colors.red, value);
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
    } else {
      const snackBar = SnackBar(
        content: Text('No internet connection'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

 
}
