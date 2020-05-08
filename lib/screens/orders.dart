import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:onlineshoppingbackendapp/screens/partials/appbar.dart';
import 'package:onlineshoppingbackendapp/screens/partials/navigation_drawer.dart';
import 'package:onlineshoppingbackendapp/screens/partials/orders_list.dart';

class OrdersScreen extends StatefulWidget {
  OrdersScreen({Key key, this.currentPage, this.bgColour}) : super(key: key);

  final int currentPage;
  final Color bgColour;

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: MyAppBar(
        bgColour: widget.bgColour,
        title: "Orders",
      ),
      body: OrderListView(
        data: Firestore.instance.collection("orders").snapshots(),
        scrollDirection: Axis.vertical,
        scaffoldKey: _scaffoldKey,
      ),
      drawer: NavDrawer(
        currentPage: widget.currentPage,
      ),
    );
  }

}
