import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlineshoppingbackendapp/screens/partials/navigation_drawer.dart';

import 'brain.dart';
import 'firestore_handler.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key key, @required this.position}) : super();

  final int position;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _avatarPath = "https://www.partyrama.co.uk/wp-content/uploads/2017/09/"
      "star-wars-c-3po-cardboard-face-mask-product-image.jpg";

  String status = "Online";
  final _name = "C-3PO";

  Map _lastResponse;

  List<Widget> chatLog = [];

  final _textEditingController = TextEditingController();

  final GlobalKey<ScaffoldState> _globalKey = new GlobalKey();

  ChatEngine _chatEngine = new ChatEngine();
  FirestoreManager _firestoreManager = new FirestoreManager();

  ScrollController _scrollController = ScrollController();

  List<DocumentSnapshot> _productSearch;

  List<DocumentSnapshot> _cart = [];
  List<Map> _giftCart = [];

  String _failedProductSearch =
      "Couldn't find the item that you're looking for";

  void _submitQuery() async {
    //check text field is not empty
    if (_textEditingController.text.isNotEmpty) {
      //send query to chat bot
      chatLog.add(UserChatBubble(
        message: _textEditingController.text,
      ));

      //run the user's query through the neural network
      var _reply = await _chatEngine.detectIntent(_textEditingController.text);

      if (_reply[0] == 200) {
        //intercept product search intent and render correct chat bubble
        print(_reply[1]["queryResult"]["action"]);

        if (_reply[1]["queryResult"]["action"]
            .toString()
            .contains("gift_card.")) {
          String _action = _reply[1]["queryResult"]["action"].toString();
          //add gift card to cart
          _giftCart.add({"amount": int.parse(_action.split(".")[1])});

          print(_giftCart.toString());

          //build chat bubble
          chatLog.add(SystemChatBubble(
            message: _reply[1]["queryResult"]["fulfillmentText"],
            products: null,
          ));
        } else if (_reply[1]["queryResult"]["action"] == "product.search") {
          //query database for the product
          _productSearch = await _firestoreManager
              .productSearch(_reply[1]["queryResult"]["parameters"]["product"]);

          //build chat bubble
          chatLog.add(SystemChatBubble(
            message: _productSearch.isEmpty
                ? _failedProductSearch
                : _reply[1]["queryResult"]["fulfillmentText"],
            products: _productSearch.isEmpty ? null : _productSearch,
          ));
        } else if (_reply[1]["queryResult"]["action"] ==
            "product.search.select.number") {
          //display selected item to the user

          int _selectedNumber =
              _reply[1]["queryResult"]["parameters"]["number"][0] - 1;
          //build chat bubble
          if (_selectedNumber <= _productSearch.length) {
            //valid number show item
            chatLog.add(SystemChatBubble(
              message: _productSearch.isEmpty
                  ? _failedProductSearch
                  : _reply[1]["queryResult"]["fulfillmentText"],
              products: _productSearch.isEmpty
                  ? null
                  : [_productSearch[_selectedNumber]],
            ));
          } else {
            //index error return error message
            chatLog.add(SystemChatBubble(
                message: "Can't find the item you're looking for. Try again",
                products: null));
          }
        } else if (_reply[1]["queryResult"]["action"] ==
            "product.search.select.number.yes") {
          //check to see if the user wanted a gift card or not

          //add product to the cart
          int selectedItem = _reply[1]["queryResult"]["outputContexts"][0]
                  ["parameters"]["number"][0] -
              1;

          _cart.add(_productSearch[selectedItem]);

          //build the chat bot
          chatLog.add(SystemChatBubble(
            message: _reply[1]["queryResult"]["fulfillmentText"],
            products: null,
          ));
        } else if (_reply[1]["queryResult"]["action"] == "cart.check") {
          //display the user's cart

          //build chat bubble
          chatLog.add(SystemChatBubble(
            message: _cart.isEmpty && _giftCart.isEmpty
                ? "Cart is empty"
                : _reply[1]["queryResult"]["fulfillmentText"],
            products: _cart.isEmpty ? null : _cart,
          ));

          //display gift card credit
          int sum = 0;
          _giftCart.forEach((element) {
            sum = sum + element["amount"];
          });

          chatLog.add(sum > 0
              ? SystemChatBubble(
                  message: "You have £$sum worth of gift cards in your cart.",
                  products: null,
                )
              : Container());
        } else if (_reply[1]["queryResult"]["action"] == "item.remove") {
          // get item from response
          String product = _reply[1]["queryResult"]["parameters"]["product"]
              .toString()
              .toLowerCase();

          //check if item is a gift card
          if (product != null && (_giftCart.isNotEmpty || _cart.isNotEmpty)) {
            if (product.contains("gift") && product.contains(" card")) {
              _giftCart.clear();
            } else {
              //remove product
              _cart.removeWhere((item) =>
                  item["chatbot keyword"].toString().toLowerCase() == product);
            }

            //build chat bubble
            chatLog.add(SystemChatBubble(
                message: _reply[1]["queryResult"]["fulfillmentText"],
                products: null));
          } else {
            //build chat bubble
            chatLog.add(SystemChatBubble(
                message: "Couldn't find a matching product in your basket",
                products: null));
          }
        } else if (_reply[1]["queryResult"]["action"] == "order.cancel") {
          if (_reply[1]["queryResult"]["allRequiredParamsPresent"] == true) {
            String orderNumber = _reply[1]["queryResult"]["parameters"]
                    ["order_number"]
                .toString();

            bool res = await _firestoreManager.modifyOrder(
                "order.cancel", orderNumber);

            if (res == true) {
              //build chat bubble
              chatLog.add(SystemChatBubble(
                  message: _reply[1]["queryResult"]["fulfillmentText"],
                  products: null));
            } else {
              //build chat bubble
              chatLog.add(SystemChatBubble(
                  message: "Please check your order number and try again",
                  products: null));
            }
          } else {
            //build chat bubble
            chatLog.add(SystemChatBubble(
                message: _reply[1]["queryResult"]["fulfillmentText"],
                products: null));
          }
        } else if (_reply[1]["queryResult"]["action"] == "refund.request") {

          //check that all required information has been provided by the user
          if (_reply[1]["queryResult"]["allRequiredParamsPresent"] == true) {
            String orderNumber = _reply[1]["queryResult"]["parameters"]
            ["order_number"]
                .toString();

            String comment = _reply[1]["queryResult"]["parameters"]
            ["user_comment"]
                .toString();

            bool res = await _firestoreManager.modifyOrder(
                "refund.request", orderNumber, comment);

            if (res == true) {
              //build chat bubble
              chatLog.add(SystemChatBubble(
                  message: _reply[1]["queryResult"]["fulfillmentText"],
                  products: null));
            } else {
              //build chat bubble
              chatLog.add(SystemChatBubble(
                  message: "Please check your order number and try again",
                  products: null));
            }
          } else {
            //build chat bubble
            chatLog.add(SystemChatBubble(
                message: _reply[1]["queryResult"]["fulfillmentText"],
                products: null));
          }

        } else if (_reply[1]["queryResult"]["action"] == "order.change") {

          //check that all required information has been provided by the user
          if (_reply[1]["queryResult"]["allRequiredParamsPresent"] == true) {
            String orderNumber = _reply[1]["queryResult"]["parameters"]
            ["order_number"]
                .toString();

            String comment = _reply[1]["queryResult"]["parameters"]
            ["user_comment"]
                .toString();

            bool res = await _firestoreManager.modifyOrder(
                "order.change", orderNumber, comment);

            if (res == true) {
              //build chat bubble
              chatLog.add(SystemChatBubble(
                  message: _reply[1]["queryResult"]["fulfillmentText"],
                  products: null));
            } else {
              //build chat bubble
              chatLog.add(SystemChatBubble(
                  message: "Please check your order number and try again",
                  products: null));
            }
          } else {
            //build chat bubble
            chatLog.add(SystemChatBubble(
                message: _reply[1]["queryResult"]["fulfillmentText"],
                products: null));
          }

        } else if (_reply[1]["queryResult"]["action"] == "check_out") {

          //check that all required information has been provided by the user
          if (_reply[1]["queryResult"]["allRequiredParamsPresent"] == true) {
            //check that the cart is not empty
            print("am making a receipt");

            chatLog.add(SystemChatBubble(
              message: "Processing please wait...",
              products: null,
            ));
            setState(() {});

            //pass payment credentials to server for validation
            String email = _reply[1]["queryResult"]["parameters"]["email"];
            String password =
                _reply[1]["queryResult"]["parameters"]["password"];

            print("Email $email\nPassword: $password\n");

            String _userInfo =
                await _firestoreManager.authenticateUser(email, password);

            if (_userInfo != null) {
              //save order to the system and print the receipt

              //create receipt object and write to database
              Map payDetails = {
                "security code": _reply[1]["queryResult"]["parameters"]
                    ["security-code"],
                "email": _reply[1]["queryResult"]["parameters"]["email"],
                "card number": _reply[1]["queryResult"]["parameters"]
                    ["card-number"],
              };

              await _firestoreManager.createReceipt(
                  payDetails, _userInfo, _giftCart, _cart);

              //Show chat bot response
              chatLog.add(SystemChatBubble(
                message: _reply[1]["queryResult"]["fulfillmentText"],
                products: null,
              ));
            } else {
              chatLog.add(SystemChatBubble(
                message: "Unable to authenticate account. "
                    "Please check credentials and try again",
                products: null,
              ));
            }
          } else if (![_cart.isEmpty, _giftCart.isEmpty].contains(false)) {
            //check that the carts are not empty
            chatLog.add(SystemChatBubble(
              message: "Add some items to your cart first",
              products: null,
            ));
          } else {
            //Show chat bot response
            chatLog.add(SystemChatBubble(
              message: _reply[1]["queryResult"]["fulfillmentText"],
              products: null,
            ));
          }
        } else {
          chatLog.add(SystemChatBubble(
            message: _reply[1]["queryResult"]["fulfillmentText"],
            products: null,
          ));
        }
      } else {
        chatLog.add(SystemChatBubble(
            message:
                "So sorry having a little trouble calling home, please do comeback later",
            products: null));
      }

      //update UI
      setState(() {});

      await Future.delayed(Duration(microseconds: 280));

      //TODO: Smoother scroll transition
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);

      //clear text field
      _textEditingController.clear();

      //save the response so it can be used for future queries if needed
      _lastResponse = _reply.length == 2 ? _reply[1] : null;
    }
  }

  Future getImage(AsyncSnapshot snapshot) async {
    final image = await ImagePicker.pickImage(source: ImageSource.gallery);

    String img64 = base64Encode(image.readAsBytesSync());

    http.Response res = await http.post(
      "http://${snapshot.data["server_endpoint"]}.eu-west-2.compute.amazonaws.com/detect",
      body: jsonEncode({"img": img64}),
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Headers": "Content-Type"
      },
    );

    print(res.statusCode);

    if (res.statusCode == 200 && json.decode(res.body)["predictions"].length > 0) {
      var data = json.decode(res.body);
      _textEditingController.text = "i want ${data["predictions"][0]["class"]}";
      _submitQuery();
      _textEditingController.clear();

    } else {
      _globalKey.currentState.showSnackBar(
          SnackBar(
            content: Text("Unable to connect to server"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          )
      );
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        elevation: 5.0,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(_avatarPath),
              minRadius: 20,
            ),
            SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _name,
                  style: TextStyle(color: Colors.black),
                  overflow: TextOverflow.clip,
                ),
                Text(
                  status,
                  style: TextStyle(
                      color:
                          status == "Online" ? Colors.green : Colors.grey[400],
                      fontSize: 12),
                ),
              ],
            )
          ],
        ),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection("user_settings")
            .document("qmHWLXV17pvLEWclXcKc").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return snapshot.data["chatbot"] == false ? Container(
            child: Center(
              child: Text("Chatbot disabled, reactivate from the settings")),
          ):
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: chatLog.length,
                  padding: const EdgeInsets.all(15),
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemBuilder: (BuildContext context, int index) {
                    return chatLog[index];
                  },
                ),
              ),

              Positioned(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 0,
                right: 0,
                height: 170,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0,0.0,8.0,15.0),
                  child: _textFieldWidget(snapshot),
                ),
              )

            ],
          );
        }
      ),
      drawer:   NavDrawer(currentPage: widget.position),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Widget _textFieldWidget(AsyncSnapshot snapshot) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35.0),
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 3), blurRadius: 5, color: Colors.grey)
                  ]),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 15),
                  InkWell(
                    child: Icon(
                      Icons.tag_faces,
                      color: Colors.grey,
                    ),
                    onTap: () async {
                      await getImage(snapshot);
                    }

                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                          hintText: "Enter Query....",
                          border: InputBorder.none),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(width: 15),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration:
                BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            child: InkWell(
              child: Center(child: Icon(Icons.send, color: Colors.white)),
              splashColor: Colors.grey,
              onTap: () {
                _submitQuery();
              },
            ),
          )
        ],
      ),
    );
  }

  Future<String> _inputDialog(BuildContext context) async {
    String endPoint;
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Server EndPoint'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                    autofocus: true,
                    onChanged: (value) {
                      endPoint = value;
                    },
                  ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Done'),
              onPressed: () {
                Navigator.of(context).pop(endPoint);
              },
            ),
          ],
        );
      },
    );
  }
}

class UserChatBubble extends StatelessWidget {

  UserChatBubble({this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric( vertical: 7),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .6),
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Text(
                  message,
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
          SizedBox(width: 30),
          Text(
            TimeOfDay.fromDateTime(DateTime.now()).format(context),
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class SystemChatBubble extends StatelessWidget {
  SystemChatBubble({this.message, this.intent, this.products});

  final bool isMe = false;
  final String message, intent;
  final List<DocumentSnapshot> products;
  final _imageUrl = "https://mosaic03.ztat.net/vgs/media/catalog-lg/";

  Widget productReel(BuildContext context) {
    //TODO: Build product reel
    return Container(
      height: 350.00,
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: Column(
                children: <Widget>[
                  Image.network(_imageUrl + products[index]["media"][0]["path"],
                      fit: BoxFit.fitHeight, width: 160.00, height: 224.00),
                  Container(
                    width: 135,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        products[index]["name"],
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    width: 135,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                      ),
                      child: Text(products[index]["sku"],
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 135,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 14.0,
                        ),
                        child: Text(
                          products[index]["price"]["promotional"] == null
                              ? products[index]["price"]["original"]
                              : products[index]["price"]["promotional"],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 135,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          "${index + 1} / ${products.length}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10.0,
                              color: Colors.blueGrey),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric( vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Text(
              TimeOfDay.fromDateTime(DateTime.now()).format(context),
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(width: 30),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .6),
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(message, style: TextStyle(color: Color(0xfff9f9f9)),),
                    products == null ? Container() : SizedBox(width: 15.0),
                    products == null ? Container() : productReel(context)
                  ],
                ),
              ),
            ],

          ),
        ],
      ),
    );
  }
}
