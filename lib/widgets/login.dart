/**Logging in to firebase using phone number and OTP */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './homepage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class login extends StatefulWidget {
  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController phoneController = new TextEditingController();

  final TextEditingController passwordController = new TextEditingController();

  final TextEditingController OTP = new TextEditingController();
  bool _otpField = false, _otpButton = false,_verifyButton=false;

  String number, otp, verId;

  Future<void> verify() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verId = verId;
    };
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verId = verId;
    };
    final PhoneVerificationCompleted verificationSuccess =
        (AuthCredential user) {
      Fluttertoast.showToast(
          msg: "Verified!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          fontSize: 20);

      print('verified');
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
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationSuccess,
        verificationFailed: verificationFailed,
        codeSent: smsCodeSent,
        codeAutoRetrievalTimeout: autoRetrieve);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  hintText: 'Phone Number', border: OutlineInputBorder()),
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
            SizedBox(
              height: 4,
            ),
            RaisedButton(
              child: Text('Send OTP'),
              onPressed: _otpButton
                  ? () {
                      number = '+91' + phoneController.text;
                      verify();
                      setState(() {
                        _otpField = true;
                        _verifyButton=true;
                      });
                    }
                  : null,
            ),
            SizedBox(
              height: 4,
            ),
            TextField(
              decoration: InputDecoration(hintText: 'Enter OTP'),
              enabled: _otpField,
              controller: OTP,
              obscureText: true,
              keyboardType: TextInputType.number,
              onSubmitted: (txt) => signIn(),
            ),
            RaisedButton(
              child: Text('Verify'),
              onPressed: _verifyButton?() {
                signIn();
              }:null,
            ),
          ],
        ),
      ),
    );
  }

  Future signIn() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verId,
      smsCode: OTP.text,
    );
    FirebaseAuth _auth = FirebaseAuth.instance;

    final FirebaseUser user =
        await _auth.signInWithCredential(credential).then((user) {
      Navigator.pushReplacementNamed(context, '/homepage');
      Fluttertoast.showToast(
          msg: "Log in successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 20);
    }).catchError((e) {
      print(e);
      Fluttertoast.showToast(
          msg: "Invalid OTP",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          fontSize: 20);
    });
  }
}
