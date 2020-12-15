import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gtaxi_app/screens/loginpage.dart';
import 'package:gtaxi_app/screens/mainpage.dart';
import 'package:gtaxi_app/widgets/ProgressDialog.dart';
import 'package:gtaxi_app/widgets/TaxiButton.dart';

import '../brand_colors.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = "register";

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  void showSnackBar(String title) {
    final snackBar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void registerUser() async {
    //show please wait dialog

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              status: "Registering you... ",
            ));
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (userCredential != null) {
        DatabaseReference newUserRef = FirebaseDatabase.instance
            .reference()
            .child("users/${userCredential.user.uid}");
        //Prepare data to be saved on users table
        Map userMap = {
          "fullName": fullNameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
        };

        newUserRef.set(userMap);

        // take user to mainPage

        Navigator.pushNamedAndRemoveUntil(
            context, MainPage.id, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        showSnackBar(e.code.toString());
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        showSnackBar(e.code.toString());
      }
    } catch (e) {
      Navigator.pop(context);
      showSnackBar(e.toString());
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 70,
                ),
                Image(
                  alignment: Alignment.center,
                  height: 100,
                  width: 100,
                  image: AssetImage("images/logo.png"),
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  "Create Rider\'s Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: "Brand-Bold"),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: fullNameController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: "Full Name",
                            labelStyle: TextStyle(
                              fontSize: 14,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            )),
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: "Email Address",
                            labelStyle: TextStyle(
                              fontSize: 14,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            )),
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: "Phone Number",
                            labelStyle: TextStyle(
                              fontSize: 14,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            )),
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(
                              fontSize: 14,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            )),
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      TaxiButton(
                        title: "REGISTER",
                        color: BrandColors.colorGreen,
                        onPressed: () async {
                          //checkNetwork  Avalibilty
                          var connectivityResult =
                              await Connectivity().checkConnectivity();
                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar("No internet connectivity");
                          }

                          if (fullNameController.text.length < 3) {
                            showSnackBar("Please provide a valid full name");
                            return;
                          }
                          if (phoneController.text.length < 10) {
                            showSnackBar("Please provide a valid phone number");
                            return;
                          }

                          if (!emailController.text.contains("@")) {
                            showSnackBar(
                                "Please provide a valid email address");
                            return;
                          }

                          if (passwordController.text.length < 8) {
                            showSnackBar(
                                "Password must be at least 8 characters");
                            return;
                          }
                          registerUser();
                        },
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginPage.id, (route) => false);
                  },
                  child: Text("Already have a RIDER account? Log in"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
