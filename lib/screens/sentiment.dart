import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashy_tab_bar/flashy_tab_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:onlineshoppingbackendapp/screens/partials/navigation_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class SentimentScreen extends StatefulWidget {
  SentimentScreen({Key, @required this.position}) : super();

  final int position;
  @override
  _sentimentScreenState createState() => _sentimentScreenState();
}

class _sentimentScreenState extends State<SentimentScreen> with TickerProviderStateMixin {

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  TabController _tabController;

  int _selectedIndex = 0;

  @override
  void initState() {
    _tabController = new TabController(
        length: 4,
        vsync: this,
        initialIndex: _selectedIndex
    );

    _tabController.addListener(() {

      setState(() {
        _selectedIndex = _tabController.index;

        _tabController.animateTo(
            _tabController.index,
            duration: Duration(milliseconds: 300)
        );
      });


    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: new Text("Sentiment Tracker", style: TextStyle(fontSize: 19.0),),
          backgroundColor: Colors.white,
          elevation: 6.0,
          centerTitle: true,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(Icons.search),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, kToolbarHeight),
            child: FlashyTabBar(
              selectedIndex: _selectedIndex,
              iconSize: 20.0,
              showElevation: false,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;

                  _tabController.animateTo(
                      _selectedIndex,
                      duration: Duration(milliseconds: 400)
                  );
                });
              },
              items: [
                FlashyTabBarItem(
                  icon: Icon(Icons.view_list,
                      color: Colors.blueGrey
                  ),
                  title: Text('All',
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.blueGrey
                      )),
                ),
                FlashyTabBarItem(
                  icon: Icon(Icons.sentiment_very_satisfied,
                      color: Colors.green
                  ),
                  title: Text('Happy',
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.green
                      )),
                ),
                FlashyTabBarItem(
                  icon: Icon(Icons.sentiment_neutral,
                      color: Colors.orangeAccent
                  ),
                  title: Text('Neutral',
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.orange
                      )),
                ),
                FlashyTabBarItem(
                  icon: Icon(Icons.sentiment_dissatisfied,
                      color: Colors.red
                  ),
                  title: Text('Negative',
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.red
                      )),
                ),
              ],
            ),
          ),
        ),
        drawer: NavDrawer(currentPage: widget.position),
        body: Container(
          child: StreamBuilder(
            stream: Firestore.instance.collection("user_settings")
                .document("qmHWLXV17pvLEWclXcKc").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

              return TabBarView(
                controller: _tabController,
                children: [
                  _sentimentListView(snapshot),
                  _goodSentimentListView(snapshot),
                  _neutralSentimentListView(snapshot),
                  _badSentimentListView(snapshot)
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _sentimentListView(AsyncSnapshot snapshot){
    return Container(
      child: StreamBuilder(
        stream: Firestore.instance.collection("dummy_sentiment").snapshots(),
        builder: (context, sentSnapshot){
          if (!sentSnapshot.hasData) return Center(child: CircularProgressIndicator());
          return ListView.builder(
              itemCount: sentSnapshot.data.documents.length,
              itemBuilder: (context, index) {

                print(sentSnapshot.data.documents[index]["score"]);

                if (sentSnapshot.data.documents[index]["score"] == null) {
                  _classifySentiment(
                      snapshot,
                      sentSnapshot.data.documents[index]["message"],
                      sentSnapshot.data.documents[index].reference
                  );
                }

                return Slidable(
                  key: Key(sentSnapshot.data.documents[index].toString()),
                  actionExtentRatio: 0.25,
                  actionPane: SlidableStrechActionPane(),
                  closeOnScroll: true,
                  controller: SlidableController(),

                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0,4.0,8.0,4.0),
                    child: Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12.0,5.0,12.0,12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            sentSnapshot.data.documents[index]["message"] == null ? Container() :
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.width - 55,
                                  child: Text(
                                    sentSnapshot.data.documents[index]["message"],
                                    maxLines: 10,
                                    textAlign: TextAlign.justify,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(fontSize: 14.5),
                                  )
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                height: 4.0,
                                child: Container(
                                    color: _sentimentIndicator(
                                        sentSnapshot.data.documents[index])
                                ),
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  ),

                  secondaryActions: <Widget>[
                    InkWell(
                      onTap: () async {

                        String email = sentSnapshot.data.documents[index]["email"];

                        String url = "mailto:<$email>?"
                            "subject=<Online FeedBack>&body=<body>";

                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          //throw 'Could not launch $url';
                          final snackBar = SnackBar(
                            content: Text("E-mail app not found on device"),
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.redAccent,
                          );
                          Scaffold.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: Container(
                        color: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: AlignmentDirectional.centerStart,
                        child: Icon(
                          Icons.message,
                          color: Colors.white,
                          size: 45.0,
                          semanticLabel: "Message",
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await Firestore.instance.runTransaction((Transaction myTransaction) async {
                          await myTransaction.delete(sentSnapshot.data.documents[index].reference);

                          final snackBar = SnackBar(
                            content: Text("Removed from Tracker"),
                            elevation: 4.0,
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          );
                          Scaffold.of(context).showSnackBar(snackBar);

                        });
                      },

                      child: Container(
                        color: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: AlignmentDirectional.centerEnd,
                        child: Icon(
                          Icons.assignment_turned_in,
                          color: Colors.white,
                          size: 45.0,
                          semanticLabel: "Complete",
                        ),
                      ),

                    ),
                  ],

                );
              }
          );
        },
      ),
    );
  }
  Widget _goodSentimentListView(AsyncSnapshot snapshot){
    return Container(
      child: StreamBuilder(
        stream: Firestore.instance.collection("dummy_sentiment").snapshots(),
        builder: (context, sentSnapshot){
          if (!sentSnapshot.hasData) return Center(child: CircularProgressIndicator());
          return ListView.builder(
              itemCount: sentSnapshot.data.documents.length,
              itemBuilder: (context, index) {

                print(sentSnapshot.data.documents[index]["score"]);

                if (sentSnapshot.data.documents[index]["score"] == null) {
                  _classifySentiment(
                      snapshot,
                      sentSnapshot.data.documents[index]["message"],
                      sentSnapshot.data.documents[index].reference
                  );
                }

                return _TabCategory(sentSnapshot.data.documents[index]["score"]) == 0 ? Slidable(
                  key: Key(sentSnapshot.data.documents[index].toString()),
                  actionExtentRatio: 0.25,
                  actionPane: SlidableStrechActionPane(),
                  closeOnScroll: true,
                  controller: SlidableController(),

                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0,4.0,8.0,4.0),
                    child: Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12.0,5.0,12.0,12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            sentSnapshot.data.documents[index]["message"] == null ? Container() :
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.width - 55,
                                  child: Text(
                                    sentSnapshot.data.documents[index]["message"],
                                    maxLines: 10,
                                    textAlign: TextAlign.justify,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(fontSize: 14.5),
                                  )
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                height: 4.0,
                                child: Container(
                                    color: _sentimentIndicator(
                                        sentSnapshot.data.documents[index])
                                ),
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  ),

                  secondaryActions: <Widget>[
                    InkWell(
                      onTap: () async {

                        String email = sentSnapshot.data.documents[index]["email"];

                        String url = "mailto:<$email>?"
                            "subject=<Online FeedBack>&body=<body>";

                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          //throw 'Could not launch $url';
                          final snackBar = SnackBar(
                            content: Text("E-mail app not found on device"),
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.redAccent,
                          );
                          Scaffold.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: Container(
                        color: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: AlignmentDirectional.centerStart,
                        child: Icon(
                          Icons.message,
                          color: Colors.white,
                          size: 45.0,
                          semanticLabel: "Message",
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await Firestore.instance.runTransaction((Transaction myTransaction) async {
                          await myTransaction.delete(sentSnapshot.data.documents[index].reference);

                          final snackBar = SnackBar(
                            content: Text("Removed from Tracker"),
                            elevation: 4.0,
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          );
                          Scaffold.of(context).showSnackBar(snackBar);

                        });
                      },

                      child: Container(
                        color: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: AlignmentDirectional.centerEnd,
                        child: Icon(
                          Icons.assignment_turned_in,
                          color: Colors.white,
                          size: 45.0,
                          semanticLabel: "Complete",
                        ),
                      ),

                    ),
                  ],

                ) : Container();
              }
          );
        },
      ),
    );
  }
  Widget _neutralSentimentListView(AsyncSnapshot snapshot){
    return Container(
      child: StreamBuilder(
        stream: Firestore.instance.collection("dummy_sentiment").snapshots(),
        builder: (context, sentSnapshot){
          if (!sentSnapshot.hasData) return Center(child: CircularProgressIndicator());
          return ListView.builder(
              itemCount: sentSnapshot.data.documents.length,
              itemBuilder: (context, index) {

                print(sentSnapshot.data.documents[index]["score"]);

                if (sentSnapshot.data.documents[index]["score"] == null) {
                  _classifySentiment(
                      snapshot,
                      sentSnapshot.data.documents[index]["message"],
                      sentSnapshot.data.documents[index].reference
                  );
                }

                return _TabCategory(sentSnapshot.data.documents[index]["score"]) == 1 ? Slidable(
                  key: Key(sentSnapshot.data.documents[index].toString()),
                  actionExtentRatio: 0.25,
                  actionPane: SlidableStrechActionPane(),
                  closeOnScroll: true,
                  controller: SlidableController(),

                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0,4.0,8.0,4.0),
                    child: Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12.0,5.0,12.0,12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            sentSnapshot.data.documents[index]["message"] == null ? Container() :
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.width - 55,
                                  child: Text(
                                    sentSnapshot.data.documents[index]["message"],
                                    maxLines: 10,
                                    textAlign: TextAlign.justify,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(fontSize: 14.5),
                                  )
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                height: 4.0,
                                child: Container(
                                    color: _sentimentIndicator(
                                        sentSnapshot.data.documents[index])
                                ),
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  ),

                  secondaryActions: <Widget>[
                    InkWell(
                      onTap: () async {

                        String email = sentSnapshot.data.documents[index]["email"];

                        String url = "mailto:<$email>?"
                            "subject=<Online FeedBack>&body=<body>";

                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          //throw 'Could not launch $url';
                          final snackBar = SnackBar(
                            content: Text("E-mail app not found on device"),
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.redAccent,
                          );
                          Scaffold.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: Container(
                        color: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: AlignmentDirectional.centerStart,
                        child: Icon(
                          Icons.message,
                          color: Colors.white,
                          size: 45.0,
                          semanticLabel: "Message",
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await Firestore.instance.runTransaction((Transaction myTransaction) async {
                          await myTransaction.delete(sentSnapshot.data.documents[index].reference);

                          final snackBar = SnackBar(
                            content: Text("Removed from Tracker"),
                            elevation: 4.0,
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          );
                          Scaffold.of(context).showSnackBar(snackBar);

                        });
                      },

                      child: Container(
                        color: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: AlignmentDirectional.centerEnd,
                        child: Icon(
                          Icons.assignment_turned_in,
                          color: Colors.white,
                          size: 45.0,
                          semanticLabel: "Complete",
                        ),
                      ),

                    ),
                  ],

                ) : Container();
              }
          );
        },
      ),
    );
  }
  Widget _badSentimentListView(AsyncSnapshot snapshot){
    return Container(
      child: StreamBuilder(
        stream: Firestore.instance.collection("dummy_sentiment").snapshots(),
        builder: (context, sentSnapshot){
          if (!sentSnapshot.hasData) return Center(child: CircularProgressIndicator());
          return ListView.builder(
              itemCount: sentSnapshot.data.documents.length,
              itemBuilder: (context, index) {

                print(sentSnapshot.data.documents[index]["score"]);

                if (sentSnapshot.data.documents[index]["score"] == null) {
                  _classifySentiment(
                      snapshot,
                      sentSnapshot.data.documents[index]["message"],
                      sentSnapshot.data.documents[index].reference
                  );
                }

                return _TabCategory(sentSnapshot.data.documents[index]["score"]) == 2 ? Slidable(
                  key: Key(sentSnapshot.data.documents[index].toString()),
                  actionExtentRatio: 0.25,
                  actionPane: SlidableStrechActionPane(),
                  closeOnScroll: true,
                  controller: SlidableController(),

                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0,4.0,8.0,4.0),
                    child: Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12.0,5.0,12.0,12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            sentSnapshot.data.documents[index]["message"] == null ? Container() :
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.width - 55,
                                  child: Text(
                                    sentSnapshot.data.documents[index]["message"],
                                    maxLines: 10,
                                    textAlign: TextAlign.justify,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(fontSize: 14.5),
                                  )
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                height: 4.0,
                                child: Container(
                                    color: _sentimentIndicator(
                                        sentSnapshot.data.documents[index])
                                ),
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  ),

                  secondaryActions: <Widget>[
                    InkWell(
                      onTap: () async {

                        String email = sentSnapshot.data.documents[index]["email"];

                        String url = "mailto:<$email>?"
                            "subject=<Online FeedBack>&body=<body>";

                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          //throw 'Could not launch $url';
                          final snackBar = SnackBar(
                            content: Text("E-mail app not found on device"),
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.redAccent,
                          );
                          Scaffold.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: Container(
                        color: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: AlignmentDirectional.centerStart,
                        child: Icon(
                          Icons.message,
                          color: Colors.white,
                          size: 45.0,
                          semanticLabel: "Message",
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await Firestore.instance.runTransaction((Transaction myTransaction) async {
                          await myTransaction.delete(sentSnapshot.data.documents[index].reference);

                          final snackBar = SnackBar(
                            content: Text("Removed from Tracker"),
                            elevation: 4.0,
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          );
                          Scaffold.of(context).showSnackBar(snackBar);

                        });
                      },

                      child: Container(
                        color: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: AlignmentDirectional.centerEnd,
                        child: Icon(
                          Icons.assignment_turned_in,
                          color: Colors.white,
                          size: 45.0,
                          semanticLabel: "Complete",
                        ),
                      ),

                    ),
                  ],

                ) : Container();
              }
          );
        },
      ),
    );
  }

  MaterialColor _sentimentIndicator(DocumentSnapshot snapshot) {
    double score = snapshot.data["score"];
    MaterialColor labelColour = Colors.blueGrey;

    if (score != null ) {
      if (score >= 0 && score <= 0.40) {
        labelColour = Colors.red;
      } else if (score >= 0.40 && score <= 0.55) {
        labelColour = Colors.orange;
      } else if (score >= 0.55) {
        labelColour = Colors.green;
      }
    }
    return labelColour;
  }

  int _TabCategory(double score) {
    int position;

    if (score != null ) {
      if (score >= 0 && score <= 0.45) {
        position = 2;

      } else if (score >= 0.45 && score <= 0.55) {
        position = 1;

      } else if (score >= 0.55) {
        position = 0;
      }
    }
    return position;
  }

  Future<Null> _classifySentiment(AsyncSnapshot snapshot, String message, DocumentReference docRef) async {

    double score;

    String url = "http://${snapshot.data["server_endpoint"]}"
        ".eu-west-2.compute.amazonaws.com/detect-sentiment";

    http.Response res = await http.post(url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic> {
          "payload": [{"message": message.toString(), "id": 0}]
      }),
    ).catchError((onError){

      print(onError);

      final snackBar = SnackBar(
        content: Text("Check Server endpoint"),
        elevation: 5.0,
        duration: Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    });

    if (res.statusCode == 200) {
      //print(json.decode(res.body));
      if (json.decode(res.body)["predictions"].length > 0) {
        score = json.decode(res.body)["predictions"][0]["score"];
      }
    }
    //print(score);
    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(docRef);
      if (postSnapshot.exists) {
        await tx.update(docRef, <String, dynamic>{'score': score});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

}