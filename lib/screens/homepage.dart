import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:onlineshoppingbackendapp/model/CardItemModel.dart';

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
    Color.fromRGBO(111, 194, 173, 1.0),
    Color.fromRGBO(99, 138, 223, 1.0),
    Color.fromRGBO(99, 138, 223, 1.0)
  ];
  var cardIndex = 0;
  ScrollController scrollController;
  var currentColor = Color.fromRGBO(231, 129, 109, 1.0);

  List<CardItemModel> cardsList = [
    CardItemModel("Personal", Icons.account_circle, 9, 0.83),
    CardItemModel("Work", Icons.work, 12, 0.24),
    CardItemModel("Home", Icons.home, 7, 0.32),
    CardItemModel("Home", Icons.home, 7, 0.32)
  ];

  AnimationController animationController;
  ColorTween colorTween;
  CurvedAnimation curvedAnimation;

  final Color barBackgroundColor = const Color(0xff72d8bf);
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex;
  final List<Color> availableColours = [
    Colors.purpleAccent,
    Colors.yellow,
    Colors.lightBlue,
    Colors.orange,
    Colors.pink,
    Colors.redAccent,
  ];

  bool isPlaying = false;

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
                height: 350.0,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: cardsList.length + 1,
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
                          if (cardIndex < 2) {
                            cardIndex++;
                            colorTween = ColorTween(begin: currentColor,
                                end: appColours[cardIndex]);
                          }
                        }
                        setState(() {
                          scrollController.animateTo((cardIndex) * 256.0,
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
        return _RequestsCard(position);
        break;
      case 1:
        return _salesCard(position);
        break;
      case 2 :
        return UserGrowthChart(position: position);
        break;
      default:
        return _statCard(position);
        break;
    }
  }

  Widget _RequestsCard(int position) {
    return StreamBuilder(
        stream: Firestore.instance.collection("requests").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
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
                        Icon(Icons.people, color: appColours[position],)
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
                          child: Text("${snapshot.data.documents
                              .length} Requests", style: TextStyle(
                              color: Colors.grey),),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text("Customer Queries", style: TextStyle(
                              fontSize: 26.0),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder(
                              stream: Firestore.instance.collection("requests")
                                  .where("isCompleted", isEqualTo: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData)
                                  return const LinearProgressIndicator();
                                return LinearProgressIndicator(
                                    value: snapshot.data.documents.length
                                        .toDouble());
                              }
                          ),
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
    );
  }

  Widget _salesCard(int position) {
    return StreamBuilder(
        stream: Firestore.instance.collection("requests").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          return AspectRatio(
            aspectRatio: 1,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: const Color(0xff81e5cd),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          'Weekly sales overview',
                          style: TextStyle(
                              color: const Color(0xff0f4a3c),
                              fontSize: 21,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Orders placed this week',
                          style: TextStyle(
                              color: const Color(0xff379982),
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 38,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0),
                            child: StreamBuilder(
                              stream: Firestore.instance.collection("orders").snapshots(),
                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                if (!snapshot.hasData) return const CircularProgressIndicator();
                                return BarChart(
                                  isPlaying ? randomData() : mainBarData(snapshot),
                                  swapAnimationDuration: animDuration,
                                );
                              }
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: const Color(0xff0f4a3c),
                        ),
                        onPressed: () {
                          setState(() {
                            isPlaying = !isPlaying;
                            if (isPlaying) {
                              refreshState();
                            }
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  BarChartData mainBarData(AsyncSnapshot snapshot) {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;
              switch (group.x.toInt()) {
                case 0:
                  weekDay = 'Monday';
                  break;
                case 1:
                  weekDay = 'Tuesday';
                  break;
                case 2:
                  weekDay = 'Wednesday';
                  break;
                case 3:
                  weekDay = 'Thursday';
                  break;
                case 4:
                  weekDay = 'Friday';
                  break;
                case 5:
                  weekDay = 'Saturday';
                  break;
                case 6:
                  weekDay = 'Sunday';
                  break;
              }
              return BarTooltipItem(
                  weekDay + '\n' + (rod.y - 1).toString(),
                  TextStyle(color: Colors.yellow));
            }),
        touchCallback: (barTouchResponse) {
          setState(() {
            if (barTouchResponse.spot != null &&
                barTouchResponse.touchInput is! FlPanEnd &&
                barTouchResponse.touchInput is! FlLongPressEnd) {
              touchedIndex = barTouchResponse.spot.touchedBarGroupIndex;
            } else {
              touchedIndex = -1;
            }
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          textStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0:
                return 'M';
              case 1:
                return 'T';
              case 2:
                return 'W';
              case 3:
                return 'T';
              case 4:
                return 'F';
              case 5:
                return 'S';
              case 6:
                return 'S';
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(snapshot),
    );
  }

  List<BarChartGroupData> showingGroups(AsyncSnapshot snapshot) =>
      List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(snapshot, 0, _getDailySaleCount(0, snapshot), isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(snapshot, 1, _getDailySaleCount(1, snapshot), isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(snapshot, 2, _getDailySaleCount(2, snapshot), isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(snapshot, 3, _getDailySaleCount(3, snapshot), isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(snapshot, 4, _getDailySaleCount(4, snapshot), isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(snapshot, 5, _getDailySaleCount(5, snapshot), isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(snapshot, 6, _getDailySaleCount(6, snapshot), isTouched: i == touchedIndex);
          default:
            return null;
        }
      });

  double _getDailySaleCount(int day, AsyncSnapshot snapshot) {
    //get all the dates for the current week
    int weekday = day + 1;

    double salesCount = 0;
    DateTime now = DateTime.now().subtract(Duration(days: 7));

    while (now.weekday != weekday) {
      now = now.subtract(Duration(days: 1));
    }

    int multiplier = weekday == 1 ? 1 : 2;
    now = now.add(Duration(days: 7 * multiplier));

    String dateComponent = now.toString().split(" ")[0];

    snapshot.data.documents.forEach((doc){
      if (doc["date"].contains(dateComponent)) {
        salesCount ++;
      }
    });

    return salesCount;
  }

  BarChartGroupData makeGroupData(AsyncSnapshot snapshot, int x, double y,
      {bool isTouched = false, Color barColor = Colors.white, double width = 22,
        List<int> showTooltips = const [],}
        ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 1 : y,
          color: isTouched ? Colors.yellow : barColor,
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: snapshot == null ? 20 : snapshot.data.documents.length.toDouble(),
            color: barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  BarChartData randomData() {
    return BarChartData(
      barTouchData: BarTouchData(
        enabled: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          textStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0:
                return 'M';
              case 1:
                return 'T';
              case 2:
                return 'W';
              case 3:
                return 'T';
              case 4:
                return 'F';
              case 5:
                return 'S';
              case 6:
                return 'S';
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(null, 0, Random().nextInt(15).toDouble() + 6,
                barColor: availableColours[Random().nextInt(
                    availableColours.length)]);
          case 1:
            return makeGroupData(null, 1, Random().nextInt(15).toDouble() + 6,
                barColor: availableColours[Random().nextInt(
                    availableColours.length)]);
          case 2:
            return makeGroupData(null, 2, Random().nextInt(15).toDouble() + 6,
                barColor: availableColours[Random().nextInt(
                    availableColours.length)]);
          case 3:
            return makeGroupData(null, 3, Random().nextInt(15).toDouble() + 6,
                barColor: availableColours[Random().nextInt(
                    availableColours.length)]);
          case 4:
            return makeGroupData(null, 4, Random().nextInt(15).toDouble() + 6,
                barColor: availableColours[Random().nextInt(
                    availableColours.length)]);
          case 5:
            return makeGroupData(null, 5, Random().nextInt(15).toDouble() + 6,
                barColor: availableColours[Random().nextInt(
                    availableColours.length)]);
          case 6:
            return makeGroupData(null, 6, Random().nextInt(15).toDouble() + 6,
                barColor: availableColours[Random().nextInt(
                    availableColours.length)]);
          default:
            return null;
        }
      }),
    );
  }

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(
        animDuration + const Duration(milliseconds: 50));
    if (isPlaying) {
      refreshState();
    }
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
                  Icon(cardsList[position].icon, color: appColours[position],)
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
                    child: Text("${cardsList[position].tasksRemaining} Tasks",
                      style: TextStyle(color: Colors.grey),),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Text("${cardsList[position].cardTitle}",
                      style: TextStyle(fontSize: 28.0),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(
                      value: cardsList[position].taskCompletion,),
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

class UserGrowthChart extends StatefulWidget {
  UserGrowthChart({Key key, this.position}) : super(key: key);

  final int position;

  @override
  _UserGrowthChartState createState() => _UserGrowthChartState();
}

class _UserGrowthChartState extends State<UserGrowthChart>{
  final Color leftBarColor = const Color(0xff53fdd7);
  final Color rightBarColor = const Color(0xffff5182);
  final double width = 7;

  List<BarChartGroupData> rawBarGroups;
  List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex;

  @override
  void initState() {
    super.initState();
    final barGroup1 = makeGroupData(0, 5, 12);
    final barGroup2 = makeGroupData(1, 16, 12);
    final barGroup3 = makeGroupData(2, 18, 5);
    final barGroup4 = makeGroupData(3, 20, 16);
    final barGroup5 = makeGroupData(4, 17, 6);
    final barGroup6 = makeGroupData(5, 19, 1.5);
    final barGroup7 = makeGroupData(6, 10, 1.5);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: const Color(0xff2c4260),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  makeTransactionsIcon(),
                  const SizedBox(
                    width: 38,
                  ),
                  const Text(
                    'Transactions',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  const Text(
                    'state',
                    style: TextStyle(color: Color(0xff77839a), fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(
                height: 38,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: BarChart(
                    BarChartData(
                      maxY: 20,
                      barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.grey,
                            getTooltipItem: (_a, _b, _c, _d) => null,
                          ),
                          touchCallback: (response) {
                            if (response.spot == null) {
                              setState(() {
                                touchedGroupIndex = -1;
                                showingBarGroups = List.of(rawBarGroups);
                              });
                              return;
                            }

                            touchedGroupIndex = response.spot.touchedBarGroupIndex;

                            setState(() {
                              if (response.touchInput is FlLongPressEnd ||
                                  response.touchInput is FlPanEnd) {
                                touchedGroupIndex = -1;
                                showingBarGroups = List.of(rawBarGroups);
                              } else {
                                showingBarGroups = List.of(rawBarGroups);
                                if (touchedGroupIndex != -1) {
                                  double sum = 0;
                                  for (BarChartRodData rod
                                  in showingBarGroups[touchedGroupIndex].barRods) {
                                    sum += rod.y;
                                  }
                                  final avg =
                                      sum / showingBarGroups[touchedGroupIndex].barRods.length;

                                  showingBarGroups[touchedGroupIndex] =
                                      showingBarGroups[touchedGroupIndex].copyWith(
                                        barRods: showingBarGroups[touchedGroupIndex].barRods.map((rod) {
                                          return rod.copyWith(y: avg);
                                        }).toList(),
                                      );
                                }
                              }
                            });
                          }),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: SideTitles(
                          showTitles: true,
                          textStyle: TextStyle(
                              color: const Color(0xff7589a2),
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                          margin: 20,
                          getTitles: (double value) {
                            switch (value.toInt()) {
                              case 0:
                                return 'Mn';
                              case 1:
                                return 'Te';
                              case 2:
                                return 'Wd';
                              case 3:
                                return 'Tu';
                              case 4:
                                return 'Fr';
                              case 5:
                                return 'St';
                              case 6:
                                return 'Sn';
                              default:
                                return '';
                            }
                          },
                        ),
                        leftTitles: SideTitles(
                          showTitles: true,
                          textStyle: TextStyle(
                              color: const Color(0xff7589a2),
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                          margin: 32,
                          reservedSize: 14,
                          getTitles: (value) {
                            if (value == 0) {
                              return '1K';
                            } else if (value == 10) {
                              return '5K';
                            } else if (value == 19) {
                              return '10K';
                            } else {
                              return '';
                            }
                          },
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: showingBarGroups,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        y: y1,
        color: leftBarColor,
        width: width,
      ),
      BarChartRodData(
        y: y2,
        color: rightBarColor,
        width: width,
      ),
    ]);
  }

  Widget makeTransactionsIcon() {
    const double width = 4.5;
    const double space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.white.withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
      ],
    );
  }

}