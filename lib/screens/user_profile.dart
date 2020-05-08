import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:onlineshoppingbackendapp/screens/partials/appbar.dart';
import 'package:onlineshoppingbackendapp/screens/partials/navigation_drawer.dart';
import 'package:onlineshoppingbackendapp/screens/partials/orders_list.dart';

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen({Key key, this.docID}) : super(key: key);

  final String docID;

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>{

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: MyAppBar(
        bgColour: Colors.white,
        title: "Users",
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: Firestore.instance.collection("users")
            .document(widget.docID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              _topHalf(snapshot),

              ExpansionTile(
                title: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.perm_contact_calendar, size: 30.0, color: Colors.grey,),
                    ),
                    Text("Details",
                      style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.grey
                      ),
                    )
                  ],
                ),
                children: <Widget>[
                  _details(snapshot),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 18.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.library_books, size: 30.0, color: Colors.grey,),
                    ),
                    Text("Orders",
                      style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.grey
                      ),
                    )
                  ],
                ),
              ), 
              
              OrderListView(
                data: Firestore.instance.collection("orders")
                    .where("doc id", isEqualTo: widget.docID).snapshots(),
                scrollDirection: Axis.horizontal,
                scaffoldKey: _scaffoldKey,
              ),

            ],
          );
        }
      ),
    );
  }

  Widget _topHalf(AsyncSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0,15.0,15.0,0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Image(
                width: 200.0,
                height: 200.0,
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
            child: Column(
              children: <Widget>[
                Text(snapshot.data["name"]["first"],
                  style: TextStyle(
                      fontSize: 38.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey
                  ),
                ),
                Text(snapshot.data["isAdmin"] == null ? "Customer" : "Admin",
                  style: TextStyle(fontSize: 20.0, color: Colors.grey),
                )
              ],
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: StreamBuilder(
                stream: Firestore.instance.collection("orders")
                    .where("doc id", isEqualTo: widget.docID).snapshots(),
                builder: (context, ordersSnapshot) {
                  if (!ordersSnapshot.hasData) return CircularProgressIndicator();
                  return SizedBox(
                    height: 60.0,
                    width: 260,
                    child: Row(
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.only(right: 35.0),
                          child: Column(
                            children: <Widget>[
                              Text("${ordersSnapshot.data.documents.length}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 35.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey
                                ),
                              ),
                              Text("Orders",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 16.0, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(right: 35.0),
                          child: Column(
                            children: <Widget>[
                              Text("${20 + Random().nextInt(500 - 20)}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 35.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey
                                ),
                              ),
                              Text("Reviews",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 16.0, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                        Column(
                          children: <Widget>[
                            Text("${snapshot.data["registered"]["date"].split("-")[0]}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 35.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey
                              ),
                            ),
                            Text("Joined",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16.0, color: Colors.grey),
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
    );
  }

  Widget _details(AsyncSnapshot snapshot) {
    return Container();
  }

  Widget _orders() {

  }

}