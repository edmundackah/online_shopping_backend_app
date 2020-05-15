import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class RequestsChart extends StatefulWidget {
  RequestsChart({Key key, this.position, this.appColours}) : super(key: key);

  final int position;
  final List<Color> appColours;

  @override
  _RequestsChartState createState() => _RequestsChartState();
}

class _RequestsChartState extends State<RequestsChart>{
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection("requests").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
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
                        Icon(Icons.people, color: widget.appColours[widget.position],)
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
                              color: Colors.blueGrey),),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text("Customer Queries", style: TextStyle(
                              fontSize: 24.0, color: Colors.grey),),
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

}