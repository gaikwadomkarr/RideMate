import 'dart:convert';

import 'package:bikingapp/Helpers/AppConstants.dart';
import 'package:bikingapp/Helpers/ShowNotificationHelper.dart';
import 'package:bikingapp/Helpers/TabIndicationPainters.dart';
import 'package:bikingapp/HomeScreen.dart';
import 'package:bikingapp/Models/SessionData.dart';
import 'package:bikingapp/ProfilePage.dart';
import 'package:bikingapp/SignUpPage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage1 extends StatefulWidget {
  @override
  _LoginPage1State createState() => _LoginPage1State();
}

class _LoginPage1State extends State<LoginPage1> {
  PageController _pageController;
  bool obscureText = true;
  bool isDialogShowing = false;
  TextEditingController usernameTxt = new TextEditingController();
  TextEditingController passwordTxt = new TextEditingController();
  TextEditingController emailTxt = new TextEditingController();
  TextEditingController nameTxt = new TextEditingController();
  TextEditingController createPassTxt = new TextEditingController();
  RegExp emailregex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final usernameFocus = FocusNode();
  final passwordFocus = FocusNode();
  final emailFocus = FocusNode();
  final nameFocus = FocusNode();
  final createpassFocus = FocusNode();

  Color left = Colors.white;
  Color right = Colors.blue[900];

  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: null,
      child: SafeArea(
        child: Scaffold(
            key: _scaffoldKey,
            body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: <Color>[color1, color2])),
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowGlow();
                },
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height / 2.45,
                        child: Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: <Widget>[
                            Align(
                              alignment: AlignmentDirectional.topStart,
                              child: Container(
                                  padding: EdgeInsets.only(bottom: 30),
                                  height:
                                      MediaQuery.of(context).size.height / 2.6,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20))),
                                  child: Stack(
                                    children: <Widget>[],
                                  )),
                            ),
                            Align(
                                alignment: AlignmentDirectional.center,
                                child: Container(
                                    // margin: EdgeInsets.only(top: 40),
                                    child: Image.asset(
                                        'assets/images/BikeIcon.png'))),
                            Align(
                              alignment: AlignmentDirectional.bottomCenter,
                              child: Container(child: _buildMenuBar(context)),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (i) {
                            if (i == 0) {
                              setState(() {
                                right = Colors.blue[900];
                                left = Colors.white;
                              });
                            } else if (i == 1) {
                              setState(() {
                                right = Colors.white;
                                left = Colors.blue[900];
                              });
                            }
                          },
                          children: <Widget>[
                            new ConstrainedBox(
                              constraints: const BoxConstraints.expand(),
                              child: loginContainer(),
                            ),
                            new ConstrainedBox(
                              constraints: const BoxConstraints.expand(),
                              child: signUpContainer(),
                            ),
                          ],
                        ),
                      ),
                    ]),
              ),
            )),
      ),
    );
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 320,
      height: 40.0,
      decoration: BoxDecoration(
        // color: Color(0x552B2B2B),
        color: Colors.blue[50],
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  _pageController.animateToPage(0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease);
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: left,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  _pageController.animateToPage(1,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease);
                },
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    color: right,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void changeObscureText() {
    if (obscureText) {
      setState(() {
        obscureText = false;
      });
    } else {
      setState(() {
        obscureText = true;
      });
    }
  }

  Widget loginContainer() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 15, 20, 0),
      child: ListView(
          // mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(height: 15),
            TextFormField(
              controller: usernameTxt,
              autocorrect: false,
              // textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.emailAddress,
              focusNode: usernameFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (terms) {
                _fieldFocusChange(context, usernameFocus, passwordFocus);
              },
              style: TextStyle(color: Colors.black),
              decoration: new InputDecoration(
                  prefixIcon: Icon(
                    FlutterIcons.email_outline_mco,
                    color: Colors.black,
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  hintText: 'Email Id *', // add hinttext in case Design
                  counterText: "",
                  hintStyle: TextStyle(color: Colors.black54)),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: passwordTxt,
              keyboardType: TextInputType.text,
              focusNode: passwordFocus,
              textInputAction: TextInputAction.done,
              obscureText: obscureText,
              style: TextStyle(color: Colors.black),
              decoration: new InputDecoration(
                  prefixIcon: Icon(
                    FlutterIcons.lock_outline_mco,
                    color: Colors.black,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      changeObscureText();
                    },
                    child: Icon(
                      obscureText
                          ? FlutterIcons.eye_mco
                          : FlutterIcons.eye_off_mco,
                      color: Colors.black,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  hintText: 'Password *', // add hinttext in case Design
                  counterText: "",
                  hintStyle: TextStyle(color: Colors.black54)),
            ),
            SizedBox(height: 100),
            Container(
              // alignment: Alignment.bottomCenter,
              height: 40,
              width: 150,
              margin: EdgeInsets.fromLTRB(75, 0, 75, 0),
              child: RaisedButton(
                elevation: 1,
                color: Colors.redAccent,
                onPressed: () {
                  hitLogin();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
            Container(
              alignment: AlignmentDirectional.bottomCenter,
              margin: EdgeInsets.only(top: 40, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ClipOval(
                      child: Container(
                    height: 50,
                    width: 50,
                    color: Colors.white,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    // child: Image.asset('assets/images/googleIcon.png',height: 30)
                    child: Text(
                      'f',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF36BF8D),
                          fontSize: 35),
                    ),
                  )),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Colors.black54, fontSize: 18),
                    ),
                  ),
                  ClipOval(
                      child: Container(
                    height: 50,
                    width: 50,
                    color: Colors.white,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    // child: Image.asset('assets/images/fbIcon.png',height: 30)
                    child: Text(
                      'G',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF36BF8D),
                          fontSize: 35),
                    ),
                  ))
                ],
              ),
            )
          ]),
    );
  }

  Widget signUpContainer() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 15, 20, 0),
      child: ListView(
          // mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(height: 15),
            TextFormField(
              controller: nameTxt,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              focusNode: nameFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (terms) {
                _fieldFocusChange(context, nameFocus, emailFocus);
              },
              style: TextStyle(color: Colors.black),
              decoration: new InputDecoration(
                  prefixIcon: Icon(
                    FlutterIcons.person_outline_mdi,
                    color: Colors.black,
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  hintText: 'Full Name *', // add hinttext in case Design
                  counterText: "",
                  hintStyle: TextStyle(color: Colors.black54)),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: emailTxt,
              keyboardType: TextInputType.emailAddress,
              focusNode: emailFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (terms) {
                _fieldFocusChange(context, emailFocus, createpassFocus);
              },
              style: TextStyle(color: Colors.black),
              decoration: new InputDecoration(
                  prefixIcon: Icon(
                    FlutterIcons.email_outline_mco,
                    color: Colors.black,
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  hintText: 'Email *', // add hinttext in case Design
                  counterText: "",
                  hintStyle: TextStyle(color: Colors.black54)),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: createPassTxt,
              keyboardType: TextInputType.emailAddress,
              focusNode: createpassFocus,
              textInputAction: TextInputAction.done,
              style: TextStyle(color: Colors.black),
              decoration: new InputDecoration(
                  prefixIcon: Icon(
                    FlutterIcons.lock_outline_mco,
                    color: Colors.black,
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  hintText: 'Create Password *', // add hinttext in case Design
                  counterText: "",
                  hintStyle: TextStyle(color: Colors.black54)),
            ),
            SizedBox(height: 50),
            Container(
              // alignment: Alignment.bottomCenter,
              height: 40,
              // width: 150,
              margin: EdgeInsets.fromLTRB(75, 0, 75, 0),
              child: RaisedButton(
                elevation: 1,
                color: Colors.redAccent,
                onPressed: () {
                  signUp();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
            Container(
              alignment: AlignmentDirectional.bottomCenter,
              margin: EdgeInsets.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ClipOval(
                      child: Container(
                    height: 50,
                    width: 50,
                    color: Colors.white,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    // child: Image.asset('assets/images/googleIcon.png',height: 30)
                    child: Text(
                      'f',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF36BF8D),
                          fontSize: 35),
                    ),
                  )),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Colors.black54, fontSize: 18),
                    ),
                  ),
                  ClipOval(
                      child: Container(
                    height: 50,
                    width: 50,
                    color: Colors.white,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    // child: Image.asset('assets/images/fbIcon.png',height: 30)
                    child: Text(
                      'G',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF36BF8D),
                          fontSize: 35),
                    ),
                  ))
                ],
              ),
            )
          ]),
    );
  }

  void hitLogin() async {
    if (usernameTxt.text.isNotEmpty && passwordTxt.text.isNotEmpty) {
      if (emailregex.hasMatch(usernameTxt.text)) {
        apiCall();
      } else {
        showInSnackBar(context, 'Email format is not proper !', _scaffoldKey);
      }
    } else {
      showInSnackBar(context, 'Please fill up all the fields !', _scaffoldKey);
    }
  }

  void apiCall() async {
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.json;
    dio.options.headers['Content-Type'] = "application/json";
    dio.options.headers["Accept"] = "application/json";

    showLoaderDialog(context, 'Loging In...');
    setState(() {
      isDialogShowing = true;
    });
    try {
      FormData formData = FormData.fromMap(
          {"email": usernameTxt.text, "password": passwordTxt.text});
      print(formData.fields.toString());

      var body = json
          .encode({"email": usernameTxt.text, "password": passwordTxt.text});
      final request = await dio.post(commonapi + '/auth/login', data: body);
      // final request = await http.post('http://192.168.0.104:4000/auth/login', body: body)
      print(request.statusCode);
      if (request.statusCode == 200) {
        print('success');
        if (isDialogShowing) {
          Navigator.pop(context);
          setState(() {
            isDialogShowing = false;
          });
        }
        print(request.data);
        SessionData.fromJson(request.data);
        Map jsonResponse = request.data;
        showInSnackBar(context, jsonResponse['message'], _scaffoldKey);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomeScreen(index: 0)));
      }
    } on DioError catch (e) {
      print('failed');
      if (isDialogShowing) {
        Navigator.pop(context);
        setState(() {
          isDialogShowing = false;
        });
      }
      print(e.response.statusCode);
      print(e.response.data);
      Map jsonResponse = e.response.data;
      showInSnackBar(context, jsonResponse['message'], _scaffoldKey);
    }
  }

  Future<void> signUp() async {
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.json;
    dio.options.headers['Content-Type'] = "application/json";
    dio.options.headers["Accept"] = "application/json";

    showLoaderDialog(context, "Signing Up...");
    setState(() {
      isDialogShowing = true;
    });

    try {
      var data = json.encode({
        'name': nameTxt.text.toString(),
        'email': emailTxt.text.toString(),
        'password': createPassTxt.text.toString()
      });

      final response = await dio.post(commonapi + '/auth/signup', data: data);
      print(data);
      print('this is the statuscode ' + response.statusCode.toString());

      if (response.statusCode == 200) {
        print(response.data.toString());
        print('sccess');
        setState(() {
          nameTxt.clear();
          emailTxt.clear();
          createPassTxt.clear();
        });
        if (isDialogShowing) {
          Navigator.of(context).pop();
          setState(() {
            isDialogShowing = false;
          });
        }
        _pageController.animateToPage(0,
            duration: Duration(milliseconds: 300), curve: Curves.ease);
      }
    } on DioError catch (e) {
      print(e.response.data.toString());
      print('failed');
      if (isDialogShowing) {
        Navigator.of(context).pop();
        setState(() {
          isDialogShowing = false;
        });
      }
      Map jsonResponse = e.response.data;
      showInSnackBar(context, jsonResponse['message'], _scaffoldKey);
    }
  }
}
