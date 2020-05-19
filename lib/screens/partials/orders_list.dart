import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:barcode_flutter/barcode_flutter.dart';

import 'order_card.dart';

class OrderListView extends StatefulWidget {
  OrderListView({Key key, this.data, this.scrollDirection, this.scaffoldKey}) : super(key: key);

  final Stream data;
  final Axis scrollDirection;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _OrderListViewState createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {



  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
          stream: widget.data,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: widget.scrollDirection,
              itemCount: !snapshot.hasData ? 0 : snapshot.data.documents.length,
              itemBuilder: (context, index) {

                final String _cardnumber = snapshot.data.
                documents[index]["payment info"]["card number"]
                    .toString().replaceAll(".0", "");

                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: OrderCard(
                    snapshot: snapshot,
                    index: index,
                    cardNumber: _cardnumber,
                    scrollDirection: widget.scrollDirection,
                    scaffoldKey: widget.scaffoldKey,
                  ),
                );
              },
            );
          }),
    );
  }




}