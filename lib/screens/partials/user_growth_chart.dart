import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  final Color barBackgroundColor = const Color(0xff77839a);
  final Duration animDuration = const Duration(milliseconds: 250);

  double highestCount = 0;

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

    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        elevation: 5.0,
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
                    width: 25,
                  ),
                  const Text(
                    'User Growth',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  const Text(
                    'yearly',
                    style: TextStyle(color: Color(0xff77839a), fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: barBackgroundColor,
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
              const SizedBox(
                height: 38,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: StreamBuilder(
                    stream: Firestore.instance.collection("users").snapshots(),
                    builder: (context, snapshot) {
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
      ),
    );
  }

  BarChartData mainBarData(AsyncSnapshot snapshot) {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String yearNum;
              switch (group.x.toInt()) {
                case 0:
                  yearNum = '${DateTime.now().year - 6}';
                  break;
                case 1:
                  yearNum = '${DateTime.now().year - 5}';
                  break;
                case 2:
                  yearNum = '${DateTime.now().year - 4}';
                  break;
                case 3:
                  yearNum = '${DateTime.now().year - 3}';
                  break;
                case 4:
                  yearNum = '${DateTime.now().year - 2}';
                  break;
                case 5:
                  yearNum = '${DateTime.now().year - 1}';
                  break;
                case 6:
                  yearNum = '${DateTime.now().year - 0}';
                  break;
              }
              return BarTooltipItem(
                  yearNum + '\n' + (rod.y - 1).toString(),
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
                return '${DateTime.now().year - 6}';
              case 1:
                return '${DateTime.now().year - 5}';
              case 2:
                return '${DateTime.now().year - 4}';
              case 3:
                return '${DateTime.now().year - 3}';
              case 4:
                return '${DateTime.now().year - 2}';
              case 5:
                return '${DateTime.now().year - 1}';
              case 6:
                return '${DateTime.now().year - 0}';
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
            return makeGroupData(snapshot, 0, _getYearlyUserCount(0, snapshot), isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(snapshot, 1, _getYearlyUserCount(1, snapshot), isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(snapshot, 2, _getYearlyUserCount(2, snapshot), isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(snapshot, 3, _getYearlyUserCount(3, snapshot), isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(snapshot, 4, _getYearlyUserCount(4, snapshot), isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(snapshot, 5, _getYearlyUserCount(5, snapshot), isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(snapshot, 6, _getYearlyUserCount(6, snapshot), isTouched: i == touchedIndex);
          default:
            return null;
        }
      });

  double _getYearlyUserCount(int index, AsyncSnapshot snapshot) {
    //get number of users for corresponding year
    double userCount = 0;
    snapshot.data.documents.forEach((doc){
      if (doc["registered"]["date"].contains((DateTime.now().year - index).toString())) {
        userCount ++;
      }
    });

    userCount > highestCount ? highestCount = userCount : highestCount = highestCount;

    print("${DateTime.now().year - index}   $userCount");

    return userCount;
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
                return '${DateTime.now().year - 6}';
              case 1:
                return '${DateTime.now().year - 5}';
              case 2:
                return '${DateTime.now().year - 4}';
              case 3:
                return '${DateTime.now().year - 3}';
              case 4:
                return '${DateTime.now().year - 2}';
              case 5:
                return '${DateTime.now().year - 1}';
              case 6:
                return '${DateTime.now().year - 0}';
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
            y: highestCount,
            color: barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
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

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(
        animDuration + const Duration(milliseconds: 50));
    if (isPlaying) {
      refreshState();
    }
  }

}