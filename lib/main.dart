import 'package:flutter/material.dart';
import 'package:ngouser/widgets/login.dart';
import 'package:ngouser/widgets/takePicture.dart';
import './widgets/choice.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import './widgets/page1.dart';
import './widgets/homepage.dart';
import 'package:camera/camera.dart';

//var firstCamera;
bool _user = false;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(MyApp(firstCamera));
}

class MyApp extends StatefulWidget {
  final cam;
  MyApp(this.cam);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  @override
  void initState() {
    getUser().then((user) {
      if (user != null) {
        setState(() {
          _user = true;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGO app',
      routes: <String, WidgetBuilder>{
        '/choice': (BuildContext context) => new choice(),
        '/login': (BuildContext context) => new login(),
        //'/page1':(BuildContext context)=>new page1(),
        '/homepage': (BuildContext context) => new homepage(null,null,null),
        '/takePicture': (BuildContext context) => new TakePictureScreen(widget.cam),
      },
      debugShowCheckedModeBanner: false,
      home: _user ? homepage(null,null,null) : choice(),
    );
  }
}
