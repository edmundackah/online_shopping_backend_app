import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:barcode_flutter/barcode_flutter.dart';
import 'package:flutter/painting.dart';
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

  final _imageUrl = "https://mosaic03.ztat.net/vgs/media/catalog-lg/";

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

                final String _cardnumber = snapshot.data.
                documents[index]["payment info"]["card number"]
                    .toString().replaceAll(".0", "");

                double _totalCost = 0;

                snapshot.data.documents[index]["products"].forEach((product){
                  _totalCost = double.parse(product["price"]) + _totalCost;
                });

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
                              padding: const EdgeInsets.all(12.0),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ExpansionTile(
                            title: Text("Items", style: TextStyle(fontSize: 18.0),),
                            children: <Widget>[
                              SizedBox(
                                child: _productsListView(snapshot, index),
                              )
                            ],
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
                                child: Text("£$_totalCost",
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
                              child: Text(_cardnumber.substring(_cardnumber.length - 4),
                                  style: TextStyle(fontSize: 20.0)
                              ),
                            ),
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

  Widget _productsListView(AsyncSnapshot snapshot, int number) {
    return ListView.builder(
      shrinkWrap: true,
        itemCount: snapshot.data.documents[number]["products"].length,
        itemBuilder: (context, index){

          String _sku = snapshot.data.documents[number]["products"][index]["sku"].toString();

          return Padding(
            padding: const EdgeInsets.only(left: 18.0, bottom: 10.0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _sku != "SYS-GIFT-CARD" ? StreamBuilder(
                      stream: Firestore.instance.collection("products")
                          .where("sku", isEqualTo: _sku).snapshots(),
                      builder: (context, productSnapshot) {
                        if (!productSnapshot.hasData) return Center(child: CircularProgressIndicator());

                        return Image.network(
                            _imageUrl + productSnapshot.data.documents[0]["media"][0]["path"],
                          height: 130.0,
                          fit: BoxFit.contain,
                        );
                      }
                  ) : Container(
                    child: SizedBox(
                      height: 90.0,
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
                           width: 180.0,
                           child: Text(
                             snapshot.data.documents[number]["products"][index]["name"],
                             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                             maxLines: 2,
                             overflow: TextOverflow.fade,
                           ),
                         ),
                       ),
                       Padding(
                         padding: const EdgeInsets.only(left: 15.0, top: 8.0),
                         child: Container(
                           width: 180.0,
                           child: Text(
                             "(${snapshot.data.documents[number]["products"][index]["sku"]})",
                             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: Colors.grey),
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                           ),
                         ),
                       ),
                       Padding(
                         padding: const EdgeInsets.only(left: 18.0, top: 20.0),
                         child: Text(
                             "£${snapshot.data.documents[number]["products"][index]["price"]}",
                             style: TextStyle(
                                 fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.blueGrey)
                         ),
                       )
                     ],
                   )
                ],
              ),
          );
        });
  }
}
