import 'package:flutter/material.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  MyAppBar({Key key, @required this.bgColour, @required this.title}) : super(key: key);

  final Color bgColour;
  final String title;

  @override
  _MyAppBarState createState() => _MyAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(50.0);
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new AppBar(
      title: new Text(widget.title, style: TextStyle(fontSize: 19.0),),
      backgroundColor: widget.bgColour,
      centerTitle: true,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Icon(Icons.search),
        ),
      ],
      elevation: 5.0,
    );
  }

}