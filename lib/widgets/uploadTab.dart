//import 'dart:html';

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:ngouser/widgets/takePicture.dart';
import 'package:location/location.dart';

String locationTest;

class uploadTab extends StatefulWidget {
  var img;
  String location;
  final uid;
  final initialPage;
  LocationData _locationData;
  uploadTab(this.img, this.location, this.initialPage, this.uid);
  @override
  _uploadTabState createState() => _uploadTabState();
}

class _uploadTabState extends State<uploadTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  Future<void> _upload() async {
    await _firestore.collection('requests').add(
      {
        'location': widget._locationData.toString(),
        'latitude': widget._locationData.latitude,
        'longitude': widget._locationData.longitude,
        'date': DateTime.now().toIso8601String().toString(),
        'img':widget.uid.toString()+'/'+DateTime.now().toIso8601String(),
        'user_id': widget.uid,
        'landmark':_landmark.text.toString(),
        'instructions':_instructions.text.toString(),
        'status':'P',
      },
    );
    Fluttertoast.showToast(msg:'Entries added!',gravity: ToastGravity.BOTTOM,fontSize: 20,toastLength: Toast.LENGTH_SHORT);
    var filename = 'Images/'+widget.uid+'/'+DateTime.now().toIso8601String();
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(filename);
    final StorageUploadTask task = firebaseStorageRef.putFile(File(widget.img));
    Fluttertoast.showToast(msg:'Image uploaded!',gravity: ToastGravity.BOTTOM,fontSize: 20,toastLength: Toast.LENGTH_SHORT);
    setState(() {
      widget.location=null;
    widget.img=null;
    _landmark.clear();
    _instructions.clear();
    });
  }

  Future<void> _addLocation() async {
    //locationTest=null;
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    widget._locationData = await location.getLocation();
    print(widget._locationData);
    if (widget._locationData != null)
      setState(() {
        //locationTest=widget._locationData.toString();
        widget.location = widget._locationData.toString();
      });

    /**  location.onLocationChanged.listen((LocationData currentLocation) {
  // Use current location
});*/
  }

  void _addImage() {
    //widget.location==null;
    //Navigator.pushReplacementNamed(context, '/takePicture');
    Navigator.pushNamed(context, '/takePicture');
  }

  final TextEditingController _landmark = new TextEditingController();
  final TextEditingController _instructions = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    //locationTest=null;
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(hintText: 'Landmark'),
            controller: _landmark,
          ),
          SizedBox(
            height: 4,
          ),
          TextField(
            decoration: InputDecoration(
              hintText: 'Instructions',
            ),
            controller: _instructions,
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add_a_photo),
                onPressed: _addImage,
                iconSize: 34,
              ),
              IconButton(
                icon: Icon(Icons.add_location),
                onPressed: _addLocation,
                iconSize: 34,
              )
            ],
          ),
          widget.location == null
              ? Text(
                  'Please upload a location',
                  style: TextStyle(color: Colors.red),
                )
              : Text(
                  'Latitude:${widget._locationData.latitude}, Longitude:${widget._locationData.longitude}'),
          SizedBox(
            height: 3,
          ),
          widget.img == null
              ? Text(
                  'Please upload an image',
                  style: TextStyle(color: Colors.red),
                )
              : Text(
                  'Pic uploaded successfully!',
                  style: TextStyle(color: Colors.blue),
                ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              RaisedButton(
                onPressed: _upload,
                child: Text('Upload'),
              )
            ],
          ),
          //SizedBox(child:Image.file(File(widget.img)),height: 200,width: 300,),
          widget.img == null
              ? Container()
              : Expanded(
                  child: Container(
                    margin: EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text('Uploaded Pic-'),
                          ],
                        ),
                        //SizedBox(child:Image.file(File(widget.img)),height: 200,width: 300,),
                        Expanded(
                          child: Image.file(File(widget.img)),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
