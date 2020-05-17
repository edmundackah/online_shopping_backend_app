import 'package:flutter/material.dart';
import 'package:onlineshoppingbackendapp/screens/partials/appbar.dart';
import 'package:onlineshoppingbackendapp/screens/partials/navigation_drawer.dart';

import 'package:flashy_tab_bar/flashy_tab_bar.dart';

import 'partials/requests_listview.dart';

class RequestsScreen extends StatefulWidget {
  RequestsScreen({Key key, this.currentPage}) : super(key: key);

  final int currentPage;

  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {

  final PageStorageBucket bucket = PageStorageBucket();

  int _selectedIndex = 0;

  final List<Widget> _tabContent = [
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: new Text("Customer Queries", style: TextStyle(fontSize: 19.0),),
          backgroundColor: Colors.white,
          elevation: 6.0,
          centerTitle: true,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(Icons.search),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, kToolbarHeight),
            child: FlashyTabBar(
              selectedIndex: _selectedIndex,
              iconSize: 20.0,
              showElevation: false,
              onItemSelected: (index) => setState(() {
                _selectedIndex = index;
              }),
              items: [
                FlashyTabBarItem(
                  icon: Icon(Icons.view_list),
                  title: Text('All Requests', style: TextStyle(fontSize: 14.0)),
                ),
                FlashyTabBarItem(
                  icon: Icon(Icons.monetization_on),
                  title: Text('Refund Request'),
                ),
                FlashyTabBarItem(
                  icon: Icon(Icons.remove_shopping_cart),
                  title: Text('Cancel Order'),
                ),
                FlashyTabBarItem(
                  icon: Icon(Icons.edit),
                  title: Text('Change Order'),
                ),
              ],
            ),
          ),
        ),
        drawer: NavDrawer(currentPage: widget.currentPage),
        body: TabBarView(
            children: [
              RequestListView(currentPage: 0,),
              Card(color: Colors.blue,),
              Card(color: Colors.green,),
              Card()
            ],
        ),
      ),
    );
  }

}