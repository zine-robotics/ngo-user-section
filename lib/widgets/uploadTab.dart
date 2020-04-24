import 'dart:convert';
import 'dart:ui';
//import 'dart:html';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:ngouser/widgets/takePicture.dart';
import 'package:location/location.dart';
import 'package:ngouser/widgets/CircularButton.dart';
import 'package:ngouser/widgets/takePicture.dart';
import './map_screen.dart';
import 'Constants.dart';

String locationTest;

class uploadTab extends StatefulWidget {
  var img;
  bool food = false,
      clothes = false,
      medicine = false,
      women = false,
      children = false;
  bool instruct = false;

  String location;
  final uid;
  final initialPage;
  LocationData _locationData;
  uploadTab(this.img, this.location, this.initialPage, this.uid);
  @override
  _uploadTabState createState() => _uploadTabState();
}

class _uploadTabState extends State<uploadTab> {
  LatLng selectedLocation;
  String address;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  Future<void> _entriesUp() async {}

  Future<void> _upload() async {
    var filename =
        'Images/' + widget.uid + '/' + DateTime.now().toIso8601String();
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(filename);
    final StorageUploadTask task = firebaseStorageRef.putFile(File(widget.img));
    var dowurl = await (await task.onComplete).ref.getDownloadURL();
    String url = dowurl.toString();
    await _firestore.collection('requests').add(
      {
        'location': widget.location.toString(),
        'latitude': selectedLocation.latitude,
        'longitude': selectedLocation.longitude,
        'date': DateTime.now().toIso8601String().toString(),
        'img': 'Images/' +
            widget.uid.toString() +
            '/' +
            DateTime.now().toIso8601String(),
        'user_id': widget.uid,
        'landmark': _landmark.text.toString(),
        'instructions': _instructions.text.toString(),
        'status': 'Pending',
        'download_url': url,
        'address': address,
        'food': widget.food,
        'clothes': widget.clothes,
        'medicine': widget.medicine,
        'women': widget.women,
        'children': widget.children
      },
    );
    Fluttertoast.showToast(
        msg: 'Entries added!',
        gravity: ToastGravity.BOTTOM,
        fontSize: 20,
        toastLength: Toast.LENGTH_SHORT);

    Fluttertoast.showToast(
        msg: 'Image uploaded!',
        gravity: ToastGravity.BOTTOM,
        fontSize: 20,
        toastLength: Toast.LENGTH_SHORT);
    setState(() {
      selectedLocation = null;
      widget.img = null;
      _landmark.clear();
      _instructions.clear();
    });
  }

  Future<String> convertCoordinates(double lat, double long) async {
    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$long%2C%20$lat.json?access_token=pk.eyJ1IjoiZGFyc2hhbmR1c2FkIiwiYSI6ImNrOTAwYWlsdDBqaDMzZGxjM3licmhtZmUifQ.5Xce1SxAs7VJv7ZaFVA8oA';
    final response = await http.get(url);
    return json.decode(response.body)['features'][0]['place_name'];
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
    selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => MapScreen(
          initialLatitude: widget._locationData.latitude,
          initialLongitude: widget._locationData.longitude,
          isSelecting: true,
        ),
      ),
    );
    // print(selectedLocation.latitude);
    if (selectedLocation == null) {
      print("Null");
      return;
    } else {
      widget.location = selectedLocation.toString();

      var address1 = await convertCoordinates(
          selectedLocation.latitude, selectedLocation.longitude);
      setState(() {
        address = address1;
      });
      _landmark.text = address;

      print(selectedLocation.latitude);
      print(selectedLocation.longitude);

      if (address == null) {
        print('null');
      } else {
        print(address);
      }
    }
    /* print(widget._locationData);
    if (widget._locationData != null)
      setState(() {
        //locationTest=widget._locationData.toString();
        widget.location = widget._locationData.toString();
      });*/

    /**  location.onLocationChanged.listen((LocationData currentLocation) {
  // Use current location
});*/
  }

  void _addImage() async {
    //widget.location==null;
    Navigator.pushReplacementNamed(context, '/takePicture');
    //widget.img = await Navigator.pushNamed(context, '/takePicture');
    //print(widget.img);
    //setState(() {
    // widget.img = widget.img;
    //});
    //Navigator.of(context).push(new MaterialPageRoute(builder: (context)=> new TakePictureScreen(widget.cam, address)));
  }

  //PersistentBottomSheetController _controller; // <------ Instance variable
  //final _scaffoldKey = GlobalKey<ScaffoldState>(); // <---- Anothe
  void category(context) async {
    //_controller=_scaffoldKey.currentState.sh
    //_controller = await _scaffoldKey.currentState.showBottomSheet(
    //context,
    //context: context,

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext ctx, StateSetter setModalState) {
          return Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: CheckboxListTile(
                    value: widget.food,
                    title: Text('Food'),
                    onChanged: (val) {
                      setState(() {
                        widget.food = val;
                      });

                      setModalState(() {
                        widget.food = val;

                        // widget.food = !widget.food;
                      });
                    },
                  ),
                ),
                Container(
                  child: CheckboxListTile(
                    value: widget.medicine,
                    title: Text('Medicine'),
                    onChanged: (val) {
                      setModalState(() {
                        widget.medicine = !widget.medicine;
                      });
                    },
                  ),
                ),
                Container(
                  child: CheckboxListTile(
                    value: widget.women,
                    title: Text('Women'),
                    onChanged: (val) {
                      setModalState(() {
                        widget.women = !widget.women;
                      });
                    },
                  ),
                ),
                Container(
                  child: CheckboxListTile(
                    value: widget.clothes,
                    title: Text('Clothes'),
                    onChanged: (val) {
                      setModalState(() {
                        widget.clothes = !widget.clothes;
                      });
                    },
                  ),
                ),
                Container(
                  child: CheckboxListTile(
                    value: widget.children,
                    title: Text('Children'),
                    onChanged: (val) {
                      setModalState(() {
                        widget.children = !widget.children;
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _delete() {
    setState(() {
      widget.img = null;
    });
  }

  final TextEditingController _landmark = new TextEditingController();
  final TextEditingController _instructions = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    //locationTest=null;
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30),
            //address != null ? Text(address) : Container(),
            Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  child: TextField(
                    //enabled: false,
                    readOnly: true,
                    //enabled: false,
                    textAlign: TextAlign.start,
                    textDirection: TextDirection.ltr,
                    controller: _landmark,
                    cursorColor: Colors.white,
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    keyboardType: TextInputType.text,
                    decoration: kInputFieldDecoration.copyWith(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Icon(
                          Icons.location_city,
                          color: Colors.white,
                        ),
                      ),
                      hintText: "   Address",
                      hintStyle: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Lato',
                        color: Colors.white,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.5),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_location,
                    color: Colors.white
                  ),
                  onPressed: _addLocation,
                  iconSize: 35,
                ),
              ],
            ),

            SizedBox(
              height: 15,
            ),
            TextField(
              textAlign: TextAlign.start,
              readOnly: widget.instruct,
              onTap: () {
                setState(() {
                  widget.instruct = true;
                });
              },
              minLines: 1,
              maxLines: 3,
              controller: _instructions,
              cursorColor: Colors.white,
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              keyboardType: TextInputType.multiline,
              decoration: kInputFieldDecoration.copyWith(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Icon(
                    Icons.add_comment,
                    color: Colors.white,
                  ),
                ),
                hintText: "   Additional Instructions",
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Lato',
                  fontSize: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.5),
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
              ),
            ),
            SizedBox(height: 15),
            /*Padding(
              padding: EdgeInsets.all(5),
              child: Material(
                elevation: 6,
                color: Colors.lightBlueAccent,
                child: MaterialButton(
                  onPressed: _addImage,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.camera_alt),
                      Container(
                        width: 20,
                      ),
                      Text(
                        "Add a Photo",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  minWidth: 125,
                  height: 35,
                ),
              ),
            ),*/

            /*Padding(
              padding: EdgeInsets.all(5),
              child: Material(
                elevation: 6,
                color: Colors.lightBlueAccent,
                child: MaterialButton(
                  onPressed: _addLocation,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.location_on),
                      Container(
                        width: 20,
                      ),
                      Text(
                        "Add a Location",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  minWidth: 125,
                  height: 35,
                ),
              ),
            ),*/
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Material(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.teal,
                    child: MaterialButton(
                      child: Text('Select Category',
                      style: TextStyle(
                        fontFamily: 'Lato'
                      ),
                      ),
                      onPressed: widget.img != null && address != null
                          ? () {
                              category(context);
                              setState(() {
                                widget.instruct = true;
                              });
                            }
                          : null,
                          minWidth: 200,
                    ),
                  ),
                  //CustomButton('Select category', category, Icons.category),
                  // IconButton(icon: Icon(Icons.category),onPressed: category,color: Colors.black,iconSize: 35,)
                ],
              ),
            ),
            /*Padding(
              padding: EdgeInsets.all(5),
              child: Material(
                elevation: 6,
                color: Colors.lightBlueAccent,
                child: MaterialButton(
                  onPressed: _addLocation,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.category),
                      Container(
                        width: 20,
                      ),
                      Text(
                        "Add a Category",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  minWidth: 125,
                  height: 35,
                ),
              ),
            ),*/
            /* address == null
                ? Text(
                    'Please upload a location',
                    style: TextStyle(color: Colors.red),
                  )
                : Text(
                    "lat : ${selectedLocation.latitude},long:${selectedLocation.longitude}"),
            SizedBox(
              height: 15,
            ),
            widget.img == null
                ? Text(
                    'Please upload an image',
                    style: TextStyle(color: Colors.red),
                  )
                : Text(
                    'Pic uploaded successfully!',
                    style: TextStyle(color: Colors.blue),
                  ),*/
            SizedBox(
              height: 15,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 220,
              //color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  DottedBorder(
                    color: Colors.white,
                    dashPattern: [10, 5],
                    strokeWidth: 1,
                    child: Container(
                        width: 300,
                        height: 300,
                        child: widget.img == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "No Image Uploaded",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: 'Lato'
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: _addImage,
                                    )
                                  ],
                                ),
                              )
                            : Image.file(File(widget.img))),
                  ),
                  widget.img != null
                      ? Container(
                        width: 20,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: _delete,
                                iconSize: 27,
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: _addImage,
                                iconSize: 27,
                              ),
                            ],
                          ),
                      )
                      : Container(),
                ],
              ),
            ),
            SizedBox(
              height:50
            ),
            //CustomButton('Upload',_upload,null),
            Center(
              child: Material(
                borderRadius: BorderRadius.circular(30),
                color: Colors.teal,
                child: MaterialButton(
                  onPressed: _upload,
                  child: 
                  Text('Upload',
                  style:TextStyle(
                    color : Colors.white,
                    fontFamily: 'Lato'
                  ),
                  ),
                  //color: Colors.teal,
                minWidth: 200,
                ),
              ),
            )
            //SizedBox(child:Image.file(File(widget.img)),height: 200,width: 300,),

            /*: Expanded(
                    child: Container(
                      margin: EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[],
                          ),
                          //SizedBox(child:Image.file(File(widget.img)),height: 200,width: 300,),
                          Expanded(
                            child: Image.file(File(widget.img)),
                          ),
                        ],
                      ),
                    ),
                  ),*/
          ],
        ),
      ),
    );
  }
}
