import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class FirestoreManager {

  /*
  This future is used to populate the database with products,
  for the chat bot to query.
  */

  //scraping the Zalando API for products
  Future<List<DocumentSnapshot>> productSearch(String query) async {

    print("searching for: $query");

    await for (
    var docs in Firestore.instance.collection("products")
        .where("chatbot keyword", isEqualTo: query).limit(81).snapshots()){

      print(docs.documents[0]["name"]);

      print("found: ${docs.documents.length}");

      return docs.documents;
    }
  }

  Future<bool> modifyOrder(String reason, String orderNumber, [String comment]) async {

    print("searching for order: $orderNumber");

    await for (var docs in Firestore.instance.collection("orders")
        .where("orderNo", isEqualTo: orderNumber).limit(1).snapshots()) {

      if (docs.documents.isNotEmpty){
        //Write the order modification request to the database
        await Firestore.instance.collection("requests").document()
            .setData({
          "request": reason,
          "orderNo": orderNumber,
          "date": DateTime.now().toString(),
          "comment": comment == null ? null : comment,
          "docID": docs.documents[0].documentID
        });

        return true;
      } else {
        return false;
      }
    }
  }

  Future<Map> createReceipt(Map paymentDetails, String user,
      List<Map> giftCard, List<DocumentSnapshot> items) async {

    String orderNo = "3608${10005 + Random.secure().nextInt(9999999 - 10005)}";

    Map<String, dynamic> _receipt = {
      "products": [],
      "orderNo": orderNo,
      "date": DateTime.now().toString(),
      "doc id": user,
      "payment info": paymentDetails
    };

    items.forEach((element) {
      String price = element["price"]["promotional"] == null
          ? element["price"]["original"] : element["price"]["promotional"];

      String size;

      if (element["sizes"].length == 1) {
        size = element["sizes"].toString();
      } else {
        size = element["sizes"][Random().nextInt(element["sizes"].length - 1)];
      }

      _receipt["products"].add({
        "sku": element["sku"].toString(),
        "name": element["name".toString()],
        "size": size.toString(),
        "price": price.replaceAll("£", ""),
        "brand name": element["brand name"] == null ? "" : element["brand name"],
        "picture": element["media"][0]["path"].toString()
      });
    });

    //add gift cards to receipt
    giftCard.forEach((element) {

      String cardNumber = Uuid().v1();

      _receipt["products"].add({
        "sku": "SYS-GIFT-CARD",
        "name": "Gift Card",
        "price": element["amount"].toString(),
        "card number":cardNumber
      });
    });

    //Write the receipt to the database
    await Firestore.instance.collection("orders").document()
        .setData(_receipt);

    return _receipt;
  }

  Future<String> authenticateUser(String email, String password) async {
    print("searching for: $email");

    await for ( var docs in Firestore.instance.collection("users")
        .where("email", isEqualTo: email)
        .where("login.password", isEqualTo: password).limit(1).snapshots()){

      print(docs.documents[0]["name"]["first"]);

      return docs.documents.isNotEmpty ? docs.documents[0].documentID : null;
    }
  }

  Future<bool> requestCancellation(int orderNumber) async {

  }
}