import 'dart:ui';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:camera/new/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ngouser/widgets/homepage.dart';
import 'package:page_transition/page_transition.dart';
import './Constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserName extends StatefulWidget {
  final String phNo;final  cam;
  UserName(this.phNo,this.cam);
  @override
  _usernameState createState() => _usernameState();
}

class _usernameState extends State<UserName> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
   bool showSpinner=false;
   bool enabled = true;
  //snapshots=_firestore.collection('requests').snapshots();
  
  String username, uid;
  @override
  void initState() {
    this.uid = '';
    FirebaseAuth.instance.currentUser().then((val) {
      setState(() {
        this.uid = val.uid;
      });
    }).catchError((e) {
      print(e);
    });
    super.initState();
  }

  TextEditingController usernameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  Future addUser() async {
      setState(() {
        enabled = false;
            showSpinner=true;

          });
    if (emailController.text.contains('@') &&
        emailController.text.endsWith('.com') && usernameController.text.isNotEmpty) {
         
      await _firestore.collection(this.uid).add(
        {
          //'user_id': this.uid.toString(),
          'username': usernameController.text.toString(),
          'email': emailController.text.toString(),
          'date': DateTime.now(),
          'phone': widget.phNo.toString(),
        },
        
      );
      /*Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => Load('/homepage', 4)));*/
      Navigator.of(context).pop();
      Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: homepage(null,  null,widget.cam,null,null,null,null,false,false,false,false,false,false),
          ));
    } else if((emailController.text.contains('@') &&
        emailController.text.endsWith('.com'))==false) {
          setState(() {
            enabled = true;
            showSpinner=false;
          });
      Fluttertoast.showToast(
          msg: 'Please enter a valid email',
          textColor: Colors.red,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT);
    }
    else {
      setState(() {
            enabled = true;
            showSpinner=false;
          });
      Fluttertoast.showToast(
          msg: 'Please enter username',
          textColor: Colors.red,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool email = false;
    return ModalProgressHUD(
           inAsyncCall: showSpinner,
          child: SafeArea(
            child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
                  children:<Widget>[
                    Container(
               child: Image.asset(
              'assets/images/ChoiceFinal.jpg',
              fit: BoxFit.cover,
             // height: MediaQuery.of(context).size.height,
              height: double.infinity,
                width: double.infinity,
            )),
            ListView(
              children: <Widget>[
                Container(
                  color: Colors.transparent,
                    padding: EdgeInsets.all(20),
                  child: Column(
                      children: <Widget>[
                        SizedBox(height: 100),
                        
                        Text(
                          "Tell us more about yourself",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Lato',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(20,5,20,5),
                          //margin: EdgeInsets.all(10),
                          child: TextField(
                            enabled: enabled,
                            textAlign: TextAlign.center,
                            controller: usernameController,
                            cursorColor: Colors.white,
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            //keyboardType: TextInputType.number,
                            decoration: kInputFieldDecoration.copyWith(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              hintText: "Full Name",
                              //  fillColor: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(20,5,20,5),
                         // margin: EdgeInsets.all(10),
                          child: TextField(
                            keyboardType: TextInputType.emailAddress,
                            enabled: enabled,
                            onChanged: (str) {
                              print(str);
                              if (str.contains('@') && str.endsWith('.com')) {
                                setState(() {
                                  email = false;
                                });
                              } else {
                                setState(() {
                                  email = true;
                                });
                              }
                            },
                            textAlign: TextAlign.center,
                            controller: emailController,
                            cursorColor: Colors.white,
                            onEditingComplete: () {
                              if (emailController.text.contains('@') &&
                                  emailController.text.endsWith('.com')) {
                                setState(() {
                                  email = false;
                                });
                              } else {
                                setState(() {
                                  email = true;
                                });
                              }
                            },
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            //keyboardType: TextInputType.number,
                            decoration: kInputFieldDecoration.copyWith(
                              labelText: email ? 'Please enter a valid email id' : null,

                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Icon(
                                  Icons.email,
                                  color: Colors.white,
                                ),
                              ),
                              hintText: "Email ID",
                              
                              //  fillColor: Colors.black,
                            ),onSubmitted: (val){FocusScope.of(context).unfocus();
                              addUser();
                            },
                          ),
                        ),
                        email
                            ? Text(
                                'Please enter a valid email',
                                style: TextStyle(color: Colors.red, fontFamily: 'Lato'),
                              )
                            : Container(),
                            SizedBox(
                              height: 15,
                              //height : MediaQuery.of(context).size.height/33
                            ),
                            RoundedButton(onPressed: addUser,text: 'Done',usernameController: usernameController,emailController: emailController,),
                        /*RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          disabledColor: Colors.transparent,
                          disabledTextColor: Colors.transparent,
                          disabledElevation: 0,
                          color: Colors.green,
                          child: Text(
                            'Done',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: (usernameController.text != null &&
                                        emailController.text != null)
                                    ? Colors.white
                                    : Colors.transparent),
                          ),
                          onPressed: addUser,
                          
                        ),*/
                      ],
                    ),
                ),
              ],
            ),]
              ),
        ),
      ),
    );
  }
}
class RoundedButton extends StatelessWidget {
  RoundedButton({@required this.onPressed, this.text,this.usernameController,this.emailController});
  final String text;
  final Function onPressed;
 //final Function onPressed;
  final TextEditingController usernameController,emailController;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Material(
        elevation: 5.0,
        color: Colors.green,
        borderRadius: BorderRadius.circular(32.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 400,
          height: 42.0,
          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}