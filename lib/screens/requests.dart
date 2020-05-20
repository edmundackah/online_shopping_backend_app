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

class _RequestsScreenState extends State<RequestsScreen> with TickerProviderStateMixin {

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  TabController _tabController;

  int _selectedIndex = 0;

  @override
  void initState() {
    _tabController = new TabController(
        length: 4,
        vsync: this,
        initialIndex: _selectedIndex
    );

    _tabController.addListener(() {

      setState(() {
        _selectedIndex = _tabController.index;

        _tabController.animateTo(
            _tabController.index,
            duration: Duration(milliseconds: 300)
        );
      });


    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        key: _scaffoldKey,
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
              onItemSelected: (index) {

                setState(() {
                  _selectedIndex = index;

                  _tabController.animateTo(
                      _selectedIndex,
                      duration: Duration(milliseconds: 400)
                  );
                });
              },
              items: [
                FlashyTabBarItem(
                  icon: Icon(Icons.view_list,
                    color: Color.fromRGBO(231, 129, 109, 1.0)
                  ),
                  title: Text('All Requests',
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Color.fromRGBO(231, 129, 109, 1.0)
                      )),
                ),
                FlashyTabBarItem(
                  icon: Icon(Icons.monetization_on,
                      color: Color.fromRGBO(231, 129, 109, 1.0)
                  ),
                  title: Text('Refund Request',
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Color.fromRGBO(231, 129, 109, 1.0)
                      )),
                ),
                FlashyTabBarItem(
                  icon: Icon(Icons.remove_shopping_cart,
                      color: Color.fromRGBO(231, 129, 109, 1.0)
                  ),
                  title: Text('Cancel Order',
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Color.fromRGBO(231, 129, 109, 1.0)
                      )),
                ),
                FlashyTabBarItem(
                  icon: Icon(Icons.edit,
                      color: Color.fromRGBO(231, 129, 109, 1.0)
                  ),
                  title: Text('Change Order',
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Color.fromRGBO(231, 129, 109, 1.0)
                      )),
                ),
              ],
            ),
          ),
        ),
        drawer: NavDrawer(currentPage: 1),
        body: TabBarView(
          controller: _tabController,
            children: [
              RequestListView(currentPage: 0, scaffoldKey: _scaffoldKey),
              RequestListView(currentPage: 1, scaffoldKey: _scaffoldKey),
              RequestListView(currentPage: 2, scaffoldKey: _scaffoldKey),
              RequestListView(currentPage: 3, scaffoldKey: _scaffoldKey)
            ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

}