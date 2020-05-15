import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onlineshoppingbackendapp/logic/firebase_manager.dart';
import 'package:onlineshoppingbackendapp/screens/homepage.dart';
import 'package:onlineshoppingbackendapp/screens/orders.dart';
import 'package:onlineshoppingbackendapp/screens/user_profile.dart';
import 'package:onlineshoppingbackendapp/screens/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavDrawer extends StatefulWidget {
  NavDrawer({Key key, this.currentPage}) : super(key: key);

  final int currentPage;

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {

  List<Color> _mainColour = [
    Colors.deepPurple,
    Color.fromRGBO(231, 129, 109, 1.0),
    Colors.teal,
    Color(0xff2c4260),
    Colors.pink,
    Colors.redAccent,
    Colors.deepOrange
  ];

  List<Color> _bgColour = [
    Colors.purple[100],
    Colors.deepOrange[100],
    Color(0xff81e5cd),
    Colors.grey,
    Colors.pink[100],
    Colors.red[100],
    Colors.orange[100]
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Drawer(
      child: FutureBuilder(
        future: FirebaseManager().getLoginCred(),
        builder: (context, loginSnapshot) {
          if (loginSnapshot.connectionState != ConnectionState.done) {
            return Container();
          }
          return StreamBuilder(
              stream: Firestore.instance
                  .collection("users")
                  .where("email", isEqualTo: loginSnapshot.data["email"])
                  .where("login.password", isEqualTo: loginSnapshot.data["password"])
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _userInfoSegment(snapshot),
                    _screensListView(snapshot, loginSnapshot)
                  ],
                );
              });
        },
      ),
    );
  }

  Widget _userInfoSegment(AsyncSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(
                    snapshot.data.documents[0]["picture"]["thumbnail"]),
                minRadius: 30,
                maxRadius: 30,
              ),
            ),
            Text(
              "Hello, ${snapshot.data.documents[0]["name"]["first"]}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "${snapshot.data.documents[0]["email"]}",
            overflow: TextOverflow.fade,
            maxLines: 1,
            style: TextStyle(fontSize: 16.0, color: Colors.grey),
          ),
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 50.0, bottom: 8.0),
            child: FlatButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) =>
                            UserProfileScreen(docID: snapshot.data.documents[0].documentID)
                    ));
              },
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(
                      Icons.verified_user,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    "Manage your account",
                    style: TextStyle(color: Colors.black54, fontSize: 16.0),
                  )
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.grey)
              ),
              splashColor: Colors.white,
            ),
          ),
        ],

      ),
    );
  }

  Widget _screensListView(AsyncSnapshot snapshot, AsyncSnapshot loginSnapshot) {
    List<IconData> _icons = [Icons.home, Icons.message, Icons.shopping_basket,
      Icons.people, Icons.score,Icons.record_voice_over, Icons.settings];

    List<String> _labels = ["Home", "Requests", "Orders", "Users",
      "Sentiment", "Chatbot", "Settings"];

    return ListView(
      shrinkWrap: true,
      children: List.generate(_icons.length, (int index) => Padding(
        padding: const EdgeInsets.only(left: 3.0, right: 12.0),
        child: Column(
          children: <Widget>[
            FlatButton(
              color: _bgColourPicker(index),
              onPressed: (){
                switch (index) {
                  case 0:
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(
                              email: loginSnapshot.data["email"],
                              password: loginSnapshot.data["password"],
                            )
                        ));
                    break;
                  case 2:
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => OrdersScreen(currentPage: index)
                        ));
                    break;
                  case 3:
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => UsersScreen(position: index)
                        ));
                    break;
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: Icon(_icons[index], size: 27.0, color: _colourPicker(index),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(_labels[index],
                        style: TextStyle(
                            color: _colourPicker(index),
                            fontSize: 18.0
                        ),
                      ),
                    )
                  ],),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Color _colourPicker(int index) {
    return widget.currentPage != index ? Colors.black54 : _mainColour[index];
  }

  Color _bgColourPicker(int index) {
    return widget.currentPage != index ? Colors.white10 : _bgColour[index];
  }
}
