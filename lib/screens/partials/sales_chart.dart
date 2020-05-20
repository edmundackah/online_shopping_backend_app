import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesChart extends StatefulWidget {
  SalesChart({Key key, this.position}) : super(key: key);

  final int position;

  @override
  _SalesChartState createState() => _SalesChartState();
}

class _SalesChartState extends State<SalesChart>{

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
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection("requests").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          return AspectRatio(
            aspectRatio: 1,
            child: Card(
              elevation: 5.0,
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

    print(dateComponent);

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

}