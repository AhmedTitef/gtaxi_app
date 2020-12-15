import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gtaxi_app/brand_colors.dart';
import 'package:gtaxi_app/screens/mainpage.dart';
import 'package:gtaxi_app/screens/registrationpage.dart';
import 'package:gtaxi_app/widgets/ProgressDialog.dart';
import 'package:gtaxi_app/widgets/TaxiButton.dart';

class LoginPage extends StatefulWidget {
  static const String id = "login";


  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  final FirebaseAuth _auth = FirebaseAuth.instance;


  void login() async {
    //show please wait dialog


    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(status: "Logging you in",));
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      );

      if (userCredential != null) {
        //verify login

        DatabaseReference userRef = FirebaseDatabase.instance.reference().child(
            "users/${userCredential.user.uid}");
        userRef.once().then((snapshot) {
          if (snapshot.value != null) {

            Navigator.pushNamedAndRemoveUntil(
                context, MainPage.id, (route) => false);
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        showSnackBar(e.code.toString());
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        showSnackBar(e.code.toString());
      }
    }
  }

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

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

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
                  "Sign in as Rider",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: "Brand-Bold"),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
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
                        title: "LOGIN",
                        color: BrandColors.colorGreen,
                        onPressed: () async {
                          //checkNetwork  Avalibilty
                          var connectivityResult =
                          await Connectivity().checkConnectivity();
                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar("No internet connectivity");
                          }


                          if (!emailController.text.contains("@")) {
                            showSnackBar(
                                "Please provide a valid email address");
                            return;
                          }

                          if (passwordController.text.length < 8) {
                            showSnackBar(
                                "Please enter a valid password");
                            return;
                          }


                          login();
                        },
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RegistrationPage.id, (route) => false);
                  },
                  child: Text("Don\'t have an account, sign up here"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

