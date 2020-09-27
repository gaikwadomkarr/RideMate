import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bikingapp/CarouselSliderBuilder.dart';
import 'package:bikingapp/Helpers/AppConstants.dart';
import 'package:bikingapp/Helpers/LayoutHelpers.dart';
import 'package:bikingapp/Helpers/ShowNotificationHelper.dart';
import 'package:bikingapp/HomeScreen.dart';
import 'package:bikingapp/Models/AllPostsModel.dart';
import 'package:bikingapp/Models/SessionData.dart';
import 'package:bikingapp/NewPost.dart';
import 'package:bikingapp/PostsScreen.dart';
import 'package:bikingapp/ProfilePage1.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;

class TilePostsScreen extends StatefulWidget {
  @override
  _TilePostsScreenState createState() => _TilePostsScreenState();
}

class _TilePostsScreenState extends State<TilePostsScreen>
    with AutomaticKeepAliveClientMixin<TilePostsScreen> {
  TabController _tabController;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isDialogShowing = false;
  Future<List<String>> refresh;
  List<String> name, title, body, photo;
  List<List<String>> images1;
  List<bool> photozoom;
  List<String> thumbnails;
  AllPostsModel allPostsModel;
  Map<String, dynamic> likesMap;
  Map<String, dynamic> commentsMap;
  List<List<String>> likes;
  String selectedPostId;
  List<IntSize> sizes;
  List<String> postIds;
  List<String> selectedPostlikes;
  TextEditingController commentText = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  List<CarouselController> carouselcontrlrs = new List<CarouselController>();
  Timer scrollTimer;
  List<bool> _isLiked;
  int count = 0;
  double offsetA = 0.0;
  List<int> current = List<int>();
  List<CarouselSliderBuilder> carousel = new List<CarouselSliderBuilder>();

  List<GlobalKey> btnkeys = [];

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
    return WillPopScope(
      onWillPop: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomeScreen(index: 0)));
      },
      child: SafeArea(
          child: Scaffold(
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

    PageController pageController = PageController(viewportFraction: 1);
    return FutureBuilder<List<String>>(
      future: refresh,
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Container(child: Text('No Posts Available')),
          );
        } else if (allPostsModel.data.length > 0) {
          return StaggeredGridView.countBuilder(
              key: PageStorageKey<String>('controllerA'),
              controller: statelessControllerA,
              addAutomaticKeepAlives: true,
              scrollDirection: Axis.vertical,
              itemCount: allPostsModel.data.length,
              // primary: true,
              crossAxisCount: 4,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              itemBuilder: (context, index) => buildTiles(index, sizes[index]),
              staggeredTileBuilder: (index) => StaggeredTile.fit(2));
          // );
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
                          controller: _scrollController,
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

  Widget buildTiles(int index, IntSize size) {
    return Card(
      shadowColor: color1,
      borderOnForeground: true,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostsScreen(initialPage: index)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                new ClipRRect(
                    // decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    // image: DecorationImage(
                    //   image: NetworkImage(thumbnails[index]),
                    // )),
                    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: FadeInImage.assetNetwork(
                      image: thumbnails[index],
                      placeholder: 'assets/images/bike.gif',
                      // height: size.height.toDouble(),
                      // width: size.width.toDouble(),
                      fit: BoxFit.cover,
                      // filterQuality: FilterQuality.high,
                    )),
                if (allPostsModel.data[index].postImages.length > 1)
                  Align(
                    alignment: FractionalOffset.bottomRight,
                    child: Icon(
                      Icons.photo_library,
                      color: Colors.white,
                    ),
                  )
              ],
            ),
            new Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    allPostsModel.data[index].postedBy.name,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: color1),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Row(
                        children: [
                          new Icon(FlutterIcons.heart_ant,
                              color: Colors.red, size: 12),
                          SizedBox(
                            width: 5,
                          ),
                          new Text(
                              allPostsModel.data[index].likes.length.toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              )),
                        ],
                      ),
                      SizedBox(width: 10),
                      Row(
                        children: [
                          new Icon(FlutterIcons.comments_faw,
                              color: Colors.black, size: 12),
                          SizedBox(
                            width: 5,
                          ),
                          new Text(
                              allPostsModel.data[index].comments.length
                                  .toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              )),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<IntSize> _createSizes(int count) {
    Random rnd = new Random();
    return new List.generate(count,
        (i) => new IntSize((rnd.nextInt(500) + 200), rnd.nextInt(100) + 150));
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
        sizes = [];
        sizes = _createSizes(allPostsModel.data.length);
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
    thumbnails = [];

    for (int i = 0; i < allPostsModel.data.length; i++) {
      if (allPostsModel.data[i].postImages[0].contains("mp4")) {
        thumbnails
            .add(allPostsModel.data[i].postImages[0].replaceAll("mp4", "jpg"));
      } else {
        thumbnails.add(allPostsModel.data[i].postImages[0]);
      }
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
    }
    setState(() {});
    print(name);
    print('this is images => ' + images1.toString());
    print(body);
    print(title);
    print(btnkeys);
    print(carousel);
    likesMap.forEach((key, value) {
      print('going inside key $key');
      List<String> likesid = [];
      value.forEach((like) {
        likesid.add(like.id);
      });
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

  void hitLikeApi() async {
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
      String url = '$commonapi/bikesGallery/like';
      print('selectedPostId => ' + selectedPostId);
      print(url);
      var body = json.encode({"postId": selectedPostId});

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + SessionData().token
      };
      final request = await http.put(url, body: body, headers: headers);
      print(request.statusCode);
      if (request.statusCode == 200) {
        if (_isDialogShowing) {
          Navigator.pop(context);
          setState(() {
            _isDialogShowing = false;
          });
        }
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

  void hitunLikeApi() async {
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
      String url = '$commonapi/bikesGallery/unlike';
      print('selectedPostId => ' + selectedPostId);
      print(url);
      var body = json.encode({"postId": selectedPostId});

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + SessionData().token
      };
      final request = await http.put(url, body: body, headers: headers);
      print(request.statusCode);
      if (request.statusCode == 200) {
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
    String url =
        '$commonapi/comments/addComment/' + allPostsModel.data[index].id;
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
    allPostsModel.data[index].likes.forEach((element) {
      print(element.name);
      selectedPostlikes.add(element.name);
    });
    if (allPostsModel.data[index].likes.length == selectedPostlikes.length) {
      openLikes(index);
    }
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

class IntSize {
  const IntSize(this.width, this.height);

  final int width;
  final int height;
}
