/**Here will be choice between user and NGO */

import 'package:flutter/material.dart';
import './login.dart';

class choice extends StatefulWidget {
  @override
  _choiceState createState() => _choiceState();
}

class _choiceState extends State<choice> {
  //userLogin() is a function just to open login page and doesn't actually log in
  void userLogin() {
    //Navigator.pushReplacementNamed(context, '/login');
    Navigator.pushNamed(context,'/login');
  }

  /*void userSignup() {
   // Navigator.of(context).
    
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NGO User'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.end  ,
        children: <Widget>[
          Center(
            child: Text(
              'User Log in with mobile number',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          /* Center(
            child: CustomButton('Sign up', userSignup),
          ),*/
          Center(
            child: CustomButton('Log In', userLogin),
          )
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback callback;
  final String text;

  CustomButton(this.text, this.callback);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.all(15),
      child: Material(
        borderRadius: BorderRadius.circular(30),
        elevation: 6,
        color: Colors.blueAccent,
        child: MaterialButton(
          onPressed: callback,
          child: Text(text),
          minWidth: 200,
          height: 45,
        ),
      ),
    );
  }
}
