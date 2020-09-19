import 'package:bikingapp/AddUpdateBike.dart';
import 'package:bikingapp/Helpers/AppConstants.dart';
import 'package:bikingapp/Models/SessionData.dart';
import 'package:bikingapp/Models/ViewProfile.dart';
import 'package:bikingapp/ProfilePage1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class BioPage extends StatefulWidget {
  const BioPage({
    Key key,
    @required this.refresh,
    @required this.widget,
    @required this.viewProfile,
  }) : super(key: key);

  final Future<ViewProfile> refresh;
  final ProfilePage1 widget;
  final ViewProfile viewProfile;

  @override
  _BioPageState createState() => _BioPageState();
}

class _BioPageState extends State<BioPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ViewProfile>(
      future: widget.refresh,
      builder: (BuildContext context,
          AsyncSnapshot<ViewProfile> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            child: Text('Loading'),
          );
        } else {
          return ListView(
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
                              offset:
                                  const Offset(0.0, 0.0),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                                margin: EdgeInsets.all(10),
                                alignment:
                                    Alignment.centerLeft,
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      'Garage',
                                      style: TextStyle(
                                          color: color1,
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ],
                                )
                              ),
                            
                            Container(
                              height: 120,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  widget.widget.userId == SessionData().data[0].id ? GestureDetector(
                                          onTap: (){
                                          },
                                          child: Container(
                                            width: 90,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  height: 70,
                                                  width: 70,
                                                  margin: EdgeInsets
                                                      .all(10),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(15),
                                                        color: color2
                                                      ),
                                                  child: Icon(FlutterIcons.add_mdi, color: Colors.white,size: 40,),
                                                ),
                                                Text(
                                                  'Add New',
                                                  overflow:
                                                      TextOverflow
                                                          .fade,
                                                  softWrap: false,
                                                  style: TextStyle(
                                                      color: color1,
                                                      fontWeight:
                                                          FontWeight
                                                              .normal,
                                                      fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ) : Container(),
                                  ListView(
                                    scrollDirection:
                                        Axis.horizontal,
                                        shrinkWrap: true,
                                    children: List.generate(
                                        widget.viewProfile.myGarage
                                            .length, (index) {
                                              print(widget.viewProfile
                                                        .myGarage[
                                                            index]
                                                        .imageUrl.toString());
                                      return GestureDetector(
                                        onTap: (){
                                          print('Tapped $index bike');
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddUpdateBike(viewProfile: widget.viewProfile,index: index,)));
                                          print(widget.viewProfile
                                                        .myGarage[
                                                            index]
                                                        .imageUrl.toString());
                                        },
                                        child: Container(
                                          width: 90,
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets
                                                    .all(10),
                                                child: CircleAvatar(
                                                    radius: 35,
                                                    backgroundImage: NetworkImage(widget.viewProfile
                                                        .myGarage[
                                                            index]
                                                        .imageUrl.toString())),
                                              ),
                                              Text(
                                                widget.viewProfile
                                                    .myGarage[
                                                        index]
                                                    .model,
                                                overflow:
                                                    TextOverflow
                                                        .fade,
                                                softWrap: false,
                                                style: TextStyle(
                                                    color: color1,
                                                    fontWeight:
                                                        FontWeight
                                                            .normal,
                                                    fontSize: 13),
                                              ),
                                            ],
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
        }
      },
    );
  }
}