import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final bool isSelecting;
  MapScreen(
      {this.initialLatitude, this.initialLongitude, this.isSelecting = false});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _pickedLocation;
  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     /* appBar: AppBar(
        actions: <Widget>[
          if (widget.isSelecting)
            IconButton(
              icon: Icon(
                Icons.check,
              ),
              onPressed: _pickedLocation == null
                  ? () {
                      Navigator.of(context).pop(LatLng(
                        widget.initialLatitude,
                        widget.initialLongitude,
                      ));
                    }
                  : () {
                      Navigator.of(context).pop(_pickedLocation);
                    },
            )
        ],
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Specify a location',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),*/
      body: Container(
        padding: EdgeInsets.only(top:10),
        height:MediaQuery.of(context).size.height*0.25,
        width: MediaQuery.of(context).size.height*0.8,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
              zoom: 16,
              target: LatLng(
                widget.initialLatitude,
                widget.initialLongitude,
              )),
          onTap: widget.isSelecting ? _selectLocation : null,
          markers: _pickedLocation == null
              ? {
                  Marker(
                      markerId: MarkerId('m1'),
                      position:
                          LatLng(widget.initialLatitude, widget.initialLongitude))
                }
              : {
                  Marker(
                    markerId: MarkerId('m1'),
                    position: _pickedLocation,
                  )
                },
        ),
      ),
    );
  }
}
