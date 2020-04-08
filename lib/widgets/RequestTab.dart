//import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

bool me;
String uidg;
class RequestTab extends StatefulWidget {
  final uid;

  RequestTab(this.uid);
   
  @override
  _RequestTabState createState() => _RequestTabState();
}

class _RequestTabState extends State<RequestTab> {
  //ScrollController scrollController = new ScrollController();
  //ScrollController scrollController = ScrollController(
  //initialScrollOffset: 30,
  //);
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    uidg=widget.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('requests')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData == null) {
          return SizedBox(
            child: Center(child: CircularProgressIndicator()),
            height: 20,
            width: 20,
          );
        }
        List<DocumentSnapshot> docs = snapshot.data.documents;

        /*List<Widget> requests = docs.map((doc) {
          Requests(doc.data['latitude'], doc.data['longitude'], doc.data['img'],
              doc.data['date']);
        }).toList();*/
        return ListView.builder(
            itemCount: getItems(context, snapshot.data.documents).length,
            itemBuilder: (context, index) {
              return getItems(context, snapshot.data.documents)[index];
            });
      },
    );
  }
}

List<Widget> getItems(BuildContext context, List<DocumentSnapshot> docs) {
  return docs.map((doc) {
    String latitude, longitude, date, instructions, status, landmark;
    latitude = doc.data['latitude'].toString();
    longitude = doc.data['longitude'].toString();
    date = doc.data['date'].toString();
    instructions = doc.data['instructions'].toString();
    status = doc.data['status'].toString();
    landmark = doc.data['landmark'].toString();
    me=(uidg==doc.data['user_id']);

    return me?Card(
      child: Row(
        children: <Widget>[
          //CircleAvatar(radius:25 ,child: ,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Latitude:' + latitude),
              Text('Longitude:' + longitude),
              Text("Date Uploaded:" + date),
              Text("Instructions:" + instructions),
              Text("Landmark:" + landmark),
              Text("Status:" + status),
            ],
          ),
        ],
      ),
    ):Container();
  }).toList();
}
/*
class Requests extends StatelessWidget {
  final latitude, longitude, date, img;

  Requests(this.latitude, this.longitude, this.img, this.date);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6),
      child: Card(
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                FittedBox(child: Text('Latitude:${latitude}')),
                FittedBox(child: Text('Latitude:${longitude}')),
                FittedBox(child: Text('Time:${date}')),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            )
          ],
        ),
      ),
    );
  }
}
*/
