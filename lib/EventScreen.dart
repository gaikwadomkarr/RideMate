import 'package:bikingapp/Helpers/AppConstants.dart';
import 'package:bikingapp/Helpers/LayoutHelpers.dart';
import 'package:bikingapp/Models/AllEventsModel.dart';
import 'package:bikingapp/Models/SessionData.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  Dio dio = new Dio();
  bool _isDialogShowing = false;
  AllEventsModel allEventsModel;
  Future<AllEventsModel> refresh;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageCache.clear();
    timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
    dio.options.headers['Authorization'] = 'Bearer ' + SessionData().token;
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.responseType = ResponseType.json;
    refresh = getAllEvents();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {},
      child: SafeArea(
        child: Scaffold(
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
                        color: color1,
                        fontSize: 20,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: Container(child: buildEvents()),
        ),
      ),
    );
  }

  Widget buildEvents() {
    return FutureBuilder<AllEventsModel>(
        future: refresh,
        builder:
            (BuildContext context, AsyncSnapshot<AllEventsModel> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (allEventsModel.count > 0) {
            return ListView(
                children: List.generate(allEventsModel.count, (index) {
              return Container(
                margin: EdgeInsets.fromLTRB(15, 15, 15, 10),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 0.0),
                    ),
                  ],
                ),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  ListTile(
                    leading: Container(
                      height: 40,
                      width: 40,
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: AssetImage('assets/images/OLQE6Q0.jpg'))),
                    ),
                    title: GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.only(left: 5),
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          allEventsModel.data[index].organizedByUser,
                          style: mediumTxtStyle().copyWith(fontSize: 15),
                        ),
                      ),
                    ),
                    subtitle: null,
                    trailing: Container(
                      child: GestureDetector(
                        // key: btnkeys[outerindex],
                        // onTap: () {
                        //   menuOptions(context, "Choose One", outerindex,
                        //       postOptions(outerindex));
                        //   selectedPostId = postIds[outerindex];
                        // },
                        child: Icon(
                          Icons.more_horiz_rounded,
                          color: color1,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    // margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    height: 220,
                    child: Stack(
                      children: [
                        Image.network(
                          allEventsModel.data[index].eventImages[0],
                          fit: BoxFit.fill,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20)),
                              color: color2.withOpacity(0.75),
                            ),
                            child: Text(
                              allEventsModel.data[index].eventType,
                              style: mediumTxtStyle().copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Text(
                      allEventsModel.data[index].title,
                      style: mediumTxtStyle().copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: ReadMoreText(
                      allEventsModel.data[index].description,
                      trimMode: TrimMode.Line,
                      trimLines: 2,
                      trimCollapsedText: ' ...read more',
                      trimExpandedText: ' read less',
                      style: regularTxtStyle.copyWith(color: Colors.black54),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 15, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    FlutterIcons.location_ent,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Miami, USA')
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Icon(FlutterIcons.people_mdi, size: 20),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('15 people')
                                ],
                              )
                            ]),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(FlutterIcons.calendar_faw, size: 20),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(allEventsModel.data[index].eventDate)
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Icon(FlutterIcons.clock_faw5, size: 20),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(allEventsModel.data[index].eventTime)
                                ],
                              )
                            ])
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    height: 40,
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          height: 35,
                          child: FloatingActionButton.extended(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              backgroundColor: color2,
                              splashColor: Colors.white24,
                              label: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10),
                                child: Text(
                                  "Join",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              onPressed: () async {}),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          height: 35,
                          alignment: Alignment.center,
                          // margin: EdgeInsets.only(left: 10),
                          child: GestureDetector(
                              onTap: () {},
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
                              '89',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            )),
                        Spacer(),
                        Container(
                            child: new Text(
                          Jiffy(
                                  allEventsModel.data[index].eventDate +
                                      ' ' +
                                      allEventsModel.data[index].eventTime,
                                  'dd/MM/yyyy hh:mm a')
                              .fromNow(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.normal),
                        )),
                      ],
                    ),
                  ),
                ]),
              );
            }));
          } else {
            return Center(child: Text('No Data'));
          }
        });
  }

  Future<AllEventsModel> getAllEvents() async {
    setState(() {
      _isDialogShowing = true;
    });
    print(commonapi + '/api/v1/event/allEvents');
    try {
      final request = await dio.get(commonapi + '/api/v1/event/allEvents');
      print(request.statusCode);
      print(request.data);

      if (request.statusCode == 200) {
        setState(() {
          _isDialogShowing = false;
          allEventsModel = AllEventsModel.fromJson(request.data);
        });
      } else {
        setState(() {
          _isDialogShowing = false;
        });
      }
    } on DioError catch (e) {
      setState(() {
        _isDialogShowing = false;
      });
    }

    return allEventsModel;
  }
}
