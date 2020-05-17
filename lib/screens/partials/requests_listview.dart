import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestListView extends StatefulWidget {
  RequestListView({Key key, this.currentPage}) : super(key: key);

  final int currentPage;

  @override
  _RequestListViewState createState() => _RequestListViewState();
}

class _RequestListViewState extends State<RequestListView> {

  final List<Stream> _dataStream = [
    Firestore.instance.collection("requests").snapshots(),

    Firestore.instance.collection("requests")
        .where("request", isEqualTo: "refund.request").snapshots(),

    Firestore.instance.collection("requests")
        .where("request", isEqualTo: "order.cancel").snapshots(),

    Firestore.instance.collection("requests")
        .where("request", isEqualTo: "order.change").snapshots()
  ];

  IconData _iconGenerator(String requestType) {
    List<IconData> _icons = [
        Icons.view_list, Icons.attach_money,
        Icons.remove_shopping_cart, Icons.edit
    ];

    switch (requestType) {
      case "order.cancel":
        return _icons[2];
        break;
      case "order.change":
        return _icons[3];
        break;
      case "refund.request":
        return _icons[1];
        break;
      default:
        return _icons[0];
        break;
    }
  }

  String _title(String requestType) {
    switch (requestType) {
      case "order.cancel":
        return "Cancellation";
        break;
      case "order.change":
        return "Order Amendment";
        break;
      case "refund.request":
        return "Refund Request";
        break;
      default:
        return "Unknown Request";
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _dataStream[widget.currentPage],
      builder: (index, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        return ListView.builder(
            itemCount: snapshot.data.documents.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(8.0,4.0,8.0,4.0),
                child: InkWell(
                  child: Card(
                    elevation: 3.0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12.0,5.0,12.0,12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 85,
                                  child: Text(
                                      _title(snapshot.data.documents[index]["request"]),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      fontSize: 17.0,
                                      color: Color.fromRGBO(231, 129, 109, 1.0)
                                    ),
                                  )
                              ),

                              Icon(
                                _iconGenerator(snapshot.data.documents[index]["request"]),
                                size: 30.0,
                                color: Color.fromRGBO(231, 129, 109, 1.0)
                              )
                            ],
                          ),

                          snapshot.data.documents[index]["comment"] == null ? Container() :
                              Padding(
                                padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width - 55,
                                    child: Text(
                                        snapshot.data.documents[index]["comment"],
                                      maxLines: 4,
                                      textAlign: TextAlign.justify,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(fontSize: 14.5),
                                    )
                                ),
                              ),

                          Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: <Widget>[

                                //padding
                                SizedBox(width: MediaQuery.of(context).size.width - 140),

                                Padding(
                                  padding: EdgeInsets.only(right: 5.0),
                                  child: Icon(Icons.date_range,
                                    size: 30.0,
                                    color: Color.fromRGBO(231, 129, 109, 1.0),
                                  ),
                                ),

                                Text(
                                  _dateBuilder(snapshot.data.documents[index]["date"]),
                                  style: TextStyle(fontSize: 15.5, color: Color.fromRGBO(231, 129, 109, 1.0)),
                                )
                              ],
                            ),
                          )

                        ],
                      ),
                    ),
                  ),
                  splashColor: Color.fromRGBO(231, 129, 109, 1.0),
                  onTap: () {
                    var bottomSheetController = showBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          margin: const EdgeInsets.only(top: 5, left: 15, right: 15),
                          height: 160,
                    ));
                  },
                ),
              );
            }
        );
      },
    );
  }

  String _dateBuilder(String date) {
    
    int monthNum = int.parse(date.split("-")[1]);
    print(monthNum);
    
    List<String> months = [
      "Jan", "Feb", "Mar",
      "Apr", "May", "June",
      "July", "Aug", "Sept",
      "Oct", "Nov", "Dec"
    ];
    return "${date.substring(8, 10)} ${months[monthNum - 1]}";
  }
}