import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ngouser/widgets/homepage.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final cam;
  final initialLatitude, initialLongitude, landmark, pickedLocation;
  final bool food,clothes,women,medicine,children;
  const DisplayPictureScreen(
      {Key key,
      this.imagePath,
      this.initialLatitude,
      this.initialLongitude,
      this.landmark,
      this.pickedLocation,
      this.cam, this.food, this.clothes, this.women, this.medicine, this.children,
      })
      : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  void submitPic() {
    //Navigator.pop(context);
    //Navigator.pop(context,widget.imagePath);
    //homepage ob=new homepage();
    //Navigator.of(context).pop(widget.imagePath);
    //Navigator.of(context).pop(widget.imagePath);
    //Navigator.of(context).popUntil(ModalRoute.withName('/homepage'));

    //Navigator.popUntil(context,ModalRoute.withName('/homepage'),widget.imagePath);

    /*Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => homepage(widget.imagePath,1,widget.cam)));*/
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => homepage(
                widget.imagePath,
                1,
                widget.cam,
                widget.initialLatitude,
                widget.initialLongitude,
                widget.landmark,
                widget.pickedLocation,widget.food,widget.clothes,widget.women,widget.medicine,widget.children,false)));
    //setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display the Picture'),
        backgroundColor: Colors.black,
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(30),
            width:MediaQuery.of(context).size.width,
            height:MediaQuery.of(context).size.height/1.5,

            child: Image.file(File(widget.imagePath)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  Navigator.pop(context);
                },
                iconSize: 35,
              ),
              IconButton(
                icon: Icon(Icons.save),
                onPressed: submitPic,
                iconSize: 35,
              ),
            ],
          )
        ],
      ),
    );
  }
}
