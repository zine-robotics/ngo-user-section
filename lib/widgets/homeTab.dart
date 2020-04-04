import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeTab extends StatefulWidget {
  final uid;
  HomeTab(this.uid);
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  ScrollController scrollController=new ScrollController();
  final Firestore _firestore = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore.collection('requests').orderBy('date').snapshots(),
              builder: (context, snapshot) {
                List<DocumentSnapshot> docs = snapshot.data.documents;
                List<Widget> requests = docs
                    .map((doc) {
                            Requests(
                                doc.data['latitude'],
                                doc.data['longitude'],
                                doc.data['img'],
                                doc.data['date']);
                        })
                    .toList();
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView(
                  controller: scrollController,
                  children: <Widget>[
                    ...requests,
                  ],
                );
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
      padding: EdgeInsets.all(6),
      child: Card(
        child: Row(
          children: <Widget>[
            CircleAvatar(
              child: Image.asset(img),
            ),
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
