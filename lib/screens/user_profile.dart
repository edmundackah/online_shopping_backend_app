import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
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
  final int _reviews = 20 + Random().nextInt(200 - 20);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
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

                      Padding(
                        padding: const EdgeInsets.only(left: 18.0, top: 5.0),
                        child: RaisedButton.icon(
                          elevation: 5.0,
                            icon: Icon(Icons.delete, color: Colors.redAccent,),
                            onPressed: (){},
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                                side: BorderSide(color: Colors.red)
                            ),
                            label: Text("Save Changes", style: TextStyle(color: Colors.redAccent),
                            )
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
                                  initialValue: snapshot.data["name"]["title"],
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
                                Text("First Name",
                                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                                ),
                                TextFormField(
                                  initialValue: snapshot.data["name"]["first"],
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
                                Text("Last Name",
                                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                                ),
                                TextFormField(
                                  initialValue: snapshot.data["name"]["last"],
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
                                  initialValue: snapshot.data["cell"],
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
                                Text("DOB",
                                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                                ),

                                InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
                                    child: Text(snapshot.data["dob"]["date"],
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  ),
                                  onTap: () async {
                                    var datePicked = await DatePicker.showSimpleDatePicker(
                                      context,
                                      initialDate: null,
                                      firstDate: DateTime(1920),
                                      lastDate: DateTime(DateTime.now().year),
                                      dateFormat: "dd-MMMM-yyyy",
                                      locale: DateTimePickerLocale.en_us,
                                      looping: true,
                                    );

                                    print(datePicked.toUtc().toString());

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

  void _updateUserDetails(TextEditingController controller, String fieldName, {DateTime pickedDate}) {
    final DocumentReference postRef = Firestore.instance.collection("users").document(widget.docID);

    print("${widget.docID}");

    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(postRef);
      String _snackBarText = "";

      if (postSnapshot.exists) {
        await Future.delayed(Duration(microseconds: 300));

        switch (fieldName) {
          case "name.title":
            if (controller.text.isNotEmpty && controller.text.length >= 2) {
              var _products = postSnapshot.data["name"];

              print(postSnapshot.data["name"]["title"]);
              _products["name"]["title"] = controller.text;

              print(_products["name"]["title"]);

              await tx.update(postRef, <String, dynamic>{'name': _products});

              _snackBarText = "Details Updated!";
            } else {
              _snackBarText = "Must be atleast 2 characters and not empty";
            }
            break;

          case "name.first":
            if (controller.text.isNotEmpty && controller.text.length >= 2) {
              var _products = postSnapshot.data["name"];
              _products["name"]["first"] = controller.text;
              await tx.update(postRef, <String, dynamic>{'name': _products});

              _snackBarText = "Details Updated!";
            } else {
              _snackBarText = "Must be atleast 2 characters and not empty";
            }
            break;
          case "name.last":
            if (controller.text.isNotEmpty && controller.text.length >= 2) {

              var _products = postSnapshot.data["name"];
              _products["name"]["last"] = controller.text;
              await tx.update(postRef, <String, dynamic>{'name': _products});

              _snackBarText = "Details Updated!";

            } else {
              _snackBarText = "Must be atleast 2 characters and not empty";
            }
            break;
          case "cell":
            if (controller.text.isNotEmpty && controller.text.length == 11 && double.tryParse(controller.text) != null) {

              String tempValue =
              controller.text.replaceAll("-", "").replaceAll("(", "").replaceAll(")", "");

              await tx.update(postRef, <String, dynamic>{'cell': tempValue});
              _snackBarText = "Details Updated!";
            } else {
              _snackBarText = "Enter a valid phone number";
            }
            break;
          case "dob.date":

            if (pickedDate != null){
              var _products = postSnapshot.data["dob"];
              _products["dob"]["date"] = pickedDate.toUtc().toString();
              _products["dob"]["age"] = DateTime.now().year - int.parse(pickedDate.toUtc().toString().split("-")[0]);

              await tx.update(postRef, <String, dynamic>{'dob': _products});
              _snackBarText = "Details Updated!";
            } else {
              _snackBarText = "Select a valid date!";
            }
            break;
        }

        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Details Updated!"),
          duration: Duration(seconds: 3),
        ));
      }

      print("${controller.text} : $fieldName ");

    }).catchError((onError) => print(onError));
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