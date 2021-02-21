import 'dart:convert';

import 'package:bikingapp/Helpers/AppConstants.dart';
import 'package:bikingapp/Helpers/ShowNotificationHelper.dart';
import 'package:bikingapp/Models/AllComments.dart';
import 'package:bikingapp/Models/SessionData.dart';
import 'package:bikingapp/Models/SinglePostComments.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class OpenComments extends StatefulWidget {
  final String postId;

  const OpenComments({Key key, this.postId}) : super(key: key);
  @override
  _OpenCommentsState createState() => _OpenCommentsState();
}

class _OpenCommentsState extends State<OpenComments>
    with SingleTickerProviderStateMixin {
  bool _isDialogShowing = false;
  SinglePostComments singlePostComments;
  TextEditingController commentText = new TextEditingController();
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    ));
    getPostComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: showComments());
  }

  Widget showComments() {
    return Container(
      height: MediaQuery.of(context).size.height / 1.7,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      margin: EdgeInsets.all(10),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  singlePostComments != null
                      ? "Comments " +
                              "(" +
                              singlePostComments.postDetails.comments.length
                                  .toString() ??
                          "0" + ")"
                      : "Comments (0)",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
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
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: ListView(
                // reverse: true,
                // controller: _scrollController,
                shrinkWrap: true,
                children: singlePostComments != null
                    ? singlePostComments.postDetails.comments.length > 0
                        ? List.generate(
                            singlePostComments.postDetails.comments.length,
                            (index) {
                            return ListTile(
                              leading: ClipOval(
                                child: Image(
                                  height: 45,
                                  fit: BoxFit.cover,
                                  image: AssetImage('assets/images/biker.png'),
                                ),
                              ),
                              title: Text(
                                  singlePostComments.postDetails.comments[index]
                                      .commentedByUserName,
                                  style: TextStyle(
                                      color: color1,
                                      fontWeight: FontWeight.w700)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                      singlePostComments.postDetails
                                          .comments[index].commentText,
                                      style: TextStyle(color: Colors.black)),
                                  Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Text(
                                        timeago
                                            .format(
                                                DateTime.parse(
                                                    singlePostComments
                                                        .postDetails
                                                        .comments[index]
                                                        .createdAt
                                                        .toString()),
                                                locale: 'en_short')
                                            .replaceAll('~', ''),
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 8)),
                                  ),
                                ],
                              ),
                              trailing: singlePostComments.postDetails
                                          .comments[index].commentedByUserId ==
                                      SessionData().data[0].id
                                  ? GestureDetector(
                                      onTap: () {
                                        // hitdeleteComment(index,
                                        //     widget.postIndex, state);
                                      },
                                      child: Icon(FontAwesomeIcons.trashAlt))
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
                          })
                    : List.generate(1, (index) {
                        return Align(
                          alignment: Alignment.center,
                          child: Center(
                            child: Text('Loading...'),
                          ),
                        );
                      })),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  // margin: EdgeInsets.only(left: 5, right: 5),
                  padding: EdgeInsets.only(left: 10),
                  // width: 230,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius:
                        new BorderRadius.only(bottomLeft: Radius.circular(10)),
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
                      hitPostComment();
                    }
                  },
                  // backgroundColor: FlavorConfig.instance.textColor,
                  shape: RoundedRectangleBorder(
                    // side: BorderSide(color: Colors.grey[500]),
                    borderRadius: new BorderRadius.only(
                        bottomRight: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  label: !_isDialogShowing
                      ? Icon(
                          Icons.send,
                          size: 35,
                          color: Colors.white,
                        )
                      : SpinKitRing(
                          color: Colors.green[900],
                          size: 25,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void getPostComments() async {
    try {
      String getPostCommentsurl =
          "$commonapi/api/v1/postComments/postComments/${widget.postId}";
      final response = await getDio().get(getPostCommentsurl);

      print(response.data.toString());
      if (response.statusCode == 200) {
        setState(() {
          singlePostComments = SinglePostComments.fromJson(response.data);
        });
      } else {}
    } on DioError catch (e) {}
  }

  Future<Null> hitPostComment() async {
    Dio dio = new Dio();
    print('this is token => ' + SessionData().token);
    dio.options.headers['Authorization'] = 'Bearer ' + SessionData().token;
    dio.options.headers['Content-Type'] = "application/json";
    dio.options.responseType = ResponseType.json;
    showLoaderDialog(context, 'Posting Comment...');
    setState(() {
      _isDialogShowing = true;
    });
    String url =
        '$commonapi/api/v1/postComments/addPostComment/' + widget.postId;
    print(url);
    var body = json.encode({"commentText": commentText.text});

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + SessionData().token
    };
    final request = await dio.post(url, data: body);
    print(request.statusCode);
    if (request.statusCode == 201) {
      commentText.text = '';
      if (_isDialogShowing) {
        Navigator.pop(context);
        setState(() {
          _isDialogShowing = false;
        });
      }

      print(request.data.toString());
      setState(() {
        singlePostComments = SinglePostComments.fromJson(request.data);
      });
      // goToLatest();
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
    }
  }
}
