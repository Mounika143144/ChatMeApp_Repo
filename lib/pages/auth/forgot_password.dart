import 'package:chatme/pages/auth/login_page.dart';
import 'package:chatme/service/check_internet_connectivity.dart';
import 'package:chatme/widgets/common_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidate = AutovalidateMode.disabled;
  final emailController = TextEditingController();
  bool isConnected = true;
  CheckInternetConnectivity c = CheckInternetConnectivity();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                nextScreen(context, const LoginPage());
              },
            ),
          ),
          body: Center(
            child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          'Receive an Email to Reset your Password',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          autovalidateMode: autovalidate,
                          validator: (mail) {
                            if (!mail.toString().contains('@')) {
                              return "Please enter a valid email";
                            }
                            if (mail == null || mail.isEmpty) {
                              return "Enter your email";
                            }
                            return null;
                          },
                          controller: emailController,
                          decoration: const InputDecoration(
                            hintText: 'Enter Email ID',
                            hintStyle: TextStyle(color: Colors.black),
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.black,
                            ),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 0.1),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 58, 107, 58),
                                ),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15))),
                          ),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.normal),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor),
                          onPressed: () async {
                            isConnected = await c.checkInternetConnection();
                            if (isConnected) {
                              if (formKey.currentState!.validate()) {
                                try {
                                  ResetPassword(emailController.text);
                                  showSnackbar(context, Colors.green,
                                      'Email sent successfully');
                                } on FirebaseAuthException catch (e) {
                                  showSnackbar(context, Colors.red,
                                      e.message.toString());
                                }
                              }
                            } else {
                              const snackBar = SnackBar(
                                content: Text('No internet connection'),
                                backgroundColor: Colors.red,
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          },
                          child: const Text('Send Email'))
                    ],
                  ),
                )),
          )),
    );
  }
}

Future ResetPassword(String email) async {
  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
}
