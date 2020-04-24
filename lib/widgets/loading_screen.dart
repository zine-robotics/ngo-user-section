import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ngouser/widgets/username.dart';
import 'package:page_transition/page_transition.dart';

import 'homepage.dart';

String username, email;
var phone1, cam1;
bool user = false;

class Load extends StatefulWidget {
  final seconds;
  //String username, email;
  final phone, cam;
  Load(this.seconds, this.phone, this.cam);
  @override
  _LoadState createState() => _LoadState();
}

void getinfo(context, uid) {
  // FirebaseAuth _auth = FirebaseAuth.instance;
  // Firestore _firestore = Firestore.instance;
}

Firestore _firestore = Firestore.instance;

class _LoadState extends State<Load> {
  String uid;
  void uida() async{
    FirebaseAuth.instance.currentUser().then((val) {
      this.uid = val.uid;
    }).catchError((e) {
      print(e);
    });
  }
  @override
  void initState() {
    uida();
    phone1 = widget.phone;
    cam1 = widget.cam;
    // getinfo(context,uid);
    Future.delayed(Duration(seconds: widget.seconds), () {
      // Navigator.of(context).pushReplacementNamed(widget.screen);
      user
          ? Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: homepage(null, null, widget.cam, null, null, null, null,
                    false, false, false, false, false, false),
              ))
          : Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: UserName(widget.phone, widget.cam)));
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 100,
                width: 200,
                child: Center(
                  child: Image.asset('assets/images/load1.gif'),
                ),
              ),
            ],
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection(uid)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                //print(uid);
                if (snapshot.hasData == null) {
                  user = false;
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: UserName(widget.phone, widget.cam)));
                  return Text('nu');
                } else {
                  List<DocumentSnapshot> docs = snapshot.data.documents;
                  username = docs[0].data['username'];
                  print(username);

                  email = docs[0].data['email'].toString();

                  if (username.isEmpty || email.isEmpty) {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: UserName(widget.phone, widget.cam)));
                  } else {
                    user = true;
                    Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: homepage(null, null, widget.cam, null, null, null, null,
                    false, false, false, false, false, false),
              ));
                  }
                  return Text('na');
                }
              },
            ),
          ),
        ],
      )),
    );
  }
}
