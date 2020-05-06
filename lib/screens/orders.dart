import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:barcode_flutter/barcode_flutter.dart';
import 'package:onlineshoppingbackendapp/screens/partials/appbar.dart';
import 'package:onlineshoppingbackendapp/screens/partials/navigation_drawer.dart';

class OrdersScreen extends StatefulWidget {
  OrdersScreen({Key key, this.currentPage, this.bgColour}) : super(key: key);

  final int currentPage;
  final Color bgColour;

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: MyAppBar(
        bgColour: widget.bgColour,
        title: "Orders",
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection("orders").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            return ListView.builder(
              itemCount: !snapshot.hasData ? 0 : snapshot.data.documents.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    elevation: 3.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: BarCodeImage(
                                params: Code39BarCodeParams(
                                  snapshot.data.documents[index]["orderNo"],
                                  lineWidth: 2.0,
                                  barHeight: 45,
                                  withText: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: Text("Items", style: TextStyle(fontSize: 18.0),),
                          children: <Widget>[

                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
      drawer: NavDrawer(
        currentPage: widget.currentPage,
      ),
    );
  }
}
