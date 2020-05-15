import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:onlineshoppingbackendapp/screens/orders.dart';
import 'package:onlineshoppingbackendapp/screens/partials/appbar.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen({Key key, this.docID}) : super(key: key);

  final String docID;

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final int _reviews = 20 + Random().nextInt(200 - 20);

  final TextEditingController _titleController = new TextEditingController();
  final TextEditingController _firstNameController = new TextEditingController();
  final TextEditingController _lastNameController = new TextEditingController();
  final TextEditingController _phoneNumController = new TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _lastNameController.dispose();
    _phoneNumController.dispose();
    _firstNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: MyAppBar(
        bgColour: Colors.white,
        title: "Users",
      ),
      backgroundColor: Colors.grey[200],
      body: StreamBuilder(
        stream: Firestore.instance.collection("users")
            .document(widget.docID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          if (snapshot.data["reviews"] == null) _saveReviewCount();

          _titleController.text = snapshot.data["name"]["title"];
          _firstNameController.text = snapshot.data["name"]["first"];
          _lastNameController.text = snapshot.data["name"]["last"];
          _phoneNumController.text = snapshot.data["cell"];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                      elevation: 5.0,
                      child: _topHalf(snapshot),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 15.0, left: 14.0, bottom: 20.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.perm_contact_calendar,
                          size: 30.0,
                          color: Colors.blueGrey[500],
                        ),
                      ),
                      Text("Personal Details",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(left: 12.0, bottom: 20.0, right: 12.0),
                  child: Card(
                    elevation: 5.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Title",
                                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                                ),
                                TextFormField(
                                  style:  TextStyle(
                                    fontSize: 20.0,
                                  ),
                                  autocorrect: true,
                                  controller: _titleController,
                                  textCapitalization: TextCapitalization.words,
                                  onEditingComplete: () async {

                                    String text = _titleController.text;

                                    if (text.length > 2 && text.isNotEmpty) {
                                      final DocumentReference postRef = Firestore
                                          .instance.collection("users").document(widget.docID);
                                      Firestore.instance.runTransaction((
                                          Transaction tx) async {
                                        DocumentSnapshot postSnapshot = await tx.get(
                                            postRef);
                                        if (postSnapshot.exists) {
                                          var nameArray = postSnapshot.data["name"];
                                          nameArray["title"] = text;
                                          await tx.update(postRef, <String, dynamic>{
                                            'name': nameArray
                                          }).catchError((onError){
                                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                                              content: Text("Failed to update Title",
                                                  style: TextStyle(color: Colors.white)),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 3),
                                            ));
                                          });
                                        }
                                      });
                                    } else {
                                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                                        content: Text("Title must be at least 2 characters",
                                            style: TextStyle(color: Colors.white)),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                      ));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("First Name",
                                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                                ),
                                TextFormField(
                                  style:  TextStyle(
                                    fontSize: 20.0,
                                  ),
                                  autocorrect: true,
                                  textCapitalization: TextCapitalization.words,
                                  controller: _firstNameController,
                                  onEditingComplete: () {

                                    String text = _firstNameController.text;

                                    if (text.length > 2 && text.isNotEmpty) {
                                      final DocumentReference postRef = Firestore
                                          .instance.collection("users").document(widget.docID);
                                      Firestore.instance.runTransaction((
                                          Transaction tx) async {
                                        DocumentSnapshot postSnapshot = await tx.get(
                                            postRef);
                                        if (postSnapshot.exists) {
                                          var nameArray = postSnapshot.data["name"];
                                          nameArray["first"] = text;
                                          await tx.update(postRef, <String, dynamic>{
                                            'name': nameArray
                                          }).catchError((onError){
                                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                                              content: Text("Failed to update name",
                                                  style: TextStyle(color: Colors.white)),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 3),
                                            ));
                                          });
                                        }
                                      });
                                    } else {
                                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                                        content: Text("Name must be at least 2 characters",
                                            style: TextStyle(color: Colors.white)),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                      ));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Last Name",
                                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                                ),
                                TextFormField(
                                  style:  TextStyle(
                                    fontSize: 20.0,
                                  ),
                                  autocorrect: true,
                                  textCapitalization: TextCapitalization.words,
                                  controller: _lastNameController,
                                  onEditingComplete: () {

                                    String text = _lastNameController.text;

                                    if (text.length > 2 && text.isNotEmpty) {
                                      final DocumentReference postRef = Firestore
                                          .instance.collection("users").document(widget.docID);

                                      Firestore.instance.runTransaction((
                                          Transaction tx) async {
                                        DocumentSnapshot postSnapshot = await tx.get(
                                            postRef);
                                        if (postSnapshot.exists) {
                                          var nameArray = postSnapshot.data["name"];
                                          nameArray["last"] = text;
                                          await tx.update(postRef, <String, dynamic>{
                                            'name': nameArray
                                          }).catchError((onError){
                                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                                              content: Text("Failed to update name",
                                                  style: TextStyle(color: Colors.white)),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 3),
                                            ));
                                          });
                                        }
                                      });
                                    } else {
                                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                                        content: Text("Name must be at least 2 characters",
                                            style: TextStyle(color: Colors.white)),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                      ));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Email",
                                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                                ),
                                TextFormField(
                                  enabled: false,
                                  initialValue: snapshot.data["email"],
                                  style:  TextStyle(
                                    fontSize: 20.0,
                                  ),
                                  autocorrect: true,
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Phone Number",
                                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                                ),
                                TextFormField(
                                  key: _formKey,
                                  style:  TextStyle(
                                    fontSize: 20.0,
                                  ),
                                  autocorrect: true,
                                  controller: _phoneNumController,
                                  keyboardType: TextInputType.phone,
                                  onEditingComplete: () {

                                    String number = _phoneNumController.text
                                        .replaceAll(" ", "").replaceAll("-", "");

                                    if (number.length > 9 &&number.isNotEmpty ) {
                                      final DocumentReference postRef = Firestore
                                          .instance.collection("users").document(widget.docID);

                                      Firestore.instance.runTransaction((
                                          Transaction tx) async {
                                        DocumentSnapshot postSnapshot = await tx.get(
                                            postRef);
                                        if (postSnapshot.exists) {
                                          await tx.update(postRef, <String, dynamic>{
                                            'cell': _phoneNumController.text
                                          }).catchError((onError){
                                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                                              content: Text("Failed to update phone number",
                                                  style: TextStyle(color: Colors.white)),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 3),
                                            ));
                                          });
                                        }
                                      });

                                    } else {
                                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                                        content: Text("Number must be 11 digits",
                                            style: TextStyle(color: Colors.white)),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                      ));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("DOB",
                                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                                ),

                                InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
                                    child: Text(snapshot.data["dob"]["date"].toString().substring(0, 10),
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  ),
                                  onTap: () async {
                                    DateTime datePicked = await DatePicker.showSimpleDatePicker(
                                      context,
                                      initialDate: DateTime.parse(snapshot.data["dob"]["date"]),
                                      firstDate: DateTime(1930),
                                      lastDate: DateTime(DateTime.now().year),
                                      dateFormat: "dd-MMMM-yyyy",
                                      locale: DateTimePickerLocale.en_us,
                                      looping: true,
                                    );

                                    if (datePicked != null ) {

                                      DateTime today = DateTime.now();
                                      int age = (today.difference(datePicked).inDays / 365).floor();

                                      if (age >= 12) {
                                        final DocumentReference postRef = Firestore
                                            .instance.collection("users").document(widget.docID);

                                        Firestore.instance.runTransaction((
                                            Transaction tx) async {
                                          DocumentSnapshot postSnapshot = await tx.get(
                                              postRef);
                                          if (postSnapshot.exists) {

                                            var dobArray = postSnapshot.data["dob"];
                                            dobArray["age"] = age;
                                            dobArray["date"] = datePicked.toUtc().toString();

                                            await tx.update(postRef, <String, dynamic>{
                                              'dob': dobArray
                                            }).catchError((onError){
                                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                                content: Text("Failed to update D.O.B",
                                                    style: TextStyle(color: Colors.white)),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 3),
                                              ));
                                            });
                                          }
                                        });

                                      } else {
                                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                                          content: Text("Must be 12 or older to hold an account",
                                              style: TextStyle(color: Colors.white)),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 3),
                                        ));
                                      }
                                    }


                                  },
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _topHalf(AsyncSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: Image(
                    width: 100.0,
                    height: 100.0,
                    image: AdvancedNetworkImage(
                      snapshot.data["picture"]["large"],
                      useDiskCache: true,
                      cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 25.0, left: 40.0),
                  child: StreamBuilder(
                      stream: Firestore.instance.collection("orders")
                          .where("doc id", isEqualTo: widget.docID)
                          .snapshots(),
                      builder: (context, ordersSnapshot) {
                        if (!ordersSnapshot.hasData)
                          return CircularProgressIndicator();
                        return SizedBox(
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 40.0),
                                child: InkWell(
                                  onTap: () => Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (context) => OrdersScreen(
                                            docID: widget.docID)
                                      )),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      Text("${ordersSnapshot.data.documents
                                          .length}",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 35.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.redAccent
                                        ),
                                      ),
                                      Text("Orders",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start,
                                children: <Widget>[
                                  Text(
                                    "${snapshot.data["registered"]["date"]
                                        .split("-")[0]}",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 35.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey[500]
                                    ),
                                  ),
                                  Text("Joined",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        );
                      }
                  ),
                ),
              ),

            ],
          ),

          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Row(
              children: <Widget>[
                Text(snapshot.data["name"]["first"],
                  style: TextStyle(
                      fontSize: 35.0,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text(",",
                    style: TextStyle(
                        fontSize: 35.0,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text("${snapshot.data["dob"]["age"]}",
                    style: TextStyle(
                        fontSize: 35.0,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveReviewCount() {
    final DocumentReference postRef = Firestore.instance.collection("users")
        .document(widget.docID);

    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(postRef);
      if (postSnapshot.exists) {
        await tx.update(postRef, <String, dynamic>{'reviews': _reviews});
      }
    });
  }

  Widget _details(AsyncSnapshot snapshot) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Name"),
          TextField()
        ],
      ),
    );
  }
}