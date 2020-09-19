import 'package:bikingapp/Helpers/AppConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

void showInSnackBar(
    BuildContext context, String value, GlobalKey<ScaffoldState> _key) {
  FocusScope.of(context).requestFocus(new FocusNode());
  _key.currentState?.removeCurrentSnackBar();
  _key.currentState.showSnackBar(new SnackBar(
    backgroundColor: color2,
    content: new Text(
      value,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.white, fontSize: 15, fontFamily: "WorkSansMedium"),
    ),
    duration: Duration(seconds: 3),
  ));
}

void showLoaderDialog(BuildContext context, String value) {
  final spinkit = SpinKitSquareCircle(
    color: Colors.white,
    size: 50.0,
    duration: Duration(milliseconds: 1000),
  );
  showDialog(
      context: context,
      builder: (context) => Material(
          type: MaterialType.transparency,
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                spinkit,
                Text("\n" + value,
                    style: TextStyle(
                      fontSize: 15,
                    ))
              ]))));
}

void showProfileOptions(BuildContext context, String button1, String button2,
    String button3, Function onTap1, Function onTap2, Function onTap3) {
  showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25))),
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Container(
                    // margin: EdgeInsets.only(left: 10),
                    child: IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 25,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context)),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Text('Select one to Update your Profile',
                      style: TextStyle(color: Colors.grey[600])),
                  const Spacer(flex: 3)
                ],
              ),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                child: Container(
                  height: 35,
                  width: 200,
                  color: color2,
                  child: MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.white24,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: Text(
                          button1,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onPressed: onTap1),
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                child: Container(
                  height: 35,
                  width: 200,
                  color: color2,
                  child: MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.white24,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: Text(
                          button2,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onPressed: onTap2),
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                child: Container(
                  height: 35,
                  width: 200,
                  color: color2,
                  child: MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.white24,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: Text(
                          button3,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onPressed: onTap3),
                ),
              ),
            ],
          ),
        );
      });
}

menuOptions(
    BuildContext context, String title, int index, Widget contentWidget) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            titleTextStyle: TextStyle(
                color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            contentTextStyle: TextStyle(color: Colors.black, fontSize: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.all(10),
            content: contentWidget);
      });
}
