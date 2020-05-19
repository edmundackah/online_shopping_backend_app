import 'package:barcode_flutter/barcode_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

class RequestOrderCard extends StatefulWidget {
  RequestOrderCard({Key key, @required this.index, @required this.snapshot,
    @required this.scaffoldKey, @required this.cardNumber,
    @required this.scrollDirection, this.elevation}) : super();

  final int index;
  final double elevation;
  final AsyncSnapshot snapshot;
  final String cardNumber;
  final Axis scrollDirection;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _RequestOrderCardState createState() => _RequestOrderCardState();
}

class _RequestOrderCardState extends State<RequestOrderCard> {

  final _imageUrl = "https://mosaic03.ztat.net/vgs/media/catalog-lg/";

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.elevation == null ? 3.0 : widget.elevation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: BarCodeImage(
                  params: Code39BarCodeParams(
                    widget.snapshot.data.documents[widget.index]["orderNo"],
                    lineWidth: 2.0,
                    barHeight: 45,
                    withText: true,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
                height: 200.0,
                child: _productsListView(widget.snapshot, widget.index)
            ),
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 12.0, bottom: 12.0),
                child: Text("Amount charged", style: TextStyle(fontSize: 18.0)),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 80.0, top: 12.0, bottom: 12.0),
                  child: Text("£${_getTotalPrice(widget.snapshot, widget.index).toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 18.0)
                  )
              )
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 21.0, bottom: 15.0),
                child: Image.asset("assets/images/visa.png", height: 28.0),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 10.0, bottom: 30.0),
                  child: Text("....",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35.0),
                  )
              ),
              Padding(
                padding: EdgeInsets.only(left: 12.0, bottom: 11.0),
                child: Text(widget.cardNumber.substring(widget.cardNumber.length - 4),
                    style: TextStyle(fontSize: 20.0)
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 60.0, bottom: 16.0),
                child: FlatButton.icon(
                    onPressed: () async {
                      await Firestore.instance.runTransaction((Transaction myTransaction) async {
                        await myTransaction.delete(widget.snapshot.data.documents[widget.index].reference);

                        final snackBar = SnackBar(
                          content: Text("Order refunded"),
                          elevation: 4.0,
                          duration: Duration(seconds: 2),
                        );
                        widget.scaffoldKey.currentState.showSnackBar(snackBar);

                      });
                    },
                    icon: Icon(Icons.refresh, color: Colors.green,),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.green)
                    ),
                    label: Text("Refund",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 18.0,))
                ),
              )
            ],
          ),
        ],
      ),
    );
  }


  double _getTotalPrice(AsyncSnapshot snapshot, int index) {
    double _totalCost = 0;

    snapshot.data.documents[index]["products"].forEach((product){
      int _qty = product["qty"] == null ? 1 : product["qty"];

      print(_qty);

      _totalCost = (double.parse(product["price"]) * _qty) + _totalCost;
    });
    return _totalCost;
  }

  Widget _productsListView(AsyncSnapshot snapshot, int number) {
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: snapshot.data.documents[number]["products"].length,
        itemBuilder: (context, index){

          String _sku = snapshot.data.documents[number]["products"][index]["sku"].toString();

          var _qty = snapshot.data.documents[number]["products"][index]["qty"] == null ? 1 :
          snapshot.data.documents[number]["products"][index]["qty"];

          return Padding(
            padding: const EdgeInsets.only(left: 18.0, bottom: 25.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _sku != "SYS-GIFT-CARD" ? StreamBuilder(
                    stream: Firestore.instance.collection("products")
                        .where("sku", isEqualTo: _sku).snapshots(),
                    builder: (context, productSnapshot) {
                      if (!productSnapshot.hasData) return Center(child: CircularProgressIndicator());

                      final _imageUrlDB = _imageUrl + productSnapshot.data.documents[0]["media"][0]["path"];

                      return Container(
                        width: 90.0,
                        height: 140.0,
                        child: Image(
                          image: AdvancedNetworkImage(
                            _imageUrlDB,
                            useDiskCache: true,
                            cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                          ),
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                ) : Container(
                  child: SizedBox(
                    height: 90.0,
                    width: 90.0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 60.0),
                      child: Icon(Icons.card_giftcard, size: 100.0, color: Colors.grey,),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Container(
                        width: 150.0,
                        child: Text(
                          snapshot.data.documents[number]["products"][index]["name"],
                          style: TextStyle(fontSize: 17.0),
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, top: 8.0),
                      child: Container(
                        child: Text(
                          "(${snapshot.data.documents[number]["products"][index]["sku"]})",
                          style: TextStyle(fontSize: 13.0, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, top: 10.0),
                      child: Text(
                          "£${snapshot.data.documents[number]["products"][index]["price"]}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.blueGrey)
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, top: 5.0),
                      child: FlatButton.icon(
                          icon: Icon(Icons.delete, color: Colors.redAccent,),
                          onPressed: () => _removeItem(
                              snapshot.data.documents[number].documentID,
                              index),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0),
                              side: BorderSide(color: Colors.red)
                          ),
                          label: Text("Remove", style: TextStyle(color: Colors.redAccent),
                          )
                      ),
                    ),
                  ],
                ),
                _qtyWidget(snapshot.data.documents[number].documentID ,_qty, index),
              ],
            ),
          );
        });
  }

  void _removeItem(String docID, int index) {

    print("doc: $docID    $index");
    //remove item from order
    final DocumentReference postRef = Firestore.instance.collection("orders").document(docID);

    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(postRef);
      if (postSnapshot.exists) {

        var _products = postSnapshot.data["products"];

        print("before: ${_products.length}");
        print(_products[index]["name"]);
        _products.removeWhere((item) => item["name"] == _products[index]["name"]);
        print("after: ${_products.length}");

        await tx.update(postRef, <String, dynamic>{'products': _products});

        //remove an item from the basket
        final snackBar = SnackBar(
          content: Text("Item refunded"),
          elevation: 4.0,
          duration: Duration(seconds: 2),
        );
        widget.scaffoldKey.currentState.showSnackBar(snackBar);
      }
    });
  }

  Widget _qtyWidget(String docID, var qty, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 37.0),
      child: Container(
        decoration: BoxDecoration(border: Border.all()),
        height: 120.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Icon(Icons.add, size: 20.0, color: Colors.black),
                ),
                onTap: () => _updateQuantity(docID, index, qty + 1),
              ),
              Container(
                  width: 22.0,
                  child: Divider(
                    color: Colors.black,
                    thickness: 1.5,
                  )
              ),
              Text("$qty", style: TextStyle(color: Colors.black),),
              Container(
                  width: 22.0,
                  child: Divider(
                    color: Colors.black,
                    thickness: 1.5,
                  )
              ),
              InkWell(
                  onTap: () => _updateQuantity(docID, index, qty - 1),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Icon(Icons.remove, size: 18.0, color: Colors.black),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _updateQuantity(String docID, int index, var quanity) {
    if (quanity > 0) {
      final DocumentReference postRef = Firestore.instance.collection("orders").document(docID);

      Firestore.instance.runTransaction((Transaction tx) async {
        DocumentSnapshot postSnapshot = await tx.get(postRef);
        if (postSnapshot.exists) {

          var _products = postSnapshot.data["products"];
          _products[index]["qty"] = quanity;
          await tx.update(postRef, <String, dynamic>{'products': _products});
        }
      });
    } else {
      //remove an item from the basket
      final snackBar = SnackBar(
        content: Text("Quantity can't be below than 1"),
        duration: Duration(seconds: 3),
      );
      widget.scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }
}