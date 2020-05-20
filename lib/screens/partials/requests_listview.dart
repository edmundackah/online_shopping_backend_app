import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:onlineshoppingbackendapp/screens/partials/request_order_card.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestListView extends StatefulWidget {
  RequestListView({Key key, this.currentPage, this.scaffoldKey}) : super(key: key);

  final int currentPage;
  final GlobalKey<ScaffoldState> scaffoldKey;

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
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        return ListView.builder(
            itemCount: snapshot.data.documents.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Slidable(

                key: Key(snapshot.data.documents[index].toString()),
                actionExtentRatio: 0.25,
                actionPane: SlidableStrechActionPane(),
                closeOnScroll: true,
                controller: SlidableController(),

                child: Padding(
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

                      if (snapshot.data.documents.length > 2) {
                        showMaterialModalBottomSheet(
                            context: context,
                            elevation: 5.0,
                            isDismissible: true,
                            builder: (context, scrollController) =>
                                _bottomSheet(snapshot, index)
                        );

                      } else {
                        final snackBar = SnackBar(
                            content: Text("Can't find corresponding order"),
                          elevation: 5.0,
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.redAccent,
                        );
                        widget.scaffoldKey.currentState.showSnackBar(snackBar);
                      }

                    },
                  ),
                ),

                secondaryActions: <Widget>[
                  InkWell(
                    onTap: () async {
                      var orderDoc = await Firestore.instance.collection("orders")
                          .document(snapshot.data.documents[index]["docID"]).get();

                      var userDoc = await Firestore.instance.collection("users")
                          .document(orderDoc["doc id"]).get();

                      String url = "mailto:<${userDoc["email"]}>?"
                          "subject=<Order ${orderDoc["orderNo"]}>&body=<body>";

                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        //throw 'Could not launch $url';
                        final snackBar = SnackBar(
                          content: Text("E-mail app not found on device"),
                          duration: Duration(seconds: 3),
                          backgroundColor: Colors.redAccent,
                        );
                        widget.scaffoldKey.currentState.showSnackBar(snackBar);
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
                        await myTransaction.delete(snapshot.data.documents[index].reference);

                        final snackBar = SnackBar(
                          content: Text("Request Closed"),
                          elevation: 4.0,
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.green,
                        );
                        widget.scaffoldKey.currentState.showSnackBar(snackBar);

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
    );
  }

  Widget _bottomSheet(AsyncSnapshot snapshot, int index) {

    final String orderID = snapshot.data.documents[index]["orderNo"];
    print(orderID);

    return StreamBuilder(
        stream: Firestore.instance.collection("orders")
            .where("orderNo", isEqualTo: orderID).limit(1).snapshots(),

        builder: (BuildContext context, AsyncSnapshot snapshot){
          if (!snapshot.hasData) return CircularProgressIndicator();

          return Container(
            height: MediaQuery.of(context).size.height * 0.55,
            child: RequestOrderCard(
              snapshot: snapshot,
              index: 0,
              requestDocRef: snapshot.data.documents[0].reference,
              elevation: 0.0,
              cardNumber: snapshot.data.documents[0]["payment info"]["card number"].
              toString().replaceAll(".0", ""),

              scrollDirection: Axis.horizontal,
              scaffoldKey: widget.scaffoldKey,
            ),
          );
        }
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