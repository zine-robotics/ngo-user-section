import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ngouser/widgets/takePicture.dart';

import 'Constants.dart';
import 'homepage.dart';

class UploadTab extends StatefulWidget {
  bool bottom;
  var land_test = '';
  bool food = false,
      clothes = false,
      medicine = false,
      women = false,
      children = false;

  var initialPage,
      uid,
      initialLatitude,
      initialLongitude,
      landmark,
      pickedLocation;
  var location;
  var img;
  final cam;
  UploadTab(
      this.img,
      this.initialPage,
      this.uid,
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

  bool isSelecting = false;
  @override
  _UploadTabState createState() => _UploadTabState();
}

class _UploadTabState extends State<UploadTab> {
  bool showSpinner =false;
  String address;
  Completer<GoogleMapController> _controller = Completer();
  double zoom;
  ScrollController vertical = new ScrollController();
  ScrollController horizontal = new ScrollController();
  ScrollController parent1 = new ScrollController();
  LocationData _locationData;
  TextEditingController _landmark = new TextEditingController();
  //_landmark.text=widget.landmark;
  TextEditingController _instructions = new TextEditingController();
  TextEditingController _address=new TextEditingController();
  LatLng selectedLocation;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  bool cur_loc = false, dif_loc = false;
  LatLng _pickedLocation;
  Future<void> _upload(var instructions, bool food, bool clothes, bool medicine,
      bool women, bool children) async {
    var filename =
        'Images/' + widget.uid + '/' + DateTime.now().toIso8601String();
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(filename);
    final StorageUploadTask task = firebaseStorageRef.putFile(File(widget.img));
    var dowurl = await (await task.onComplete).ref.getDownloadURL();
    String url = dowurl.toString();
    print(_pickedLocation == null
        ? widget.initialLatitude
        : _pickedLocation.latitude);
    print(_pickedLocation == null
        ? widget.initialLongitude
        : _pickedLocation.longitude);
    print(DateTime.now().toIso8601String().toString());
    print(_instructions.text.toString());
    print(_landmark.text.toString());
    await _firestore.collection('requests').add(
      {
        //'location': widget.location.toString(),
        'latitude': _pickedLocation == null
            ? widget.initialLatitude
            : _pickedLocation.latitude,
        'longitude': _pickedLocation == null
            ? widget.initialLongitude
            : _pickedLocation.longitude,
        'date': DateTime.now().toIso8601String().toString(),
        'img': 'Images/' +
            widget.uid.toString() +
            '/' +
            DateTime.now().toIso8601String(),
        'user_id': widget.uid,
        'address': _landmark.text.toString(),
        'lamdmark':_address.text.toString(),
        'instructions': _instructions.text.toString(),
        'status': 'Pending',
        'download_url': url,
        //'address': _landmark,
        'Food': food,
        'Clothes': clothes,
        'Medicine': medicine,
        'Women Care': women,
        'Children Care': children
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
    revert();

    //setup();
  }

  void revert() {
    Navigator.pushNamed(context, '/homepage');
    //setup();
  }

  Future setter() async {
    _landmark.text = await convertCoordinates(
        widget.initialLatitude, widget.initialLongitude);
  }

  @override
  void initState() {
    //if(widget.bottom==true)parent1.jumpTo(parent1.position.maxScrollExtent);
    //WidgetsBinding.instance
    //  .addPostFrameCallback((_) => (){if(widget.bottom==true)parent1.jumpTo(parent1.position.maxScrollExtent);});
    // SchedulerBinding.instance.addPostFrameCallback((_) =>(){});if(widget.bottom==true)parent1.jumpTo(parent1.position.maxScrollExtent);
    _landmark.text = widget.landmark;
    print(widget.pickedLocation);
    _pickedLocation = widget.pickedLocation;
    //if(cur_loc==false&&dif_loc==false){cur_loc=true;}
    if (_pickedLocation != null) {
      dif_loc = true;
    } else if (widget.initialLatitude != null) {
      cur_loc = true;
      setter();
    }

    setup();
    super.initState();
  }

  Future<String> convertCoordinates(double lat, double long) async {
    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$long%2C%20$lat.json?access_token=pk.eyJ1IjoiZGFyc2hhbmR1c2FkIiwiYSI6ImNrOTAwYWlsdDBqaDMzZGxjM3licmhtZmUifQ.5Xce1SxAs7VJv7ZaFVA8oA';
    final response = await http.get(url);
    return json.decode(response.body)['features'][0]['place_name'];
  }

  void selectLocation(LatLng position) async {
    setState(() {
      _pickedLocation = position;
    });
    _landmark.text = await convertCoordinates(
        _pickedLocation.latitude, _pickedLocation.longitude);
    setState(() {
      widget.land_test = _landmark.text;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Future<void> setup() async {
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
    _locationData = await location.getLocation();
    setState(() {
      widget.initialLatitude = _locationData.latitude;
      widget.initialLongitude = _locationData.longitude;
    });
    // TODO: implement initState
  }

  void _addImage() async {
    //widget.location==null;
    //Navigator.pushNamed(context, '/takePicture');
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new TakePictureScreen(
          widget.cam,
          widget.initialLatitude,
          widget.initialLongitude,
          _landmark.text.toString(),
          _pickedLocation,
          widget.food,
          widget.women,
          widget.clothes,
          widget.medicine,
          widget.children);
    }));
    //widget.img = await Navigator.pushNamed(context, '/takePicture');
    //print(widget.img);
    //setState(() {
    // widget.img = widget.img;
    //});
    //Navigator.of(context).push(new MaterialPageRoute(builder: (context)=> new TakePictureScreen(widget.cam, address)));
  }

  void _delete() {
    setState(() {
      widget.img = null;
    });
    Fluttertoast.showToast(
        msg: 'Please select another image',
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT);
  }

  void _settingModalBottomSheet(
      context, instructions, upload, food, clothes, medicine, women, children,_address) {
    showModalBottomSheet(
      isDismissible: true,
      backgroundColor: Colors.grey,
      elevation: 6,
      context: context,
      builder: (BuildContext bc) {
        return Scaffold(
          resizeToAvoidBottomPadding: false,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Details',
              //textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 20,
              ),
            ),
            backgroundColor: Colors.black,
            leading: Container(),
          ),
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter st) {
              return Container(
                decoration: BoxDecoration(
                    //  border: Border.all(width: 5),
                    ),
                padding: EdgeInsets.all(20),
                width: double.infinity,
                height: (MediaQuery.of(context).size.height / 2),
                child: Column(
                  children: <Widget>[
                    TextField(
                      enabled: true,
                      //maxLines: 3,
                      //minLines: 1,

                      //enabled: false,
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.ltr,
                      controller: _address,
                      cursorColor: Colors.black,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),

                      //keyboardType: TextInputType,
                      onSubmitted: (val) {
                        FocusScope.of(context).unfocus();
                      },
                      decoration: kInputFieldDecoration.copyWith(
                        prefixIcon: Icon(
                          Icons.assignment,
                          color: Colors.black,
                        ),
                        hintText: "Address(optional)",
                        hintStyle: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Lato',
                          color: Colors.black54,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2.5),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                      ),
                    ),
                    SizedBox(height: 15,),
                    TextField(
                      enabled: true,
                      //maxLines: 3,
                      //minLines: 1,

                      //enabled: false,
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.ltr,
                      controller: instructions,
                      cursorColor: Colors.black,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),

                      //keyboardType: TextInputType,
                      onSubmitted: (val) {
                        FocusScope.of(context).unfocus();
                      },
                      decoration: kInputFieldDecoration.copyWith(
                        prefixIcon: Icon(
                          Icons.assignment,
                          color: Colors.black,
                        ),
                        hintText: "Add a description ...... ",
                        hintStyle: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Lato',
                          color: Colors.black54,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2.5),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                      ),
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      //disabledColor: Colors.transparent,
                      //disabledTextColor: Colors.transparent,
                      disabledElevation: 0,
                      color: Colors.green,
                      // disabledColor: Colors.green,
                      child: Text('Upload',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          )),
                      onPressed: () {
                        upload(instructions, food, clothes, medicine, women,
                            children);
                        Navigator.popAndPushNamed(context, '/homepage');
                        //setup();

                        // Navigator.of(context).pop(context);
                        // revert();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bottom == true) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        parent1.jumpTo(parent1.position.maxScrollExtent);
      });
    }

    if (widget.initialLatitude == null) {
      setup();
    }
    Widget circle0 = new Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Icon(Icons.check),
    );
    Widget circle1 = new Stack(
      children: <Widget>[
        Container(
          height: 40,
          width: 40,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        ),
        Positioned(
          top: 6,
          left: 6,
          child: Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
    return ModalProgressHUD(
           inAsyncCall: showSpinner,
          child: Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          controller: parent1,
          child: Column(
            children: <Widget>[
              Container(
                // color: Colors.grey,
                width: MediaQuery.of(context).size.width,
                //height: MediaQuery.of(context).size.height,
                child: Column(
                  children: <Widget>[
                    Container(
                        //color: Colors.grey,
                        // padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width * 0.86,
                        height: MediaQuery.of(context).size.height / 4,
                        child: widget.initialLatitude == null
                            ? Center(
                                child: SizedBox(
                                child: CircularProgressIndicator(),
                                height: 50,
                                width: 50,
                              ))
                            : Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width * 2,
                                child: Scaffold(
                                  floatingActionButton: SingleChildScrollView(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Container(
                                            width: 30.0,
                                            height: 30.0,
                                            child: new RawMaterialButton(
                                              fillColor: Colors.blue,
                                              shape: new CircleBorder(),
                                              elevation: 0.0,
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ),
                                              onPressed: () async {
                                                final GoogleMapController
                                                    controller =
                                                    await _controller.future;
                                                controller.animateCamera(
                                                    CameraUpdate.zoomIn());
                                              },
                                            )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                            width: 30.0,
                                            height: 30.0,
                                            child: new RawMaterialButton(
                                              fillColor: Colors.blue,
                                              shape: new CircleBorder(),
                                              elevation: 0.0,
                                              child: Icon(
                                                Icons.remove,
                                                color: Colors.white,
                                              ),
                                              onPressed: () async {
                                                final GoogleMapController
                                                    controller =
                                                    await _controller.future;
                                                controller.animateCamera(
                                                    CameraUpdate.zoomOut());
                                              },
                                            )),
                                      ],
                                    ),
                                  ),
                                  resizeToAvoidBottomInset: false,
                                  resizeToAvoidBottomPadding: false,
                                  body: Container(
                                    // padding: EdgeInsets.all(10),
                                    height:
                                        MediaQuery.of(context).size.height * 2,
                                    width: MediaQuery.of(context).size.width * 2,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      controller: horizontal,
                                      child: SingleChildScrollView(
                                        controller: vertical,
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          height:
                                              MediaQuery.of(context).size.height *
                                                  2,
                                          width:
                                              MediaQuery.of(context).size.height *
                                                  2,
                                          child: GoogleMap(
                                            // myLocationButtonEnabled: true,
                                            minMaxZoomPreference:
                                                MinMaxZoomPreference.unbounded,
                                            zoomGesturesEnabled: true,
                                            onMapCreated: _onMapCreated,
                                            initialCameraPosition: CameraPosition(
                                                zoom: 16,
                                                target: LatLng(
                                                  widget.initialLatitude,
                                                  widget.initialLongitude,
                                                )),
                                            onTap:
                                                dif_loc ? selectLocation : null,
                                            markers: _pickedLocation == null
                                                ? {
                                                    Marker(
                                                        markerId: MarkerId('m1'),
                                                        position: LatLng(
                                                            widget
                                                                .initialLatitude,
                                                            widget
                                                                .initialLongitude))
                                                  }
                                                : {
                                                    Marker(
                                                      markerId: MarkerId('m1'),
                                                      position: _pickedLocation,
                                                    )
                                                  },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )

                        // SizedBox(height: 15),
                        //address != null ? Text(address) : Container(),
                        ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.89,
                          child: TextField(
                            //enabled: false,
                            readOnly: true,
                            //enabled: false,

                            textAlign: TextAlign.start,
                            textDirection: TextDirection.ltr,
                            controller: _landmark,
                            cursorColor: Colors.black,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (val) {},
                            decoration: kInputFieldDecoration.copyWith(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.location_city,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              hintText: "  Pick a Location",
                              hintStyle: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Lato',
                                color: Colors.black54,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(32.0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(32.0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2.5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(32.0)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      // width: MediaQuery.of(context).size.width * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: CheckboxListTile(
                              value: cur_loc,
                              title: Text(
                                'Current location',
                                style: TextStyle(
                                  fontFamily: "Lato",
                                  fontSize: 12,
                                ),
                              ),
                              onChanged: (val) async {
                                if (val) {
                                  _landmark.text = await convertCoordinates(
                                      widget.initialLatitude,
                                      widget.initialLongitude);
                                  widget.isSelecting = false;
                                  horizontal.animateTo(
                                    MediaQuery.of(context).size.height / 1.2,
                                    duration: Duration(seconds: 1),
                                    curve: Curves.ease,
                                  );

                                  vertical.animateTo(
                                    MediaQuery.of(context).size.height / 1.2,
                                    duration: Duration(seconds: 1),
                                    curve: Curves.ease,
                                  );
                                }
                                setState(() {
                                  widget.land_test = _landmark.text;

                                  _pickedLocation = null;
                                  if (val) {
                                    dif_loc = !val;
                                  }
                                  cur_loc = val;
                                  //dif_loc = !val;
                                });
                              },
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: CheckboxListTile(
                              title: Text('Choose location',
                                  style: TextStyle(
                                      fontSize: 12, fontFamily: 'Lato')),
                              value: dif_loc,
                              onChanged: (val) async {
                                setState(() {
                                  if (val) {
                                    _landmark.clear();
                                    widget.land_test = _landmark.text;
                                    cur_loc = !val;
                                    widget.isSelecting = true;
                                  }
                                  dif_loc = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      // width: MediaQuery.of(context).size.width,
                      // height:MediaQuery.of(context).size.height/2,
                      child: Card(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DottedBorder(
                                color: Colors.black54,
                                dashPattern: [10, 5],
                                strokeWidth: 1,
                                child: Container(
                                    //margin: EdgeInsets.all(3),
                                    width:
                                        MediaQuery.of(context).size.width * 0.36,
                                    height:
                                        MediaQuery.of(context).size.height / 3,
                                    child: widget.img == null
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  "Upload an image",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                      fontFamily: 'Lato'),
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
                            ),
                            widget.img != null
                                ? Container(
                                    // padding: EdgeInsets.all(8),
                                    width: 21,
                                    height: 21,
                                    child: FloatingActionButton(
                                      splashColor: Colors.grey,
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      foregroundColor: Colors.red,
                                      child: Icon(
                                        Icons.delete,
                                      ),
                                      onPressed: _delete,
                                    ),
                                    /*IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: _addImage,
                                          iconSize: 27,
                                        )*/
                                  )
                                : Container(),
                            FittedBox(
                              child: Container(
                                padding: EdgeInsets.only(left: 19),
                                //width: MediaQuery.of(context).size.width * 0.49,
                                //height:
                                //  MediaQuery.of(context).size.height * 0.46,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Column(
                                      children: <Widget>[
                                        Center(
                                          child: FittedBox(
                                            child: Text(
                                              'Select Category',
                                              style: TextStyle(
                                                  fontFamily: 'Lato',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.38,
                                          child: CheckboxListTile(
                                            value: widget.food,
                                            title: Text('Food',
                                                style: TextStyle(
                                                    fontFamily: 'Lato',
                                                    fontSize: 10)),
                                            onChanged: (val) {
                                              if (!val) {
                                                widget.food = val;
                                              } else {
                                                widget.food = val;
                                                widget.children = !val;
                                                widget.clothes = !val;
                                                widget.medicine = !val;
                                                widget.women = !val;
                                              }
                                              setState(() {
                                                widget.food;

                                                // widget.food = !widget.food;
                                              });
                                            },
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.38,
                                          child: CheckboxListTile(
                                            value: widget.medicine,
                                            title: Text('Medicine',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Lato',
                                                    fontSize: 10)),
                                            onChanged: (val) {
                                              setState(() {
                                                if (!val) {
                                                  widget.medicine = val;
                                                } else {
                                                  widget.food = !val;
                                                  widget.children = !val;
                                                  widget.clothes = !val;
                                                  widget.medicine = val;
                                                  widget.women = !val;
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.38,
                                          child: CheckboxListTile(
                                            value: widget.women,
                                            title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  'Women',
                                                  style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      fontSize: 10),
                                                ),
                                                Text(
                                                  'Care',
                                                  style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      fontSize: 10),
                                                ),
                                              ],
                                            ),
                                            onChanged: (val) {
                                              setState(() {
                                                if (!val) {
                                                  widget.women = val;
                                                } else {
                                                  widget.food = !val;
                                                  widget.children = !val;
                                                  widget.clothes = !val;
                                                  widget.medicine = !val;
                                                  widget.women = val;
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.38,
                                          child: CheckboxListTile(
                                            value: widget.clothes,
                                            title: Text('Clothes',
                                                style: TextStyle(
                                                    fontFamily: 'Lato',
                                                    fontSize: 10)),
                                            onChanged: (val) {
                                              setState(() {
                                                if (!val) {
                                                  widget.clothes = val;
                                                } else {
                                                  widget.food = !val;
                                                  widget.children = !val;
                                                  widget.clothes = val;
                                                  widget.medicine = !val;
                                                  widget.women = !val;
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.38,
                                          child: CheckboxListTile(
                                            value: widget.children,
                                            title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text('Children',
                                                    style: TextStyle(
                                                        fontFamily: 'Lato',
                                                        fontSize: 10)),
                                                Text('Care',
                                                    style: TextStyle(
                                                        fontFamily: 'Lato',
                                                        fontSize: 10)),
                                              ],
                                            ),
                                            onChanged: (val) {
                                              setState(() {
                                                if (!val) {
                                                  widget.children = val;
                                                } else {
                                                  widget.food = !val;
                                                  widget.children = val;
                                                  widget.clothes = !val;
                                                  widget.medicine = !val;
                                                  widget.women = !val;
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.all(10),
                  color: Colors.black12,
                  child: Column(
                    children: <Widget>[
                      Divider(
                        color: Colors.black,
                        thickness: 2,
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                                //width: ,
                                ),
                            widget.img != null ? circle0 : circle1,
                            Container(
                              width: MediaQuery.of(context).size.width / 3 - 20,
                              child: Divider(
                                color: Colors.black,
                                thickness: 2,
                                //height: 150,
                              ),
                            ),
                            ((cur_loc == false && dif_loc == false) ||
                                    _landmark.text == null)
                                ? circle1
                                : circle0,
                            Container(
                              width: MediaQuery.of(context).size.width / 3 - 20,
                              child: Divider(
                                color: Colors.black,
                                thickness: 2,
                              ),
                            ),
                            widget.food == false &&
                                    widget.medicine == false &&
                                    widget.women == false &&
                                    widget.clothes == false &&
                                    widget.children == false
                                ? circle1
                                : circle0,
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          /*widget.img != null
                              ? Text('Image selected')
                              : Text('Image Pending...'),
                              */
                          SizedBox(width: MediaQuery.of(context).size.width / 30),
                          Text('Image',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 12,
                              )),
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 3.7),

                          /*cur_loc == false && dif_loc == false
                              ? Text('Location Pending...')
                              : Text('Location selected'),*/
                          Text('Location',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 12,
                              )),
                          SizedBox(width: MediaQuery.of(context).size.width / 5),
                          /*widget.food == false &&
                                  widget.medicine == false &&
                                  widget.women == false &&
                                  widget.clothes == false &&
                                  widget.children == false
                              ? Text('Categories ')
                              : Text('Categories selected'),
                              */

                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text('Category',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 12,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            //disabledColor: Colors.transparent,
                            //disabledTextColor: Colors.transparent,
                            //disabledElevation: 0,
                            color: Colors.red,
                            child: Text('Revert Changes',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black)),
                            onPressed: () {
                              setState(() {
                                _landmark.text = '';
                                cur_loc = false;
                                dif_loc = false;
                                widget.land_test = '';
                                widget.img = null;
                                widget.medicine = false;
                                widget.food = false;
                                widget.women = false;
                                widget.children = false;
                                widget.clothes = false;
                                _pickedLocation = null;
                              });
                            },
                          ),
                          /*
                          Button(
                            text: 'Revert Changes',
                            func: () {
                              /*Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              homepage(widget.img, address, 1)));*/
                              setState(() {
                                _landmark.text = '';
                                cur_loc = false;
                                dif_loc = false;
                                widget.land_test = '';
                                widget.img = null;
                                widget.medicine = false;
                                widget.food = false;
                                widget.women = false;
                                widget.children = false;
                                widget.clothes = false;
                              });
                            },
                            col: Colors.red,
                          ),*/
                          Container(
                            height: 20,
                            child: VerticalDivider(
                              color: Colors.black,
                              thickness: 2,
                              //width: 20,
                              //key: Key('5'),
                            ),
                          ),
                          //VerticalDivider(thickness: ,)
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            //disabledColor: Colors.transparent,
                            //disabledTextColor: Colors.transparent,
                            disabledElevation: 0,
                            color: Colors.green,
                            // disabledColor: Colors.green,
                            child: Text('Save Changes',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                )),
                            onPressed: () {
                              if (widget.img != null &&
                                  _landmark.toString().isNotEmpty &&
                                  (widget.food != false ||
                                      widget.medicine != false ||
                                      widget.women != false ||
                                      widget.children != false ||
                                      widget.clothes != false)) {
                                widget.bottom = true;
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => homepage(
                                            widget.img,
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
                                             _settingModalBottomSheet(
                                  context,
                                  _instructions,
                                  _upload,
                                  widget.food,
                                  widget.clothes,
                                  widget.medicine,
                                  widget.women,
                                  widget.children,
                                  _address);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please select all the required details",
                                    gravity: ToastGravity.TOP,
                                    toastLength: Toast.LENGTH_SHORT);
                              }
                              //setup();

                             
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10)
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

/*class Button extends StatelessWidget {
  var text;
  Function func;
  Color col;
  Button({this.text, this.func, this.col});
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(30),
      color: col,
      child: MaterialButton(
        height: 40,
        minWidth: 45,
        child: Text(text),
        onPressed: func,
      ),
    );
  }
}*/