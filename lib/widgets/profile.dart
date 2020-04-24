import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ngouser/widgets/username.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final String email;
  final String phNo;
  final cam;
  ProfilePage(this.username, this.email, this.phNo, this.cam);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String uid;
  @override
  void initState() {
    getInfo();
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  void getInfo() async {
    this.uid = '';
    FirebaseAuth.instance.currentUser().then((val) {
      setState(() {
        this.uid = val.uid;
      });
    }).catchError((e) {
      print(e);
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Firestore _firestore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: Text("           My Profile"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 2,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                colors: [Colors.blue[900], Colors.blue[100]],
                begin: FractionalOffset.topLeft,
                end: FractionalOffset.bottomLeft,
                tileMode: TileMode.clamp,
              ))),
              Center(
                //alignment: Alignment.center,
                child: Container(
                  color: Colors.white70,
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.58,
                ),
              ),
              Center(
                child: Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.3,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/images/Profile.jpg'),
                                fit: BoxFit.cover),
                          ),
                        ),
                      ],
                    )),
              ),
              Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 3.4,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2.7,
                      height: MediaQuery.of(context).size.height / 5.3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage('assets/images/User.png'),
                            fit: BoxFit.fill),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      // margin: EdgeInsets.all(),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: ListTile(
                          dense: true,
                          trailing: IconButton(
                            icon: Icon(
                              Icons.edit,
                              size: 20,
                            ),
                            onPressed: () {
                              // Navigator.of(context).pushReplacementNamed('/username');
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (cox) => new UserName(
                                          widget.phNo, widget.cam)));
                            },
                          ),
                          leading:
                              Icon(Icons.person, size: 30, color: Colors.black),
                          title: Text(
                              "  " +
                                  widget.username.substring(
                                      0, widget.username.indexOf("!")),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontFamily: 'Lato')),
                        ),
                      ),
                    ),
                    //SizedBox(height: MediaQuery.of(context).size.height / 50),
                    Card(
                      margin: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      // margin: EdgeInsets.all(),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: ListTile(
                          trailing: IconButton(
                            icon: Icon(
                              Icons.edit,
                              size: 20,
                            ),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (cox) =>
                                      new UserName(widget.phNo, widget.cam),
                                ),
                              );
                            },
                          ),
                          dense: true,
                          leading:
                              Icon(Icons.email, size: 30, color: Colors.black),
                          title: Text("  " + widget.email,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontFamily: 'Lato')),
                        ),
                      ),
                    ),
                    //SizedBox(height: MediaQuery.of(context).size.height / 50),
                    Card(
                      margin: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      // margin: EdgeInsets.all(),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.phone,
                            size: 30,
                            color: Colors.black,
                          ),
                          title: Text("  " + widget.phNo,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontFamily: 'Lato')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      /*      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height / 12,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width / 4,
              ),
              CircleAvatar(
                radius: MediaQuery.of(context).size.height / 8,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black38, size: 150),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 12),
          
          SingleChildScrollView(
                                  child: Column(
                    children: <Widget>[
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        margin: EdgeInsets.all(20),
                        child: ListTile(
                          leading: Icon(
                            Icons.person,
                            size: 40,
                          ),
                          title: Text(
                              "  " +
                                  widget.username
                                      .substring(0, widget.username.indexOf("!")),
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                              )),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 50),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        margin: EdgeInsets.all(20),
                        child: ListTile(
                          leading: Icon(
                            Icons.mail,
                            size: 40,
                          ),
                          title: Text(
                            "  " + widget.email,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 50),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        margin: EdgeInsets.all(20),
                        child: ListTile(
                          leading: Icon(
                            Icons.phone,
                            size: 40,
                          ),
                          title: Text(
                            "  " + widget.phNo,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
        ],
      ),*/
    );
  }
}
