import 'package:chatme/helper/helper_function.dart';
import 'package:chatme/pages/auth/login_page.dart';
import 'package:chatme/pages/home_page.dart';
import 'package:chatme/service/auth_service.dart';
import 'package:chatme/service/check_internet_connectivity.dart';
import 'package:chatme/widgets/common_widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String fullName = "";
  AuthService authService = AuthService();
  bool isConnected = true;
  CheckInternetConnectivity c = CheckInternetConnectivity();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor))
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
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
                        // const Text(
                        //   "ChatMe",
                        //   style: TextStyle(
                        //       fontSize: 40, fontWeight: FontWeight.bold),
                        // ),
                        const SizedBox(height: 10),
                        const Text(
                            "Create your account now to chat and explore",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Pacifico',
                                color: Colors.green)),
                        Image.asset(
                          "assets/register1.jpg",
                          height: 280,
                          width: 280,
                        ),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              labelText: "Full Name",
                              prefixIcon: Icon(
                                Icons.person,
                                color: Theme.of(context).primaryColor,
                              )),
                          onChanged: (val) {
                            setState(() {
                              fullName = val;
                            });
                          },
                          validator: (val) {
                            if (val!.isNotEmpty) {
                              return null;
                            } else {
                              return "Name cannot be empty";
                            }
                          },
                        ),
                        const SizedBox(
                          height: 15,
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
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: const Text(
                              "Register",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            onPressed: () {
                              register();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Already have an account?',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const WidgetSpan(child: SizedBox(width: 10)),
                              TextSpan(
                                  text: 'Login now',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    decoration: TextDecoration.underline,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      nextScreen(context, const LoginPage());
                                    }),
                            ],
                          ),
                        ),
                        // Text.rich(TextSpan(
                        //   text: "Already have an account? ",
                        //   style: const TextStyle(
                        //       color: Colors.black, fontSize: 14),
                        //   children: <TextSpan>[
                        //     TextSpan(
                        //         text: "Login now",
                        //         style: const TextStyle(
                        //             color: Colors.black,
                        //             decoration: TextDecoration.underline),
                        //         recognizer: TapGestureRecognizer()
                        //           ..onTap = () {
                        //             nextScreen(context, const LoginPage());
                        //           }),
                        //   ],
                        // )),
                      ],
                    )),
              ),
            ),
    );
  }

  register() async {
    isConnected = await c.checkInternetConnection();
    if (isConnected) {
      if (formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        final messaging = FirebaseMessaging.instance;

        await authService
            .registerUserWithEmailandPassword(fullName, email, password)
            .then((value) async {
          if (value == true) {
            // saving the shared preference state
            await HelperFunctions.saveUserLoggedInStatus(true);
            await HelperFunctions.saveUserEmailSF(email);
            await HelperFunctions.saveUserNameSF(fullName);
            nextScreenReplace(context, const HomePage());
            showSnackbar(context, Colors.green,
                "Your account has been successfully registered");
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
