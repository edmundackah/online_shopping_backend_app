import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:onlineshoppingbackendapp/model/CardItemModel.dart';
import 'package:onlineshoppingbackendapp/screens/orders.dart';
import 'package:onlineshoppingbackendapp/screens/partials/appbar.dart';
import 'package:onlineshoppingbackendapp/screens/partials/navigation_drawer.dart';
import 'package:onlineshoppingbackendapp/screens/partials/requests_chart.dart';
import 'package:onlineshoppingbackendapp/screens/partials/sales_chart.dart';
import 'package:onlineshoppingbackendapp/screens/partials/user_growth_chart.dart';
import 'package:onlineshoppingbackendapp/screens/requests.dart';
import 'package:onlineshoppingbackendapp/screens/users.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.email, this.password}) : super(key: key);

  final String email;
  final String password;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  List<Color> appColours = [
    Color.fromRGBO(231, 129, 109, 1.0),
    Color.fromRGBO(111, 194, 173, 1.0),
    Color(0xff77839a),
    Color.fromRGBO(99, 138, 223, 1.0),
  ];

  var cardIndex = 0;
  ScrollController scrollController;
  var currentColor = Color.fromRGBO(231, 129, 109, 1.0);

  final dataKey = new GlobalKey();

  AnimationController animationController;
  ColorTween colorTween;
  CurvedAnimation curvedAnimation;

  @override
  void initState() {
    super.initState();
    scrollController = new ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentColor,
      appBar: MyAppBar(bgColour: currentColor, title: "Control Center"),
      body: StreamBuilder(
          stream: Firestore.instance.collection("users")
              .where("email", isEqualTo: widget.email)
              .where("login.password", isEqualTo: widget.password)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(
                child: SizedBox(
                    height: 30.0,
                    width: 30.0,
                    child: CircularProgressIndicator()
                ));
            return _homepageBody(snapshot.data.documents[0]);
          }
      ),
      drawer: NavDrawer(currentPage: 0,),
    );
  }

  Widget _homepageBody(DocumentSnapshot doc) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 48.0, vertical: 56.0),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(
                          doc["picture"]["thumbnail"]),
                      minRadius: 30,
                      maxRadius: 30,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 12.0),
                    child: Text("Hello, ${doc["name"]["first"]}.",
                      style: TextStyle(
                          fontSize: 28.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                  ),
                  Text("Looks like a feel good day.",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 360.0,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, position) {
                    return GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _cardSelector(position),
                      ),
                      onHorizontalDragEnd: (details) {
                        animationController =
                            AnimationController(vsync: this, duration: Duration(
                                milliseconds: 500));
                        curvedAnimation = CurvedAnimation(
                            parent: animationController, curve: Curves
                            .fastOutSlowIn);
                        animationController.addListener(() {
                          setState(() {
                            currentColor = colorTween.evaluate(curvedAnimation);
                          });
                        });

                        if (details.velocity.pixelsPerSecond.dx > 0) {
                          if (cardIndex > 0) {
                            cardIndex--;
                            colorTween = ColorTween(begin: currentColor,
                                end: appColours[cardIndex]);
                          }
                        } else {
                          if (cardIndex < 3) {
                            cardIndex++;
                            colorTween = ColorTween(begin: currentColor,
                                end: appColours[cardIndex]);
                          }
                        }

                        setState(() {
                          scrollController.animateTo((cardIndex) * 295.0,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.fastOutSlowIn);
                        });

                        colorTween.animate(curvedAnimation);

                        animationController.forward();
                      },
                    );
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _cardSelector(int position) {
    switch (position) {
      case 0:
        return InkWell(
            child: RequestsChart(position: position, appColours: appColours),
          onDoubleTap: () {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => RequestsScreen(currentPage: position)
                ));
          },
        );
        break;
      case 1:
        return InkWell(
            child: SalesChart(position: position),
          onDoubleTap: (){
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => OrdersScreen(currentPage: position)
                ));
          },
        );
        break;
      case 2 :
        return InkWell(
            onDoubleTap: (){
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (context) => UsersScreen()
                  ));
            },
            child: UserGrowthChart(position: position)
        );
        break;
      default:
        return _statCard( position);
        break;
    }
  }

  Widget _statCard(int position) {
    return Card(
      elevation: 5.0,
      child: Container(
        width: 250.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(Icons.home, color: appColours[position],)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Text("7 Tasks",
                      style: TextStyle(color: Colors.grey),),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Text("Home",
                      style: TextStyle(fontSize: 28.0),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(
                      value: 0.32,),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)
      ),
    );
  }
}

