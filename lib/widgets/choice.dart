import 'dart:ui';
import 'package:ngouser/widgets/loading_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:splashscreen/splashscreen.dart';

import 'CircularButton.dart';
/**Here will be choice between user and NGO */

import 'package:flutter/material.dart';

import 'login.dart';

double _sigmaX = 3.0; // from 0-10
double _sigmaY = 3.0; // from 0-10

class choice extends StatefulWidget {
  @override
  _choiceState createState() => _choiceState();
}

class _choiceState extends State<choice> {
  //userLogin() is a function just to open login page and doesn't actually log in
  bool showSpinner = false;
  void userLogin() {
    //Navigator.pushReplacementNamed(context, '/login');
    Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child:null
              /*SplashScreen(
            seconds: 4,
            navigateAfterSeconds: new login(),
            backgroundColor: Theme.of(context).primaryColor,
            image: Image.asset('assets/images/load.gif'),
            photoSize: 100,
          ),*/
            //  Load('/login',5),
        ));
  }

  /*void userSignup() {
   // Navigator.of(context).
    
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/ChoiceFinal.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.end  ,
              children: <Widget>[
                Container(
                  height: 160,
                ),
                Container(
                  child: Text(
                    "Welcome",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lato',
                      fontSize: 55,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: 6,
                ),
                Container(
                  child: Text(
                    'Sign-in to continue',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                /* Center(
                  child: CustomButton('Sign up', userSignup),
                ),*/
                Container(
                  height: 100,
                ),
                Center(
                  child: CustomButton(
                      'Sign in with phone number', userLogin, Icons.phone),
                ),
                Container(
                  height: 10,
                ),
                //CustomButton('Sign in with email',(){} ,Icons.email)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
