import 'dart:io';

import 'package:bikingapp/EventScreen.dart';
import 'package:bikingapp/Helpers/AppConstants.dart';
import 'package:bikingapp/LoginPage1.dart';
import 'package:bikingapp/Models/SessionData.dart';
import 'package:bikingapp/PostsScreen.dart';
import 'package:bikingapp/ProfilePage1.dart';
import 'package:bikingapp/SignUpPage.dart';
import 'package:bikingapp/TilesPostsScreen.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final int index;
  HomeScreen({@required this.index});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  TabController _tabController;
  List<Widget> children = [];

  void comfirmExitFromUser() {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: new Text(
          'Are you sure?',
        ),
        content: new Text('Do you want to exit an app'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              exit(0);
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    );
  }

  void initState() {
    super.initState();
    children = [
      PostsScreen(
        initialPage: 0,
      ),
      // TilePostsScreen(),
      LoginPage1(),
      EventScreen(),
      SignUpPage(),
      ProfilePage1(
        userId: SessionData().data[0].id,
        name: SessionData().data[0].name,
      )
    ];
    _currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print(_currentIndex);
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        } else {
          comfirmExitFromUser();
        }
      },
      child: SafeArea(
          child: Scaffold(
        // appBar: AppBar(
        //   elevation: 0,
        //   backgroundColor: Colors.white,
        //   leading: Icon(FlutterIcons.search1_ant,
        //   size: 25,
        //     color: color1,
        //   ),
        //   title: Text(
        //     'Dashboard',
        //     style: TextStyle(
        //       color: color1,

        //     ),
        //   ),
        //   actions: [
        //     Container(
        //   margin: EdgeInsets.only(right: 15),
        //   child: IconButton(
        //     onPressed: () {
        //       Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               builder: (context) => ProfilePage1(userId: SessionData().data[0].id, name: SessionData().data[0].name,)));
        //     },
        //     icon: ClipOval(
        //       child: Image(
        //         fit: BoxFit.cover,
        //         image: AssetImage('assets/images/biker.png'),
        //       ),
        //     ),
        //   ),
        // ),
        //   ],
        //   centerTitle: true,
        // ),
        bottomNavigationBar: BottomNavyBar(
          iconSize: 24,
          animationDuration: Duration(milliseconds: 500),
          selectedIndex: _currentIndex,
          onItemSelected: (index) => setState(() {
            _currentIndex = index;
          }),
          showElevation: true,
          items: [
            BottomNavyBarItem(
                activeColor: color1,
                inactiveColor: color2,
                icon: Icon(Icons.home),
                title: Text('Home')),
            BottomNavyBarItem(
                activeColor: color1,
                inactiveColor: color2,
                icon: Icon(Icons.search),
                title: Text('Search')),
            BottomNavyBarItem(
                activeColor: color1,
                inactiveColor: color2,
                icon: Icon(Icons.event_note),
                title: Text('Events')),
            BottomNavyBarItem(
                activeColor: color1,
                inactiveColor: color2,
                icon: Icon(Icons.settings),
                title: Text('Settings')),
            BottomNavyBarItem(
                activeColor: color1,
                inactiveColor: color2,
                icon: Icon(Icons.person),
                title: Text('Profile')),
          ],
        ),
        body: children[_currentIndex],
        // body: Container(
        //   color: Colors.white,
        //   child: DefaultTabController(
        //     length: 4,
        //     initialIndex: 0,
        //     child: Column(
        //       children: [
        //         TabBar(
        //           isScrollable: true,
        //           controller: _tabController,
        //           labelColor: color1,
        //           indicatorColor: Colors.redAccent,
        //           labelStyle: TextStyle(
        //             fontSize: 20,
        //             fontWeight: FontWeight.bold
        //           ),
        //             unselectedLabelColor: color2,
        //             unselectedLabelStyle: TextStyle(
        //               fontSize:14,
        //               fontWeight: FontWeight.normal
        //             ),
        //             indicatorSize: TabBarIndicatorSize.tab,
        //             // indicator: BoxDecoration(
        //             //   borderRadius: BorderRadius.only(
        //             //       topLeft: Radius.circular(12),
        //             //       topRight: Radius.circular(12)),
        //             //   color: Colors.blue[100],
        //             // ),
        //           tabs: <Widget>[
        //             new Tab(
        //               text: 'Home',
        //             ),
        //             new Tab(
        //               text: 'Posts',
        //             ),
        //             new Tab(
        //               text: 'Chats',
        //             ),
        //             new Tab(
        //               text: 'Settings',
        //             ),
        //           ]
        //         ),
        //         Expanded(
        //           child: TabBarView(
        //             children: <Widget>[
        //               LoginPage1(),
        //               PostsScreen(),
        //               SignUpPage(),
        //               SplashScreen(),
        //             ]
        //           )
        //         )
        //       ],
        //     ),
        //   ),
        // ),
      )),
    );
  }
}
