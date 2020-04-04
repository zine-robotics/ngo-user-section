import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ngouser/widgets/homepage.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  void submitPic() {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>homepage(widget.imagePath, null,1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Column(
        children: <Widget>[
          Image.file(File(widget.imagePath)),
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
