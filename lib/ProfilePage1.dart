import 'dart:async';
import 'dart:convert';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:bikingapp/AddUpdateBike.dart';
import 'package:bikingapp/AvatarGlow.dart';
import 'package:bikingapp/CreateEvent.dart';
import 'package:bikingapp/Helpers/AppConstants.dart';
import 'package:bikingapp/Helpers/ShowNotificationHelper.dart';
import 'package:bikingapp/Models/SessionData.dart';
import 'package:bikingapp/Models/ViewProfile.dart';
import 'package:bikingapp/NewPost.dart';
import 'package:bikingapp/SplashScreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePage1 extends StatefulWidget {
  String userId;
  final String name;
  ProfilePage1({@required this.userId, @required this.name});
  @override
  _ProfilePage1State createState() => _ProfilePage1State();
}

class _ProfilePage1State extends State<ProfilePage1>
    with SingleTickerProviderStateMixin {
  List<String> _tabs = [
    'Icon(FlutterIcons.racing_helmet_mco)',
    'Icon(FlutterIcons.map_marked_alt_faw5s',
    'assets/images/posts.png'
  ];
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ViewProfile viewProfile;
  Future<ViewProfile> refresh;
  bool _loader = false;
  List<String> followersname;
  Route route;
  bool _isDialogShowing = false;
  bool _enabled = false;
  Timer shimmerTimer;
  int timerStart = 5;
  TabController _tabController;

  void initState() {
    super.initState();
    imageCache.clear();
    PaintingBinding.instance.imageCache.clear();
    getPosts(widget.userId);
    refresh = getprofile();
    _tabController = new TabController(vsync: this, length: 3);
    // route = ModalRoute.of(context);
  }

  void startMeetingTimer() async {
    const oneSec = const Duration(seconds: 1);
    print("this is timer => $timerStart");
    setState(() {
      _enabled = true;
    });
    shimmerTimer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (timerStart < 1) {
            print('inside time is over');
            _enabled = false;
            timerStart = 5;
            timer.cancel();
            shimmerTimer.cancel();
          } else {
            timerStart = timerStart - 1;
          }
        },
      ),
    );
  }

  void getPosts(String userId) async {
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.json;
    dio.options.headers['Authorization'] = 'Bearer ' + SessionData().token;
    setState(() {
      _loader = true;
    });
    var request;
    try {
      request = await dio.get('$commonapi/profile/viewProfile/' + userId);
      print(request.statusCode);
      if (request.statusCode == 200) {
        setState(() {
          _loader = false;
        });
        setState(() {
          viewProfile = ViewProfile.fromJson(request.data);
        });

        print(request.data.toString());
        refresh = getprofile();
      }
    } on DioError catch (e) {
      setState(() {
        _loader = false;
      });
      setState(() {
        viewProfile = ViewProfile.fromJson(e.response.data);
      });
    }
  }

  Future<ViewProfile> getprofile() async {
    followersname = [];
    setState(() {
      // viewProfile = ;
    });
    for (int i = 0; i < viewProfile.userDetails.followers.length; i++) {
      followersname.add(viewProfile.userDetails.followers[i].name);
    }
    return viewProfile;
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _loader,
      child: SafeArea(
        child: Scaffold(
            key: _scaffoldKey,
            body: DefaultTabController(
              // initialIndex: 2,
              length: _tabs.length, // This is the number of tabs.
              child: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    // These are the slivers that show up in the "outer" scroll view.
                    return <Widget>[
                      SliverOverlapAbsorber(
                        // This widget takes the overlapping behavior of the SliverAppBar,
                        // and redirects it to the SliverOverlapInjector below. If it is
                        // missing, then it is possible for the nested "inner" scroll view
                        // below to end up under the SliverAppBar even when the inner
                        // scroll view thinks it has not been scrolled.
                        // This is not necessary if the "headerSliverBuilder" only builds
                        // widgets that do not overlap the next sliver.
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context),
                        sliver: SliverAppBar(
                          elevation: 3,
                          // brightness: Brightness.dark,
                          forceElevated: true,
                          centerTitle: true,
                          snap: false,
                          floating: false,
                          title: widget.userId == SessionData().data[0].id
                              ? Text(
                                  SessionData().data[0].name,
                                  style: TextStyle(color: color1),
                                )
                              : Text(
                                  viewProfile != null
                                      ? viewProfile.userDetails.name
                                      : '',
                                  style: TextStyle(color: color1)),

                          leading: widget.userId == SessionData().data[0].id
                              ? Container()
                              : GestureDetector(
                                  onTap: () {
                                    // Navigator.pushReplacement(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => HomeScreen()));
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: color1,
                                  ),
                                ),
                          // shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.only(
                          //         bottomLeft: Radius.circular(15),
                          //         bottomRight: Radius.circular(15))),
                          // title: const Text(
                          //   'Profile',
                          //   style: TextStyle(color:color1),
                          // ), // This is the title in the app bar.
                          pinned: true,
                          expandedHeight: 400.0,
                          flexibleSpace: FlexibleSpaceBar(
                            // collapseMode: CollapseMode.none,
                            // title: Text(
                            //   'Omkar Gaikwad',
                            //   style: TextStyle(color:color1),
                            // ),
                            centerTitle: true,
                            titlePadding: EdgeInsets.all(50),
                            background: Center(
                              child: Container(
                                color: Colors.white,
                                margin: EdgeInsets.fromLTRB(10, 10, 10, 15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 120,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              openFollowers();
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: <Widget>[
                                                      Text(
                                                        'Followers',
                                                        style: TextStyle(
                                                            color: color1,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      Text(
                                                        viewProfile != null
                                                            ? viewProfile
                                                                .userDetails
                                                                .followers
                                                                .length
                                                                .toString()
                                                            : '0',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ]),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Container(
                                                    height: 40,
                                                    color: color1,
                                                    width: 1),
                                              ],
                                            ),
                                          ),
                                          AvatarGlow(
                                            endRadius: 70.0,
                                            glowColor: color1,
                                            child: Material(
                                              elevation: 8.0,
                                              shape: CircleBorder(),
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Colors.grey[100],
                                                child: Image.asset(
                                                  'assets/images/realbikeicon.png',
                                                  // height: 60,
                                                ),
                                                radius: 40.0,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                    height: 40,
                                                    color: color1,
                                                    width: 1),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    openFollowing();
                                                  },
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          'Following',
                                                          style: TextStyle(
                                                              color: color1,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        Text(
                                                          viewProfile != null
                                                              ? viewProfile
                                                                  .userDetails
                                                                  .following
                                                                  .length
                                                                  .toString()
                                                              : '0',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 15),
                                      height: 25,
                                      width:
                                          MediaQuery.of(context).size.width / 7,
                                      decoration: BoxDecoration(
                                        color: color2,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Colors.white, width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: color1,
                                            blurRadius: 5.0,
                                            offset: const Offset(0.0, 0.0),
                                          ),
                                        ],
                                        // shape: BoxShape.circle
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person,
                                            size: 15,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'Bio',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(top: 13),
                                        child: Text(
                                          'Omkar Rajaram Gaikwad\nBike Lover\nCoder\n MAHARASHTRIAN...',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        )),
                                    Container(
                                      margin:
                                          EdgeInsets.fromLTRB(40, 10, 40, 10),
                                      decoration: BoxDecoration(
                                        // color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.white, width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: color1,
                                            blurRadius: 5.0,
                                            offset: const Offset(0.0, 0.0),
                                          ),
                                        ],
                                        // shape: BoxShape.circle
                                      ),
                                      // height: 2,
                                      // child: Divider(
                                      //   thickness: 2,
                                      //   color: Colors.redAccent,
                                      // ),
                                    ),
                                    widget.userId == SessionData().data[0].id
                                        ? Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 40,
                                                  decoration: BoxDecoration(
                                                    color: color2,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 1.5),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: color1,
                                                        blurRadius: 10.0,
                                                        offset: const Offset(
                                                            0.0, 0.0),
                                                      ),
                                                    ],
                                                    // shape: BoxShape.circle
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  HomePage()));
                                                    },
                                                    icon: Icon(
                                                      Icons.edit,
                                                      size: 20,
                                                    ),
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Container(
                                                  height: 40,
                                                  width: 40,
                                                  margin:
                                                      EdgeInsets.only(left: 15),
                                                  decoration: BoxDecoration(
                                                    color: color2,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 1.5),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: color1,
                                                        blurRadius: 10.0,
                                                        offset: const Offset(
                                                            0.0, 0.0),
                                                      ),
                                                    ],
                                                    // shape: BoxShape.circle
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      showPostOptions();
                                                    },
                                                    icon: Icon(
                                                      Icons.add,
                                                      size: 20,
                                                    ),
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                // Container(
                                                //   height: 40,
                                                //   width: 40,
                                                //   margin:
                                                //       EdgeInsets.only(left: 15),
                                                //   decoration: BoxDecoration(
                                                //     color: color2,
                                                //     borderRadius:
                                                //         BorderRadius.circular(
                                                //             12),
                                                //     border: Border.all(
                                                //         color: Colors.white,
                                                //         width: 1.5),
                                                //     boxShadow: [
                                                //       BoxShadow(
                                                //         color: color1,
                                                //         blurRadius: 10.0,
                                                //         offset: const Offset(
                                                //             0.0, 0.0),
                                                //       ),
                                                //     ],
                                                //     // shape: BoxShape.circle
                                                //   ),
                                                //   child: Icon(
                                                //     Icons.message,
                                                //     size: 20,
                                                //     color: Colors.white,
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          )
                                        : FutureBuilder<ViewProfile>(
                                            future: refresh,
                                            builder: (BuildContext context,
                                                AsyncSnapshot<ViewProfile>
                                                    snapshot) {
                                              if (!snapshot.hasData) {
                                                return Container();
                                              } else if (followersname.contains(
                                                  SessionData().data[0].name)) {
                                                return Container(
                                                  height: 40,
                                                  width: 115,
                                                  margin:
                                                      EdgeInsets.only(top: 15),
                                                  decoration: BoxDecoration(
                                                    color: color2,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 1.5),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: color1,
                                                        blurRadius: 10.0,
                                                        offset: const Offset(
                                                            0.0, 0.0),
                                                      ),
                                                    ],
                                                    // shape: BoxShape.circle
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                        onPressed: () =>
                                                            hitUnFollowApi(),
                                                        icon: Icon(
                                                          FontAwesomeIcons
                                                              .userMinus,
                                                          size: 15,
                                                        ),
                                                        color: Colors.white,
                                                      ),
                                                      // SizedBox(width: 5),
                                                      Text(
                                                        'Unfollow',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              } else if (followersname.contains(
                                                      SessionData()
                                                          .data[0]
                                                          .name) ||
                                                  followersname.length < 1) {
                                                return Container(
                                                  height: 40,
                                                  width: 100,
                                                  margin:
                                                      EdgeInsets.only(top: 15),
                                                  decoration: BoxDecoration(
                                                    color: color2,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 1.5),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: color1,
                                                        blurRadius: 10.0,
                                                        offset: const Offset(
                                                            0.0, 0.0),
                                                      ),
                                                    ],
                                                    // shape: BoxShape.circle
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                        onPressed: () =>
                                                            hitFollowApi(),
                                                        icon: Icon(
                                                          FontAwesomeIcons
                                                              .userPlus,
                                                          size: 15,
                                                        ),
                                                        color: Colors.white,
                                                      ),
                                                      // SizedBox(width: 5),
                                                      Text(
                                                        'Follow',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                return Container();
                                              }
                                            },
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          backgroundColor: Colors.white,
                          bottom: TabBar(
                              onTap: (index) {
                                print("current index is $index");
                                if (index == 2) {}
                              },
                              labelColor: color1,
                              indicatorColor: Colors.redAccent,
                              unselectedLabelColor: Colors.blueGrey,
                              indicatorSize: TabBarIndicatorSize.tab,
                              // These are the widgets to put in each tab in the tab bar.
                              tabs: [
                                new Tab(
                                    icon: Icon(
                                  FlutterIcons.racing_helmet_mco,
                                  size: 30,
                                )),
                                new Tab(
                                    icon: Icon(
                                  FlutterIcons.map_marked_alt_faw5s,
                                  size: 30,
                                )),
                                new Tab(
                                    icon: Icon(
                                  FlutterIcons.photo_library_mdi,
                                  size: 30,
                                ))
                              ]),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(children: [
                    FutureBuilder<ViewProfile>(
                      future: refresh,
                      builder: (BuildContext context,
                          AsyncSnapshot<ViewProfile> snapshot) {
                        if (!snapshot.hasData) {
                          return Container(
                            child: Text('Loading'),
                          );
                        } else {
                          return CustomScrollView(
                            slivers: <Widget>[
                              SliverOverlapInjector(
                                // This is the flip side of the SliverOverlapAbsorber
                                // above.
                                handle: NestedScrollView
                                    .sliverOverlapAbsorberHandleFor(context),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                  return Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.all(10),
                                        decoration: new BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 10.0,
                                              offset: const Offset(0.0, 0.0),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    15, 10, 10, 10),
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      'Garage',
                                                      style: TextStyle(
                                                          color: color1,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 17),
                                                    ),
                                                  ],
                                                )),
                                            Container(
                                              height: 100,
                                              child: ListView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                children: <Widget>[
                                                  widget.userId ==
                                                          SessionData()
                                                              .data[0]
                                                              .id
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            print(
                                                                'Tapped $index bike');
                                                            Navigator
                                                                .pushReplacement(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            AddUpdateBike(
                                                                              viewProfile: viewProfile,
                                                                              index: index,
                                                                              isNewBike: true,
                                                                            )));
                                                          },
                                                          child: Container(
                                                            width: 80,
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  height: 55,
                                                                  width: 55,
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color:
                                                                        color2,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .white,
                                                                        width:
                                                                            1.5),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color:
                                                                            color1,
                                                                        blurRadius:
                                                                            5.0,
                                                                        offset: const Offset(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ],
                                                                    // shape: BoxShape.circle
                                                                  ),
                                                                  child: Icon(
                                                                    FlutterIcons
                                                                        .add_mdi,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 40,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'Add New',
                                                                  overflow:
                                                                      TextOverflow
                                                                          .fade,
                                                                  softWrap:
                                                                      false,
                                                                  style: TextStyle(
                                                                      color:
                                                                          color1,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      : Container(),
                                                  ListView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    children: List.generate(
                                                        viewProfile.myGarage
                                                            .length, (index) {
                                                      print(viewProfile
                                                          .myGarage[index]
                                                          .imageUrl
                                                          .toString());
                                                      return Hero(
                                                        tag: "bikeImage$index",
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            print(
                                                                'Tapped $index bike');
                                                            Navigator
                                                                .pushReplacement(
                                                                    context,
                                                                    PageRouteBuilder(
                                                                        transitionDuration: Duration(
                                                                            milliseconds:
                                                                                500),
                                                                        pageBuilder: (_,
                                                                                __,
                                                                                ___) =>
                                                                            AddUpdateBike(
                                                                              viewProfile: viewProfile,
                                                                              index: index,
                                                                              isNewBike: false,
                                                                            )));
                                                          },
                                                          onLongPress: () {},
                                                          child: Container(
                                                            width: 80,
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  child:
                                                                      CircleAvatar(
                                                                    maxRadius:
                                                                        28,
                                                                    minRadius:
                                                                        25,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    backgroundImage: viewProfile.myGarage[index].imageUrl !=
                                                                            null
                                                                        ? NetworkImage(viewProfile
                                                                            .myGarage[index]
                                                                            .imageUrl)
                                                                        : null,
                                                                    child: viewProfile.myGarage[index].imageUrl ==
                                                                            null
                                                                        ? Container(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child: Image.asset(
                                                                              'assets/images/placeholder2.png',
                                                                              height: 45,
                                                                            ))
                                                                        : null,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  viewProfile
                                                                      .myGarage[
                                                                          index]
                                                                      .model,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .fade,
                                                                  softWrap:
                                                                      false,
                                                                  style: TextStyle(
                                                                      color:
                                                                          color1,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }, childCount: 1),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    SplashScreen(),
                    FutureBuilder<ViewProfile>(
                      future: refresh,
                      builder: (BuildContext context,
                          AsyncSnapshot<ViewProfile> snapshot) {
                        if (!snapshot.hasData) {
                          return Container(
                            child: Text('Loading'),
                          );
                        } else {
                          return CustomScrollView(slivers: [
                            SliverOverlapInjector(
                              // This is the flip side of the SliverOverlapAbsorber
                              // above.
                              handle: NestedScrollView
                                  .sliverOverlapAbsorberHandleFor(context),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                print("object");
                                return Container(
                                  alignment: Alignment.center,
                                  child: Wrap(
                                    direction: Axis.horizontal,
                                    children: List.generate(
                                        viewProfile.userPostDetails.length,
                                        (index) {
                                      return Container(
                                          height: 100,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3.2,
                                          margin: EdgeInsets.all(2),
                                          // decoration: BoxDecoration(
                                          //     image: DecorationImage(
                                          //         fit: BoxFit.cover,
                                          //         image: NetworkImage(
                                          //             viewProfile
                                          //                 .userPostDetails[
                                          //                     index]
                                          //                 .photoUrl))),
                                          child:
                                              FadeInImage.assetNetwork(
                                                  fit: BoxFit.fitHeight,
                                                  placeholder:
                                                      'assets/images/bike.gif',
                                                  image: viewProfile
                                                      .userPostDetails[index]
                                                      .photoUrl));
                                    }),
                                  ),
                                );
                              }, childCount: 1),
                            ),
                          ]);
                        }
                      },
                    )
                  ])),
            )),
      ),
    );
  }

  void hitFollowApi() async {
    Dio dio = new Dio();
    dio.options.headers['Authorization'] = 'Bearer ' + SessionData().token;
    dio.options.responseType = ResponseType.json;
    showLoaderDialog(context, 'Following...');
    setState(() {
      _isDialogShowing = true;
    });

    var formData = json.encode({"otherUserId": viewProfile.userDetails.id});

    try {
      final request =
          await dio.put(commonapi + '/follow/followUser', data: formData);
      print(request.statusCode);
      if (request.statusCode == 200) {
        if (_isDialogShowing) {
          Navigator.pop(context);
          setState(() {
            _isDialogShowing = false;
          });
          setState(() {
            getPosts(viewProfile.userDetails.id);
          });
        }
        showInSnackBar(context, 'You followed ' + viewProfile.userDetails.name,
            _scaffoldKey);
      }
    } on DioError catch (e) {
      print(e.response.statusCode);
      print(e.response.statusMessage);
      if (_isDialogShowing) {
        Navigator.pop(context);
        setState(() {
          _isDialogShowing = false;
        });
      }
      showInSnackBar(context, 'Failed. Please try again Later !', _scaffoldKey);
    }
  }

  void hitUnFollowApi() async {
    Dio dio = new Dio();
    dio.options.headers['Authorization'] = 'Bearer ' + SessionData().token;
    dio.options.responseType = ResponseType.json;
    showLoaderDialog(context, 'UnFollowing...');
    setState(() {
      _isDialogShowing = true;
    });

    var formData = json.encode({"otherUserId": viewProfile.userDetails.id});

    try {
      final request =
          await dio.put(commonapi + '/follow/unfollowUser', data: formData);
      print(request.statusCode);
      if (request.statusCode == 200) {
        if (_isDialogShowing) {
          Navigator.pop(context);
          setState(() {
            _isDialogShowing = false;
          });
          setState(() {
            getPosts(viewProfile.userDetails.id);
          });
        }
        showInSnackBar(context,
            'You unfollowed ' + viewProfile.userDetails.name, _scaffoldKey);
      }
    } on DioError catch (e) {
      print(e.response.statusCode);
      print(e.response.statusMessage);
      if (_isDialogShowing) {
        Navigator.pop(context);
        setState(() {
          _isDialogShowing = false;
        });
      }
      showInSnackBar(context, 'Failed. Please try again Later !', _scaffoldKey);
    }
  }

  void openFollowing() {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        context: context,
        isDismissible: true,
        elevation: 1,
        enableDrag: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, state) {
              return Container(
                height: MediaQuery.of(context).size.height / 1.7,
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                margin: EdgeInsets.all(10),
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        // scrollTimer.cancel();
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.close,
                          size: 25,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                          // reverse: true,
                          // controller: _scrollController,
                          shrinkWrap: true,
                          children: viewProfile.userDetails.following.length > 0
                              ? List.generate(
                                  viewProfile.userDetails.following.length,
                                  (index) {
                                  return ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      // widget.userId = viewProfile.userDetails.following[index].id;
                                      // getPosts(viewProfile.userDetails.following[index].id);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfilePage1(
                                                      userId: viewProfile
                                                          .userDetails
                                                          .following[index]
                                                          .id,
                                                      name: viewProfile
                                                          .userDetails
                                                          .following[index]
                                                          .name)));
                                    },
                                    leading: ClipOval(
                                      child: Image(
                                        height: 35,
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                            'assets/images/biker.png'),
                                      ),
                                    ),
                                    title: Text(
                                        viewProfile
                                            .userDetails.following[index].name,
                                        style: TextStyle(
                                            color: color1,
                                            fontWeight: FontWeight.w700)),
                                  );
                                })
                              : List.generate(1, (index) {
                                  return Align(
                                    alignment: Alignment.center,
                                    child: Center(
                                      child: Text('No Followings !'),
                                    ),
                                  );
                                })),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  void openFollowers() {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        context: context,
        isDismissible: true,
        elevation: 1,
        enableDrag: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, state) {
              return Container(
                height: MediaQuery.of(context).size.height / 1.7,
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                margin: EdgeInsets.all(10),
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        // scrollTimer.cancel();
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.close,
                          size: 25,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                          // reverse: true,
                          // controller: _scrollController,
                          shrinkWrap: true,
                          children: viewProfile.userDetails.followers.length > 0
                              ? List.generate(
                                  viewProfile.userDetails.followers.length,
                                  (index) {
                                  return ListTile(
                                      onTap: () {
                                        Navigator.pop(context);
                                        // widget.userId = viewProfile.userDetails.following[index].id;
                                        // getPosts(viewProfile.userDetails.following[index].id);

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfilePage1(
                                                        userId: viewProfile
                                                            .userDetails
                                                            .followers[index]
                                                            .id,
                                                        name: viewProfile
                                                            .userDetails
                                                            .followers[index]
                                                            .name)));
                                      },
                                      leading: ClipOval(
                                        child: Image(
                                          height: 35,
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                              'assets/images/biker.png'),
                                        ),
                                      ),
                                      title: Text(
                                          viewProfile.userDetails
                                              .followers[index].name,
                                          style: TextStyle(
                                              color: color1,
                                              fontWeight: FontWeight.w700)),
                                      // subtitle: Text(
                                      //     allPostsModel.data[index1]
                                      //         .comments[index].commentText,
                                      //     style: TextStyle(color: Colors.black)),
                                      trailing: Container(
                                        height: 30,
                                        margin: EdgeInsets.only(top: 15),
                                        child: MaterialButton(
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: Colors.red,
                                                    width: 1.5),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            highlightColor: Colors.transparent,
                                            splashColor: Colors.white24,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0, right: 8),
                                              child: Text(
                                                "Follow",
                                                style: TextStyle(
                                                    color: color1,
                                                    fontSize: 13,
                                                    fontFamily: "Selawk"),
                                              ),
                                            ),
                                            onPressed: () async {}),
                                      ));
                                })
                              : List.generate(1, (index) {
                                  return Align(
                                    alignment: Alignment.center,
                                    child: Center(
                                      child: Text('No Followings !'),
                                    ),
                                  );
                                })),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  void showPostOptions() {
    showModalBottomSheet(
        backgroundColor: Colors.grey[200],
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (BuildContext context) {
          return Container(
            height: 200,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  width: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                  ),
                  height: 4,
                ),
                SizedBox(height: 10),
                Container(
                  height: 35,
                  width: MediaQuery.of(context).size.width / 1.2,
                  decoration: BoxDecoration(
                    color: color2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: color1,
                        blurRadius: 5.0,
                        offset: const Offset(0.0, 0.0),
                      ),
                    ],
                    // shape: BoxShape.circle
                  ),
                  child: MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.white24,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.photoVideo,
                              size: 15,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Photo/Video",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewPost(
                                      isNewPost: true,
                                      viewProfile: viewProfile,
                                      index: null,
                                      allPostsModel: null,
                                    )));
                      }),
                ),
                SizedBox(height: 20),
                Container(
                  height: 35,
                  width: MediaQuery.of(context).size.width / 1.2,
                  decoration: BoxDecoration(
                    color: color2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: color1,
                        blurRadius: 5.0,
                        offset: const Offset(0.0, 0.0),
                      ),
                    ],
                    // shape: BoxShape.circle
                  ),
                  child: MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.white24,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.calendarAlt,
                              size: 15,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Event/Activity",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateEvent(
                                      isNew: true,
                                    )));
                      }),
                ),
              ],
            ),
          );
        });
  }
}
