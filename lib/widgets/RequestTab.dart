import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

bool me;
String uidg;

class RequestTab extends StatefulWidget {
  final uid;

  RequestTab(this.uid);

  @override
  _RequestTabState createState() => _RequestTabState();
}

final Firestore _firestore = Firestore.instance;
List<DocumentSnapshot> docs;
AsyncSnapshot<QuerySnapshot> snapa;

//List<String> docs_data;
class _RequestTabState extends State<RequestTab> {
  //ScrollController scrollController = new ScrollController();
  //ScrollController scrollController = ScrollController(
  //initialScrollOffset: 30,
  //);
  //final FirebaseAuth _auth = FirebaseAuth.instance;
//List nada=[Text('No requests found')];
  @override
  Widget build(BuildContext context) {
    uidg = widget.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('requests')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        snapa = snapshot;
        if (snapshot.data == null) {
          return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Icon(Icons.error),
                    ),
                    Text("No Requests found!"),
                  ],
                );
              });
        } else {
          docs = snapshot.data.documents;
          //docs_data = snapshot.data[];

          /*List<Widget> requests = docs.map((doc) {
          Requests(doc.data['latitude'], doc.data['longitude'], doc.data['img'],
              doc.data['date']);
        }).toList();*/
          return ListView.builder(
              itemCount: getItems(context, docs).length,
              itemBuilder: (context, index) {
                // String img = snapshot.data.hitsList[index].previewUrl;
                return getItems(context, docs)[index];
              });
        }
      },
    );
  }
}

Future<Widget> _getImage(BuildContext context, String img) async {
  //String img;
  Image m;
  final StorageReference ref = FirebaseStorage.instance.ref().child(img);
  m = await ref.getDownloadURL();
  return m;
}

List<Widget> getItems(BuildContext context, List<DocumentSnapshot> docs) {
  // int i = -1;
  return docs.map((doc) {
    //i++;
    String latitude,
        longitude,
        date,
        instructions,
        status,
        landmark,
        img,
        address;

    bool food, clothes, medicine, women, children;
    women = doc.data['Women Care'];
    medicine = doc.data['Medicine'];
    clothes = doc.data['Clothes'];
    food = doc.data['Food'];
    children = doc.data['Children Care'];
    latitude = doc.data['latitude'].toString();
    longitude = doc.data['longitude'].toString();
    date = doc.data['date'].toString();
    instructions = doc.data['instructions'].toString();
    status = doc.data['status'].toString();
    landmark = doc.data['landmark'].toString();
    address = doc.data['address'].toString();
    me = (uidg == doc.data['user_id']);
    img = doc.data['download_url'].toString();
    //address = doc.data['address'].toString();
    return me
        ? GestureDetector(
            onLongPress: () {
              _settingModalBottomSheet(
                context,
                doc,
                img,
                date,
                landmark,
                instructions,
                status,
                food,
                medicine,
                women,
                clothes,
                children,
              );
            },
            child: Card(
              margin: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(img),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 3,
                        ),
                        FittedBox(
                          child: Text(
                            "Date :   " + date.substring(0, date.indexOf('T')),
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 15,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        /*FittedBox(
                          child: Text(
                            "Instructions:" + instructions,
                            style: TextStyle(fontFamily: 'Lato', fontSize: 15),
                          ),
                        ),*/
                        FittedBox(
                          child: Text(
                            "Location : " +
                                address.substring(0, address.indexOf(',')),
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Card(
                                color: Colors.red,
                                child: Padding(
                                  padding: const EdgeInsets.all(7.0),
                                  child: Text(
                                    "PENDING",
                                    style: TextStyle(
                                      fontSize: 14,
                                      //fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                            IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: () {
                                _settingModalBottomSheet(
                                  context,
                                  doc,
                                  img,
                                  date,
                                  address,
                                  instructions,
                                  status,
                                  food,
                                  medicine,
                                  women,
                                  clothes,
                                  children,
                                );
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }).toList();
}

String Category(food, medicine, women, clothes, children) {
  String s = '';
  if (food == true) {
    s += 'Food ';
  }
  if (medicine == true) {
    s += 'Medicine ';
  }
  if (women == true) {
    s += 'Women Care ';
  }
  if (clothes == true) {
    s += 'Clothes ';
  }
  if (children == true) {
    s += 'Children Care';
  }
  return s;
}

void _settingModalBottomSheet(
  context,
  doc,
  String url,
  String date,
  String address,
  String instructions,
  String status,
  food,
  medicine,
  women,
  clothes,
  children,
) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          height: (MediaQuery.of(context).size.height) / 2,
          width: MediaQuery.of(context).size.width,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              centerTitle: true,
              title: Text(
                'Details',
                //textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 20,
                ),
              ),
              leading: Container(),
            ),
            body: Container(
              decoration: BoxDecoration(
                  //border: Border.all(width: 5),
                  ),
              //padding: EdgeInsets.all(10),
              width: (MediaQuery.of(context).size.width),
              height: (MediaQuery.of(context).size.height),
              child: ListView(
                // mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.all(5),
                          width: 6 * (MediaQuery.of(context).size.width) / 10,
                          // height:MediaQuery.of(context).size.width*0.6,
                          padding: EdgeInsets.all(4),
                          child: Image(image: NetworkImage(url)),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.only(bottom: 50),
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                onPressed: () async {
                                  // StorageReference photoRef = await FirebaseStorage.getReferenceFromUrl(url);
                                  StorageReference photoRef =
                                      await FirebaseStorage.instance
                                          .getReferenceFromUrl(url);
                                  photoRef.delete().catchError((e) {});
                                  _firestore
                                      .collection('requests')
                                      .document(doc.documentID.toString())
                                      .delete()
                                      .then((_) {
                                    Fluttertoast.showToast(
                                      msg: 'Request deleted',
                                      gravity: ToastGravity.TOP,
                                      toastLength: Toast.LENGTH_SHORT,
                                    );
                                    Navigator.popAndPushNamed(
                                        context, '/homepage');
                                  }).catchError((e) {
                                    Fluttertoast.showToast(
                                      msg: 'Error deleting request',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.TOP,
                                    );
                                  });
                                },
                              )),
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Text(
                              date.substring(0, date.indexOf('T')),
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Card(
                              margin: EdgeInsets.all(5),
                              //shape: ShapeBorder.lerp(),
                              color: Colors.red,
                              child: Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 14,
                                    //fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    "ADDRESS\n ",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Text(address,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 13,
                          // fontWeight: FontWeight.bold,
                        )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "CATEGORY \n ",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    Category(food, medicine, women, clothes, children),
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 13,

                      // fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "ADDITIONAL INFORMATION \n ",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    margin:EdgeInsets.all(20) ,
                    child: Text(instructions.isNotEmpty ? instructions : '--',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 13,
                          // fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,),
                  ),
                ],
              ),

              //child: ,
            ),
          ),
        );
      });
}