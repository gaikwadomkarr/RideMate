import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bikingapp/CarouselSliderBuilder.dart';
import 'package:bikingapp/Helpers/AppConstants.dart';
import 'package:bikingapp/Helpers/LayoutHelpers.dart';
import 'package:bikingapp/Helpers/ShowNotificationHelper.dart';
import 'package:bikingapp/HomeScreen.dart';
import 'package:bikingapp/Models/AllPostsModel.dart';
import 'package:bikingapp/Models/SessionData.dart';
import 'package:bikingapp/NewPost.dart';
import 'package:bikingapp/ProfilePage1.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:drag_to_expand/drag_to_expand.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:readmore/readmore.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostsScreen extends StatefulWidget {
  final int initialPage;
  PostsScreen({@required this.initialPage});
  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen>
    with AutomaticKeepAliveClientMixin<PostsScreen> {
  TabController _tabController;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isDialogShowing = false;
  Future<List<String>> refresh;
  List<String> name, title, body, photo;
  List<List<String>> images1;
  List<bool> photozoom;
  AllPostsModel allPostsModel;
  Map<String, dynamic> likesMap;
  Map<String, dynamic> commentsMap;
  List<List<String>> likes;
  String selectedPostId;
  List<String> postIds;
  List<String> selectedPostlikes;
  TextEditingController commentText = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  List<CarouselController> carouselcontrlrs = new List<CarouselController>();
  Timer scrollTimer;
  List<bool> _isLiked;
  List<PanelController> panelControllers = new List<PanelController>();
  int count = 0;
  double offsetA = 0.0;
  List<int> current = List<int>();
  List<CarouselSliderBuilder> carousel = new List<CarouselSliderBuilder>();
  List<bool> isPanelOpened;
  List<GlobalKey> btnkeys = [];
  double minHeight = 35;
  double maxHeight;
  GlobalKey btnKey = GlobalKey();

  void initState() {
    super.initState();
    imageCache.clear();
    SchedulerBinding.instance.addPostFrameCallback((_) => getAllPosts());
    refresh = seperateResponse();
    timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
    Jiffy.locale('en_short');
  }

  @override
  Widget build(BuildContext context) {
    maxHeight = MediaQuery.of(context).size.height / 3;
    return WillPopScope(
      onWillPop: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomeScreen(index: 0)));
      },
      child: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.white,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/BikeIcon.png',
                height: 35,
              ),
              Container(
                margin: EdgeInsets.only(left: 10),
                child: Text(
                  'RideMate',
                  style: TextStyle(
                      color: color1, fontSize: 20, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage1(
                                userId: SessionData().data[0].id,
                                name: SessionData().data[0].name,
                              )));
                },
                icon: ClipOval(
                  child: Image(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/biker.png'),
                  ),
                ),
              ),
            ),
          ],
          centerTitle: true,
        ),
        resizeToAvoidBottomInset: true,
        body: RefreshIndicator(onRefresh: getAllPosts, child: buildPosts()),
      )),
    );
  }

  double _scale = 1.0;
  double _previousScale = 1.0;

  void stateChanged(bool isShow) {
    print('menu is ${isShow ? 'showing' : 'closed'}');
  }

  void onClickMenu(MenuItemProvider item) {
    print('Click menu -> ${item.menuTitle}');
  }

  void onDismiss() {
    print('Menu is dismiss');
  }

  void customBackground(int index, BuildContext context) {
    PopupMenu menu = PopupMenu(
        context: context,
        // backgroundColor: color2,
        // lineColor: Colors.tealAccent,
        // maxColumn: 2,
        items: [
          MenuItem(
              title: 'Edit',
              textStyle: TextStyle(color: Colors.white),
              image: Icon(
                Icons.edit,
                color: Colors.white,
              )),
          MenuItem(
              title: 'Delete',
              textStyle: TextStyle(color: Colors.white),
              image: Icon(
                Icons.delete,
                color: Colors.white,
              )),
        ],
        onClickMenu: onClickMenu,
        stateChanged: stateChanged,
        onDismiss: onDismiss);
    menu.show(widgetKey: btnkeys[index]);
  }

  Widget buildPosts() {
    ScrollController statelessControllerA =
        ScrollController(initialScrollOffset: offsetA);
    statelessControllerA.addListener(() {
      setState(() {
        offsetA = statelessControllerA.offset;
      });
    });

    PanelController panelController = PanelController();

    PageController pageController =
        PageController(viewportFraction: 0.8, initialPage: widget.initialPage);
    return FutureBuilder<List<String>>(
      future: refresh,
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Container(child: Text('No Posts Available')),
          );
        } else if (allPostsModel.data.length > 0) {
          return ListView(
              // pageSnapping: true,
              scrollDirection: Axis.vertical,
              // key: PageStorageKey<String>('controllerA'),
              controller: statelessControllerA,
              // itemCount: allPostsModel.data.length,
              children:
                  List.generate(allPostsModel.data.length, (int outerindex) {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        // border: Border.all(color: Colors.black),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0, 0),
                              blurRadius: 5)
                        ],
                        borderRadius: BorderRadius.circular(10)),
                    // height: MediaQuery.of(context).size.height - 2,
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Container(
                            height: 40,
                            width: 40,
                            // margin: EdgeInsets.fromLTRB(20, 10, 10, 0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/OLQE6Q0.jpg'))),
                          ),
                          title: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage1(
                                            userId: allPostsModel
                                                .data[outerindex].postedBy.id,
                                            name: allPostsModel
                                                .data[outerindex].postedBy.name,
                                          )));
                            },
                            child: Text(
                              name[outerindex],
                              style: mediumTxtStyle().copyWith(fontSize: 15),
                            ),
                          ),
                          subtitle: null,
                          trailing: Container(
                            child: GestureDetector(
                              key: btnkeys[outerindex],
                              onTap: () {
                                menuOptions(context, "Choose One", outerindex,
                                    postOptions(outerindex));
                                selectedPostId = postIds[outerindex];
                              },
                              child: Icon(
                                Icons.more_vert,
                                color: color1,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        carousel[outerindex],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.fromLTRB(20, 10, 0, 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  new Container(
                                    alignment: Alignment.centerLeft,
                                    child: GestureDetector(
                                        onTap: () {
                                          if (_isLiked[outerindex]) {
                                            selectedPostId =
                                                postIds[outerindex];
                                            hitunLikeApi(outerindex);
                                            count--;
                                            print(_isLiked);
                                          } else {
                                            selectedPostId =
                                                postIds[outerindex];
                                            hitLikeApi(outerindex);
                                            count++;
                                            print(_isLiked);
                                          }
                                        },
                                        child: _isLiked[outerindex]
                                            ? Icon(
                                                FlutterIcons.heart_faw5s,
                                                size: 23,
                                                color: Colors.red[900],
                                              )
                                            : Icon(
                                                FlutterIcons.heart_faw5,
                                                size: 23,
                                                color: Colors.red[900],
                                              )),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      getSelectedPostsLikes(outerindex);
                                    },
                                    child: Container(
                                        alignment: Alignment.centerLeft,
                                        margin: EdgeInsets.only(left: 10),
                                        child: new Text(
                                          // allPostsModel
                                          //         .data[outerindex].likes.length
                                          //         .toString() +
                                          likesMap[postIds[outerindex]] != null
                                              ? likesMap[postIds[outerindex]]
                                                      .length
                                                      .toString() +
                                                  ' likes'
                                              : "0" + ' likes',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                        )),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: GestureDetector(
                                        onTap: () {
                                          openComments(outerindex);
                                          // goToLatest();
                                        },
                                        child: Icon(
                                          FlutterIcons.comment_dots_faw5,
                                          size: 23,
                                          color: Colors.red[900],
                                        )),
                                  ),
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.only(left: 10),
                                      child: new Text(
                                        allPostsModel
                                            .data[outerindex].comments.length
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600),
                                      )),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                  alignment: Alignment.centerRight,
                                  margin: EdgeInsets.only(right: 15),
                                  child: new Text(
                                    Jiffy(allPostsModel
                                            .data[outerindex].createdAt)
                                        .fromNow(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal),
                                  )),
                            )
                          ],
                        ),
                        Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.fromLTRB(20, 0, 10, 0),
                            child: Text(title[outerindex],
                                style: titleTxtStyle())),
                      ],
                    ),
                  ),
                );
              }));
        } else {
          return Container();
        }
      },
    );
  }

  void goToLatest() {
    scrollTimer = Timer(Duration(milliseconds: 1000), () {
      print('calling autoscroll');
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void openComments(int index1) {
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
                        child: Icon(Icons.close),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                          // reverse: true,
                          // controller: _scrollController,
                          shrinkWrap: true,
                          children: allPostsModel.data[index1].comments.length >
                                  0
                              ? List.generate(
                                  allPostsModel.data[index1].comments.length,
                                  (index) {
                                  return ListTile(
                                    leading: ClipOval(
                                      child: Image(
                                        height: 45,
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                            'assets/images/biker.png'),
                                      ),
                                    ),
                                    title: Text(
                                        allPostsModel
                                            .data[index1]
                                            .comments[index]
                                            .commentedByUserName,
                                        style: TextStyle(
                                            color: color1,
                                            fontWeight: FontWeight.w700)),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                            allPostsModel.data[index1]
                                                .comments[index].commentText,
                                            style:
                                                TextStyle(color: Colors.black)),
                                        Container(
                                          margin: EdgeInsets.only(top: 5),
                                          child: Text(
                                              timeago
                                                  .format(
                                                      DateTime.parse(
                                                          allPostsModel
                                                              .data[index1]
                                                              .comments[index]
                                                              .createdAt
                                                              .toString()),
                                                      locale: 'en_short')
                                                  .replaceAll('~', ''),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 8)),
                                        ),
                                      ],
                                    ),
                                    trailing: allPostsModel
                                                .data[index1]
                                                .comments[index]
                                                .commentedByUserId ==
                                            SessionData().data[0].id
                                        ? GestureDetector(
                                            onTap: () {
                                              hitdeleteComment(
                                                  index, index1, state);
                                            },
                                            child:
                                                Icon(FontAwesomeIcons.trashAlt))
                                        : null,
                                  );
                                })
                              : List.generate(1, (index) {
                                  return Align(
                                    alignment: Alignment.center,
                                    child: Center(
                                      child: Text(
                                          'No Comments yet ! Be the first to comment.'),
                                    ),
                                  );
                                })),
                    ),
                    SingleChildScrollView(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              // margin: EdgeInsets.only(left: 5, right: 5),
                              padding: EdgeInsets.only(left: 10),
                              // width: 230,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: new BorderRadius.only(
                                    bottomLeft: Radius.circular(10)),
                                // color: _color,
                              ),
                              child: TextField(
                                enabled: true,
                                controller: commentText,
                                // cursorColor: FlavorConfig.instance.textColor,
                                style: TextStyle(
                                  color: color1,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Add Comment...',
                                  hintStyle: TextStyle(
                                    fontSize: 17,
                                    color: Color(0xFF7E0D74),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(10.0),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 10),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 45,
                            width: 60,
                            child: FloatingActionButton.extended(
                              elevation: 0,
                              heroTag: 'Reply',
                              onPressed: () {
                                if (commentText.text.isNotEmpty) {
                                  hitPostComment(index1, state);
                                }
                              },
                              // backgroundColor: FlavorConfig.instance.textColor,
                              shape: RoundedRectangleBorder(
                                // side: BorderSide(color: Colors.grey[500]),
                                borderRadius: new BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                              ),
                              label: Icon(
                                Icons.send,
                                size: 35,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  Widget postOptions(int index) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Divider(
            color: Colors.black,
          ),
          SizedBox(
            height: 15,
          ),
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewPost(
                              isNewPost: false,
                              viewProfile: null,
                              index: index,
                              allPostsModel: allPostsModel,
                            )));
              },
              child: Text(
                'Edit Post',
              )),
          SizedBox(height: 10),
          Divider(),
          SizedBox(height: 10),
          GestureDetector(
              onTap: () {
                Navigator.pop(context);
                menuOptions(context, "Confirm Deletion", index,
                    deleteConfirmation(index));
              },
              child: Text(
                'Delete Post',
              ))
        ]);
  }

  Widget deleteConfirmation(int index) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Divider(
            color: Colors.black,
          ),
          SizedBox(
            height: 15,
          ),
          GestureDetector(
              onTap: () {
                Navigator.pop(context);
                hitDeletePostApi(postIds[index]);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              )),
          SizedBox(height: 10),
          Divider(),
          SizedBox(height: 10),
          GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                "Don't Delete",
              ))
        ]);
  }

  void openLikes(index) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        context: context,
        isDismissible: true,
        elevation: 1,
        enableDrag: true,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height / 1.7,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            margin: EdgeInsets.all(10),
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  width: 15,
                  color: Colors.red,
                  height: 2,
                ),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: selectedPostlikes.length > 0
                        ? List.generate(selectedPostlikes.length, (index) {
                            return Column(
                              children: [
                                ListTile(
                                  leading: ClipOval(
                                    child: Image(
                                      height: 35,
                                      fit: BoxFit.cover,
                                      image:
                                          AssetImage('assets/images/biker.png'),
                                    ),
                                  ),
                                  title: Text(selectedPostlikes[index],
                                      style: TextStyle(color: color1)),
                                ),
                                Divider()
                              ],
                            );
                          })
                        : List.generate(1, (index) {
                            return Container(
                              child: Text('No one liked yet !'),
                            );
                          }),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> getAllPosts() async {
    Dio dio = new Dio();
    dio.options.headers['Authorization'] = 'Bearer ' + SessionData().token;
    dio.options.responseType = ResponseType.json;

    showLoaderDialog(context, 'Getting your Posts...');
    setState(() {
      _isDialogShowing = true;
    });

    try {
      print('$commonapi/api/v1/post/allPosts');
      final request = await dio.get('$commonapi/api/v1/post/allPosts');
      print(request.statusCode);
      print(request.data);
      if (request.statusCode == 200) {
        print('success');
        if (_isDialogShowing) {
          Navigator.pop(context);
          setState(() {
            _isDialogShowing = false;
          });
        }
        print('this is post data => ' + request.data.toString());
        allPostsModel = AllPostsModel.fromJson(request.data);
        refresh = seperateResponse();
      }
    } on DioError catch (e) {
      print('failed');
      if (_isDialogShowing) {
        Navigator.pop(context);
        setState(() {
          _isDialogShowing = false;
        });
      }
      showInSnackBar(context, e.request.data['message'], _scaffoldKey);
    }
  }

  Future<List<String>> seperateResponse() async {
    name = [];
    images1 = [];
    title = [];
    body = [];
    _isLiked = [];
    likesMap = new Map<String, dynamic>();
    commentsMap = new Map<String, dynamic>();
    postIds = [];
    likes = [];
    photozoom = [];
    carouselcontrlrs = [];
    carousel = [];
    isPanelOpened = [];
    panelControllers = [];

    for (int i = 0; i < allPostsModel.data.length; i++) {
      name.add(allPostsModel.data[i].postedBy.name.toString());
      title.add(allPostsModel.data[i].title);
      body.add(allPostsModel.data[i].body);
      images1.add(allPostsModel.data[i].postImages);
      current.add(0);
      photozoom.add(false);
      carouselcontrlrs.add(new CarouselController());
      carousel
          .add(new CarouselSliderBuilder(allPostsModel.data[i].postImages, i));
      likesMap[allPostsModel.data[i].id] = allPostsModel.data[i].likes;
      commentsMap[allPostsModel.data[i].id] = allPostsModel.data[i].comments;
      postIds.add(allPostsModel.data[i].id);
      btnkeys.add(new GlobalKey());
      panelControllers.add(new PanelController());
      isPanelOpened.add(false);
    }
    setState(() {});
    print(name);
    print('this is images => ' + images1.toString());
    print(body);
    print(title);
    print(btnkeys);
    print(carousel);
    print("this is likes sections =>" + likesMap.toString());
    likesMap.forEach((key, value) {
      print('going inside key $key');
      List<String> likesid = [];
      if (value != null) {
        value.forEach((like) {
          likesid.add(like.id);
          // print("this is post id $key likes => $like");
        });
      }
      likes.add(likesid);
    });
    for (int i = 0; i < likes.length; i++) {
      if (likes[i].contains(SessionData().data[0].id)) {
        _isLiked.add(true);
      } else {
        _isLiked.add(false);
      }
    }

    print('this is _isLiked => ' + _isLiked.toString());
    print('this is likes => ' + likes.toString());
    buildPosts();
    return name;
  }

  Widget getIsLiked(int index) {
    if (likes[index].contains(SessionData().data[0].id)) {}
  }

  void changeisLiked(int index) {}

  void hitLikeApi(int index) async {
    Dio dio = new Dio();
    print('this is token => ' + SessionData().token);
    dio.options.headers['Authorization'] = 'Bearer ' + SessionData().token;
    dio.options.headers['Content-Type'] = "application/json";
    dio.options.responseType = ResponseType.json;
    showLoaderDialog(context, 'Liking...');
    setState(() {
      _isDialogShowing = true;
    });
    try {
      String url = '$commonapi/api/v1/post/likePost/$selectedPostId';
      print('selectedPostId => ' + selectedPostId);
      print(url);
      var body = json.encode({"postId": selectedPostId});

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + SessionData().token
      };
      final request = await dio.put(url);
      print(request.statusCode);
      if (request.statusCode == 200) {
        if (_isDialogShowing) {
          Navigator.pop(context);
          setState(() {
            _isDialogShowing = false;
            _isLiked[index] = true;
          });
        }
        print(request.data.toString());
        likesMap.update("$selectedPostId", (value) {
          print("this is old value => $value");
          return request.data["postLikedDetails"]["likes"];
        });
        print("this is new likesMap => $likesMap");
        // Map jsonResponse = json.decode(request.body);
        // setState(() {
        //   allPostsModel = AllPostsModel.fromJson(jsonResponse);
        // });
      }
    } on DioError catch (e) {
      if (_isDialogShowing) {
        Navigator.pop(context);
        setState(() {
          _isDialogShowing = false;
        });
      }
      print(e.response.data);
    }
  }

  void hitunLikeApi(int index) async {
    Dio dio = new Dio();
    print('this is token => ' + SessionData().token);
    dio.options.headers['Authorization'] = 'Bearer ' + SessionData().token;
    dio.options.headers['Content-Type'] = "application/json";
    dio.options.responseType = ResponseType.json;
    showLoaderDialog(context, 'UnLiking...');
    setState(() {
      _isDialogShowing = true;
    });
    try {
      String url = '$commonapi/api/v1/post/unlikePost/$selectedPostId';
      print('selectedPostId => ' + selectedPostId);
      print(url);
      final request = await dio.put(url);
      print(request.statusCode);
      if (request.statusCode == 200) {
        if (_isDialogShowing) {
          Navigator.pop(context);
          setState(() {
            _isDialogShowing = false;
            _isLiked[index] = false;
          });
        }
        print(request.data.toString());
        likesMap.update("$selectedPostId", (value) {
          print("this is old value => $value");
          return request.data["postUnlikedDetails"]["likes"];
        });
        print("this is new likesMap => $likesMap");
      }
    } on DioError catch (e) {
      if (_isDialogShowing) {
        Navigator.pop(context);
        setState(() {
          _isDialogShowing = false;
        });
      }
      print(e.response.data);
    }
  }

  void hitDeletePostApi(String postId) async {
    Dio dio = new Dio();
    print('this is token => ' + SessionData().token);
    dio.options.headers['Authorization'] = 'Bearer ' + SessionData().token;
    dio.options.headers['Content-Type'] = "application/json";
    dio.options.responseType = ResponseType.json;
    showLoaderDialog(context, 'Deleting Post...');
    setState(() {
      _isDialogShowing = true;
    });
    try {
      String url = '$commonapi/post/deletePost/$selectedPostId';
      print('selectedPostId => ' + selectedPostId);
      print(url);

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + SessionData().token
      };
      final request = await http.delete(url, headers: headers);
      print(request.statusCode);
      if (request.statusCode == 200) {
        if (_isDialogShowing) {
          Navigator.pop(context);
          setState(() {
            _isDialogShowing = false;
          });
        }
        showInSnackBar(context, 'Post deleted successfully !', _scaffoldKey);
        print(request.body.toString());
        Map jsonResponse = json.decode(request.body);
        setState(() {
          allPostsModel = AllPostsModel.fromJson(jsonResponse);
        });
      }
    } on DioError catch (e) {
      if (_isDialogShowing) {
        Navigator.pop(context);
        setState(() {
          _isDialogShowing = false;
        });
      }
      print(e.response.data);
    }
  }

  Future<Null> hitPostComment(int index, StateSetter updateState) async {
    showLoaderDialog(context, 'Posting Comment...');
    setState(() {
      _isDialogShowing = true;
    });
    String url = '$commonapi/api/v1/postComments/addPostComment/' +
        allPostsModel.data[index].id;
    print(url);
    var body = json.encode({"commentText": commentText.text});

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + SessionData().token
    };
    final request = await http.post(url, body: body, headers: headers);
    print(request.statusCode);
    if (request.statusCode == 200) {
      commentText.text = '';
      if (_isDialogShowing) {
        Navigator.pop(context);
        setState(() {
          _isDialogShowing = false;
        });
      }

      print(request.body.toString());
      Map jsonResponse = json.decode(request.body);
      setState(() {
        allPostsModel = AllPostsModel.fromJson(json.decode(request.body));
      });
      updateState(() {
        allPostsModel = AllPostsModel.fromJson(json.decode(request.body));
      });
      goToLatest();
      // Future.delayed(Duration(seconds: 1),(){
      //   _scrollController
      //     .jumpTo(_scrollController.position.maxScrollExtent);
      // });
    } else {
      print('failed');
      if (_isDialogShowing) {
        Navigator.pop(context);
        setState(() {
          _isDialogShowing = false;
        });
      }
      print(request.body.toString());
      Map jsonResponse = json.decode(request.body);
      setState(() {
        allPostsModel = AllPostsModel.fromJson(json.decode(request.body));
      });
      updateState(() {
        allPostsModel = AllPostsModel.fromJson(json.decode(request.body));
      });
    }
  }

  Future<Null> hitdeleteComment(
      int index, int index1, StateSetter updateState) async {
    showLoaderDialog(context, 'Posting Comment...');
    setState(() {
      _isDialogShowing = true;
    });
    String url = '$commonapi/comments/deleteComment/' +
        allPostsModel.data[index1].comments[index].id +
        '/' +
        allPostsModel.data[index1].id;
    print(url);
    var body = json.encode({"commentText": commentText.text});

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + SessionData().token
    };
    final request = await http.delete(url, headers: headers);
    print(request.statusCode);
    if (request.statusCode == 200) {
      commentText.text = '';
      if (_isDialogShowing) {
        Navigator.pop(context);
        setState(() {
          _isDialogShowing = false;
        });
      }

      print(request.body.toString());
      Map jsonResponse = json.decode(request.body);
      setState(() {
        allPostsModel = AllPostsModel.fromJson(json.decode(request.body));
      });
      updateState(() {
        allPostsModel = AllPostsModel.fromJson(json.decode(request.body));
      });
      goToLatest();
      // Future.delayed(Duration(seconds: 1),(){
      //   _scrollController
      //     .jumpTo(_scrollController.position.maxScrollExtent);
      // });
    } else {
      print('failed');
      if (_isDialogShowing) {
        Navigator.pop(context);
        setState(() {
          _isDialogShowing = false;
        });
      }
      print(request.body.toString());
      Map jsonResponse = json.decode(request.body);
      setState(() {
        allPostsModel = AllPostsModel.fromJson(json.decode(request.body));
      });
      updateState(() {
        allPostsModel = AllPostsModel.fromJson(json.decode(request.body));
      });
    }
  }

  void getSelectedPostsLikes(int index) {
    selectedPostlikes = [];

    likesMap[postIds[index]].forEach((like) {
      selectedPostlikes.add(like["name"]);
    });
    openLikes(index);
  }

  void getSelectedPostsComments(int index) {
    openComments(index);
  }

  void showLikespopUp(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: EdgeInsets.only(top: 10),
          title: Text('Liked by'),
          children: selectedPostlikes.length > 0
              ? List.generate(selectedPostlikes.length, (index) {
                  return Column(
                    children: [
                      ListTile(
                        leading: ClipOval(
                          child: Image(
                            height: 35,
                            fit: BoxFit.cover,
                            image: AssetImage('assets/images/biker.png'),
                          ),
                        ),
                        title: Text(selectedPostlikes[index],
                            style: TextStyle(color: color1)),
                      ),
                    ],
                  );
                })
              : List.generate(1, (index) {
                  return Container(
                    child: Text('No one liked yet !'),
                  );
                }),
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
