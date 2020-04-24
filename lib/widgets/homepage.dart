import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ngouser/widgets/RequestTab.dart';
import 'package:ngouser/widgets/profile.dart';
import 'package:ngouser/widgets/uploadTab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngouser/widgets/uploadTab1.dart';
import 'package:page_transition/page_transition.dart';

class homepage extends StatefulWidget {
  var img, initialPage;
  bool bottom;
  var uid, initialLatitude, initialLongitude, landmark, pickedLocation;
  final cam;
  final bool food, clothes, women, medicine, children;
  String username = 'user', email='null', phone;
  homepage(
      this.img,
      this.initialPage,
      this.cam,
      this.initialLatitude,
      this.initialLongitude,
      this.landmark,
      this.pickedLocation,
      this.food,
      this.clothes,
      this.women,
      this.medicine,
      this.children,
      this.bottom);
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  TabController _tabController;

  String uid;

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 2);
    if (widget.initialPage != null) _tabController.animateTo(1);
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

  void _signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pop(context);
    //Navigator.popAndPushNamed(context,'/choice');
    Navigator.pushReplacementNamed(context, '/login');
    //Navigator.push(context, MaterialPageRoute(builder: (context) => choice()));

    //Navigator.of(context).pushReplacementNamed('/choice');
    // Navigator.popAndPushNamed(context, '/choice');
    // Navigator.of(context).pushNamedAndRemoveUntil('/homepage', (Route<dynamic> route) => false);
    // Navigator.popUntil(context,ModalRoute.withName('/homepage'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            Container(
              //color: Colors.grey,
              height:  MediaQuery.of(context).size.height,
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SafeArea(
                      child: Container(
                        height: MediaQuery.of(context).size.height / 3,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/Drawer.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _firestore
                                  .collection(uid)
                                  .orderBy('date', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                print(uid);
                                if (snapshot.hasData == null) {
                                  return Text('Hello, User');
                                } else {
                                  List<DocumentSnapshot> docs =
                                      snapshot.data.documents;
                                  print(docs[0].data['username']);

                                  if (docs[0]
                                      .data['username']
                                      .toString()
                                      .isNotEmpty) {
                                    widget.username =
                                        docs[0].data['username'] + '!';
                                  } else {
                                    widget.username = 'user !';
                                  }
                                  if (docs[0]
                                      .data['username']
                                      .toString()
                                      .isNotEmpty) {
                                    widget.email =
                                        docs[0].data['email'] ;
                                  } else {
                                    widget.email = 'null';
                                  }
                                  if (docs[0]
                                      .data['phone']
                                      .toString()
                                      .isNotEmpty) {
                                    widget.phone =
                                        docs[0].data['phone'] ;
                                  } else {
                                    widget.phone = 'null';
                                  }
                                  

                                  return Text(
                                    'Hello, ' + widget.username,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height/2,
                      child: ListView(children: <Widget>[
                        SizedBox(
                          height: 15,
                        ),
                        ListTile(
                          title: Text(
                            "Profile",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          leading: Icon(
                            Icons.account_box,
                            size: 40,
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                  child: ProfilePage(widget.username,
                                      widget.email, widget.phone,widget.cam),
                                  type: PageTransitionType.downToUp,
                                ));
                          },
                        ),
                        ListTile(
                          title: Text(
                            "Existing Requests",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          leading: Icon(
                            Icons.book,
                            size: 40,
                          ),
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, '/homepage');
                          },
                        ),
                        ListTile(
                          title: Text(
                            "Create New Request ",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          leading: Icon(
                            Icons.add_box,
                            size: 40,
                          ),
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => homepage(
                                        null,
                                        1,
                                        widget.cam,
                                        widget.initialLatitude,
                                        widget.initialLongitude,
                                        widget.landmark,
                                        widget.pickedLocation,
                                        widget.food,
                                        widget.clothes,
                                        widget.women,
                                        widget.medicine,
                                        widget.children,
                                        widget.bottom)));
                          },
                        ),
                        ListTile(
                          title: Text(
                            "Sign out",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.arrow_back,
                                size: 40,
                              ),
                            ],
                          ),
                          onTap: _signOut,
                        ),
                        SizedBox(
                          height: 80,
                        ),
                        Center(
                          child: Container(
                            child: Text("\u00A9 Sanjeevani"),
                          ),
                        ),
                      ]),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          indicatorWeight: 5,
          tabs: [
            Container(
                padding: EdgeInsets.only(top: 5),
                height: 60.0,
                child: Tab(
                  text: 'EXISTING',
                  icon: Icon(Icons.home),
                )),
            Container(
                padding: EdgeInsets.only(top: 5),
                height: 60.0,
                child: Tab(text: 'NEW', icon: Icon(Icons.add))),
          ],
        ),
        centerTitle: true,
        title: Text(
          'Sanjeevani',
          style: TextStyle(
            fontSize: 25,
            letterSpacing: 0.2,
            fontWeight: FontWeight.w100,
            fontFamily: 'Montserrat',
            color: Colors.white,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          //HomeTab(this.uid),
          //SizedBox(child: CircularProgressIndicator(),height:30 ,width: 30,),
          //HomeTab(this.uid),
          RequestTab(this.uid),
          UploadTab(
              widget.img,
              widget.initialPage,
              uid,
              widget.cam,
              widget.initialLatitude,
              widget.initialLongitude,
              widget.landmark,
              widget.pickedLocation,
              widget.food,
              widget.clothes,
              widget.women,
              widget.medicine,
              widget.children,
              widget.bottom),
        ],
      ),
    );
  }
}

class Requests extends StatefulWidget {
  final username;

  Requests(this.username);

  @override
  _RequestsState createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  @override
  Widget build(BuildContext context) {
    return null;
  }
}
