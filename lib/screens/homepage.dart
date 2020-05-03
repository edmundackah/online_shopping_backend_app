

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onlineshoppingbackendapp/CardItemModel.dart';

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

  var appColours = [
    Color.fromRGBO(231, 129, 109, 1.0),
    Color.fromRGBO(99, 138, 223, 1.0),
    Color.fromRGBO(111, 194, 173, 1.0)
  ];
  var cardIndex = 0;
  ScrollController scrollController;
  var currentColor = Color.fromRGBO(231, 129, 109, 1.0);

  var cardsList = [
    CardItemModel("Personal", Icons.account_circle, 9, 0.83),
    CardItemModel("Work", Icons.work, 12, 0.24),
    CardItemModel("Home", Icons.home, 7, 0.32)
  ];

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
      appBar: new AppBar(
        title: new Text("Control Center", style: TextStyle(fontSize: 19.0),),
        backgroundColor: currentColor,
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.search),
          ),
        ],
        elevation: 0.0,
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection("users")
              .where("email", isEqualTo: widget.email)
              .where("login.password", isEqualTo: widget.password)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            return _homepageBody(snapshot.data.documents[0]);
          }
      ),
      drawer: Drawer(),
    );
  }

  Widget _homepageBody(DocumentSnapshot doc) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 56.0),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(doc["picture"]["thumbnail"]),
                      minRadius: 30,
                      maxRadius: 30,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0,8.0,0.0,12.0),
                    child: Text("Hello, ${doc["name"]["first"]}.",
                      style: TextStyle(
                          fontSize: 28.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                  ),
                  Text("Looks like feel good.", style: TextStyle(color: Colors.white),),
                  Text("You have 3 tasks to do today.", style: TextStyle(color: Colors.white,),),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 350.0,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, position) {
                    return GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _statCard(position),
                      ),
                      onHorizontalDragEnd: (details) {

                        animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
                        curvedAnimation = CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn);
                        animationController.addListener(() {
                          setState(() {
                            currentColor = colorTween.evaluate(curvedAnimation);
                          });
                        });

                        if(details.velocity.pixelsPerSecond.dx > 0) {
                          if(cardIndex>0) {
                            cardIndex--;
                            colorTween = ColorTween(begin:currentColor,end:appColours[cardIndex]);
                          }
                        }else {
                          if(cardIndex<2) {
                            cardIndex++;
                            colorTween = ColorTween(begin: currentColor,
                                end: appColours[cardIndex]);
                          }
                        }
                        setState(() {
                          scrollController.animateTo((cardIndex)*256.0, duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
                        });

                        colorTween.animate(curvedAnimation);

                        animationController.forward( );

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

  Widget _statCard(int position) {
    return Card(
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
                  Icon(cardsList[position].icon, color: appColours[position],),
                  Icon(Icons.more_vert, color: Colors.grey,),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text("${cardsList[position].tasksRemaining} Tasks", style: TextStyle(color: Colors.grey),),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text("${cardsList[position].cardTitle}", style: TextStyle(fontSize: 28.0),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(value: cardsList[position].taskCompletion,),
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