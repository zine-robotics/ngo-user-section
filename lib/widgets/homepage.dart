import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ngouser/widgets/homeTab.dart';
import 'package:ngouser/widgets/uploadTab.dart';
import './choice.dart';

class homepage extends StatefulWidget {
  final img,location,initialPage;
  homepage(this.img,this.location,this.initialPage);
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> with SingleTickerProviderStateMixin{
  

  TabController _tabController;

  
  String uid;

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length:2);
    if(widget.initialPage!=null)_tabController.animateTo(1);
    this.uid = '';
    FirebaseAuth.instance.currentUser().then((val) {
      setState(() {
        this.uid = val.uid;
      });
    }).catchError((e) {
      print(e);
    });
    super.initState();
  }

  void _signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pop(context);
    //Navigator.popAndPushNamed(context,'/choice');
    Navigator.pushReplacementNamed(context, '/choice');
    //Navigator.push(context, MaterialPageRoute(builder: (context) => choice()));

    //Navigator.of(context).pushReplacementNamed('/choice');
    // Navigator.popAndPushNamed(context, '/choice');
    // Navigator.of(context).pushNamedAndRemoveUntil('/homepage', (Route<dynamic> route) => false);
    // Navigator.popUntil(context,ModalRoute.withName('/homepage'));
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _signOut,
          ),
          title: Text('Homepage'),
          bottom: TabBar(
            controller: _tabController,
            //isScrollable: true,
            tabs: [
              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Icon(Icons.home),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Icon(Icons.add_a_photo),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            HomeTab(this.uid),
            uploadTab(widget.img,widget.location,widget.initialPage,uid),
          ],
        ),
      )
    ;
  }
}
