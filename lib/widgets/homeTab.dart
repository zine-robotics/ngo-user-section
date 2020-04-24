import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeTab extends StatefulWidget {
  final uid;

  HomeTab(this.uid);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  //ScrollController scrollController = new ScrollController();
  ScrollController scrollController = ScrollController(
    initialScrollOffset: 30,
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('requests')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData == null) {
                  return CircularProgressIndicator();
                } 
                else {
                  List<DocumentSnapshot> docs = snapshot.data.documents;
                  List<Widget> requests = docs.map((doc) {
                    Requests(
                      doc.data['latitude'],
                      doc.data['longitude'],
                      doc.data['img'],
                      doc.data['date'],
                    );
                  }).toList();
                  //scrollController.animateTo(scrollController.position.maxScrollExtent,
                  //  duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                  return ListView(
                    key: ValueKey<int>(
                        Random(DateTime.now().millisecondsSinceEpoch)
                            .nextInt(4294967296)),
                    scrollDirection: Axis.vertical,
                    //shrinkWrap: true,
                    //controller: scrollController,
                    children: <Widget>[
                      ...requests,
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Requests extends StatelessWidget {
  final latitude, longitude, date, img;

  Requests(this.latitude, this.longitude, this.img, this.date);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(50),
      child: Card(
        margin: EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                /*FittedBox(child: Text('Latitude:${latitude}')),
                FittedBox(child: Text('Latitude:${longitude}')),
                FittedBox(child: Text('Time: ' + date)),
                */
              ],
              crossAxisAlignment: CrossAxisAlignment.end,
            )
          ],
        ),
      ),
    );
  }
}
