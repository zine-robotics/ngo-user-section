import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:camera/new/src/support_android/camera.dart';
/**Logging in to firebase using phone number and OTP */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ngouser/widgets/username.dart';
import 'package:page_transition/page_transition.dart';

import './Constants.dart';
import 'homepage.dart';

class login extends StatefulWidget {
  final cam;
  
  //login(this.cam);
  login(this.cam);
  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;
  bool showSpinner = false;
  double _sigmaX = 3.0; // from 0-10
  double _sigmaY = 3.0; // from 0-10

  final TextEditingController phoneController = new TextEditingController();

  final TextEditingController passwordController = new TextEditingController();

  final TextEditingController OTP = new TextEditingController();
  bool _otpField = false, _otpButton = false, _verifyButton = false;

  String number, otp, verId;
  bool newUser;

  Future<void> verify() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verId = verId;
    };
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verId = verId;
      Fluttertoast.showToast(
          msg: "OTP sent!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          fontSize: 20);
    };
    final PhoneVerificationCompleted verificationSuccess =
        (AuthCredential credential) {
       setState((){
showSpinner = true;
          });
          

      FirebaseAuth _auth = FirebaseAuth.instance;

      _auth.signInWithCredential(credential).then((user) {
      newUser = user.additionalUserInfo.isNewUser;
      
      setState(() {
         showSpinner = false;
      });
      if(newUser==true){
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: UserName(phoneController.text, widget.cam)));}
      else{
          Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: homepage(null,  null,widget.cam,null,null,null,null,false,false,false,false,false,false),
          ));

        // Navigator.push(context,'/username');
        Fluttertoast.showToast(
            msg: "Log in successful!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 20);
      }}).catchError((e) {
        print(e);
        Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            fontSize: 20);
      });
      // print('verified');
    };
    //final PhoneVerificationCompleted fe=(FirebaseUser u
    final PhoneVerificationFailed verificationFailed =
        (AuthException exception) {
      print('${exception.message}');
      Fluttertoast.showToast(
          msg: exception.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          fontSize: 20);
    };
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.number,
        timeout: const Duration(seconds: 120),
        verificationCompleted: verificationSuccess,
        verificationFailed: verificationFailed,
        codeSent: smsCodeSent,
        codeAutoRetrievalTimeout: autoRetrieve);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      //resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: Stack(children: <Widget>[
            Container(
                child: Image.asset(
              'assets/images/register.png',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            )),
            ListView(children: <Widget>[
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    Hero(
                      tag: 'welcome',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          "Welcome",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Lato',
                            fontSize: 55,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 15,
                    ),
                    Container(
                      child: Text(
                        'Sign-in to continue',
                        textAlign: TextAlign.center,
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

                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: phoneController,
                        cursorColor: Colors.white,
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        keyboardType: TextInputType.number,
                        decoration: kInputFieldDecoration.copyWith(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Icon(
                                Icons.phone,
                                color: Colors.white,
                              ),
                            ),
                            hintText: "Enter Phone No."),
                        /* InputDecoration(
              hintStyle: TextStyle(color: Colors.white),
              icon: Icon(Icons.phone, color: Colors.white),
              hintText: 'Enter Phone Number',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(30),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(30),
              ),
              border: new OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(30.0),
                ),
              ),
              //fillColor: Theme.of(context).primaryColor,
              //filled: true,
                      ),*/
                        onChanged: (txt) {
                          if (txt.length == 10) {
                            setState(() {
                              number = '+91' + txt;
                              _otpButton = true;
                            });
                          } else {
                            setState(() {
                              _otpButton = false;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: MaterialButton(
                        //padding: EdgeInsets.fromLTRB(50, 5, 50, 5),
                        minWidth: 400,
                        height: 42,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        disabledColor: Colors.transparent,
                        disabledTextColor: Colors.transparent,
                        disabledElevation: 0,
                        color: Colors.green,
                        child: Text(
                          'Send OTP',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: _otpButton
                                  ? Colors.white
                                  : Colors.transparent),
                        ),
                        onPressed: _otpButton
                            ? () {
                                number = '+91' + phoneController.text;
                                verify();
                                setState(() {
                                  _otpField = true;
                                  _verifyButton = true;
                                });
                              }
                            : null,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    _verifyButton
                        ? Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(10),
                            child: TextField(
                              textAlign: TextAlign.center,
                              cursorColor: Colors.white,
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: kInputFieldDecoration.copyWith(
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Icon(
                                      Icons.security,
                                      color: Colors.white,
                                    ),
                                  ),
                                  hintText: "Enter OTP"),
                              /*InputDecoration(
                    //fillColor: Theme.of(context).primaryColor,filled: true,
                    hintText: 'Enter OTP',
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    icon: Icon(Icons.security, color: Colors.white),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),*/

                              enabled: _otpField,
                              controller: OTP,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              onSubmitted: (txt) => signIn(),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: MaterialButton(
                        minWidth: 400,
                        height: 42,
                        elevation: 5,
                        //padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        disabledColor: Colors.transparent,
                        disabledTextColor: Colors.transparent,
                        disabledElevation: 0,
                        color: Colors.green,
                        child:
                            Text(
                          'Verify',
                          style: TextStyle(
                            color:
                                _verifyButton ? Colors.white : Colors.transparent,
                            fontSize: 18,
                          ),
                        ),
                        
                         /*  StreamBuilder<QuerySnapshot>(
                                stream: _firestore
                                    .collection(this.uid)
                                    .orderBy('date', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  print(this.uid);
                                  if (snapshot.hasData == null) {
                                    print("New User");
                                    return Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: _verifyButton
                                            ? Colors.white
                                            : Colors.transparent,
                                        fontSize: 18,
                                      ),
                                    );
                                  }else{
                                    print("Old User");
                                  return Text(
                                      'Login',
                                      style: TextStyle(
                                        color: _verifyButton
                                            ? Colors.white
                                            : Colors.transparent,
                                        fontSize: 18,
                                      ),
                                    );}
                                }),*/
                        onPressed: _verifyButton
                            ? () {
                                signIn();
                                // print(phoneController.text);
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Future signIn() async {
    setState(() {
      showSpinner = true;
    });

    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verId,
      smsCode: OTP.text,
    );
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.signInWithCredential(credential).then((user) {
      newUser = user.additionalUserInfo.isNewUser;
      
      
      setState(() {
         showSpinner = false;
      });
      if(newUser==true){
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: UserName(phoneController.text, widget.cam)));}
      else{
          Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: homepage(null,  null,widget.cam,null,null,null,null,false,false,false,false,false,false),
          ));

      }        
      // Navigator.push(context,'/username');
      Fluttertoast.showToast(
          msg: "Log in successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 20);
    }).catchError((e) {
      setState(() {
        showSpinner = false;
      });

      print(e);
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          fontSize: 20);
    });
  }
}