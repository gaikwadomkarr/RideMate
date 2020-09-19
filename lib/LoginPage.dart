import 'dart:convert';

import 'package:bikingapp/Helpers/ShowNotificationHelper.dart';
import 'package:bikingapp/ProfilePage.dart';
import 'package:bikingapp/SignUpPage.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController useridText = new TextEditingController();
  TextEditingController passwordText = new TextEditingController();
  RegExp emailregex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool obscureText;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
          body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Colors.blue, Colors.blue[900]])),
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 2.5,
              child: Image.asset('assets/images/BikeIcon1.png'),
            ),
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                color: Colors.white,
              ),
              child: ListView(children: <Widget>[
                Container(
                  height: 55,
                  margin:
                      EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
                  child: TextFormField(
                    obscureText: false,
                    controller: useridText,
                    keyboardType: TextInputType.emailAddress,
                    style:
                        TextStyle(fontFamily: "WorkSansMedium", fontSize: 15),
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Colors.blue[700]),
                        labelText: 'Email Id *',
                        labelStyle: TextStyle(
                            color: Colors.blue[300],
                            fontFamily: "WorkSansMedium"),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey))),
                  ),
                ),
                Container(
                  height: 55,
                  margin:
                      EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
                  child: TextFormField(
                    obscureText: true,
                    controller: passwordText,
                    style:
                        TextStyle(fontFamily: "WorkSansMedium", fontSize: 15),
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Colors.blue[700]),
                        labelText: 'Password *',
                        labelStyle: TextStyle(
                            color: Colors.blue[300],
                            fontFamily: "WorkSansMedium"),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey))),
                  ),
                ),
                Container(
                        alignment: Alignment.bottomCenter,
                        height: 50,
                        width: 20,
                        // margin: EdgeInsets.fromLTRB(25, 15, 25, 10),
                        child: RaisedButton(
                          elevation: 1,
                          color: Colors.blue[400],
                          onPressed: (){
                            hitLogin();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Login', 
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                       Container(
                        // alignment: Alignment.bottomCenter,
                        height: 40,
                        width: 20,
                        margin: EdgeInsets.fromLTRB(25, 15, 25, 5),
                        child: RaisedButton(
                          elevation: 1,
                          color: Colors.blue[400],
                          onPressed: (){
                            // signUp();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Login with Google', 
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                       Container(
                        // alignment: Alignment.bottomCenter,
                        height: 40,
                        width: 20,
                        margin: EdgeInsets.fromLTRB(25, 15, 25, 10),
                        child: RaisedButton(
                          elevation: 1,
                          color: Colors.blue[400],
                          onPressed: (){
                            // signUp();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Login with Fcaebook', 
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            'Dont have an account ?',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: (){
                              print('you clicked on login');
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                            },
                            child: Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          ),
                        ),
                      )
              ]),
            ))
          ],
        ),
      )),
    );
  }

  void hitLogin() async {
    if(useridText.text.isNotEmpty && passwordText.text.isNotEmpty){
      if(emailregex.hasMatch(useridText.text)){
        apiCall();
      }
      else{
        showInSnackBar(context, 'Email format is not proper !', _scaffoldKey);
      }
    }
    else{
      showInSnackBar(context, 'Please fill up all the fields !', _scaffoldKey);
    }
  }

  void apiCall() async {
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.json;
    dio.options.headers['Content-Type'] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    try{
      FormData formData = FormData.fromMap({
        "email": useridText.text,
        "password": passwordText.text
      });
      print(formData.fields.toString());

      var body = json.encode({
        "email": useridText.text,
        "password": passwordText.text
      });
      final request = await dio.post('http://192.168.0.105:4000/auth/login', data: body);
      // final request = await http.post('http://192.168.0.104:4000/auth/login', body: body)
      print(request.statusCode);
      if(request.statusCode == 200){
        print('success');
        print(request.data);
        Map jsonResponse = request.data;
        showInSnackBar(context, jsonResponse['message'], _scaffoldKey);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage()));
      }
    }on DioError catch(e){
      print('failed');
      print(e.response.statusCode);
      print(e.response.data);
      Map jsonResponse = e.response.data;
      showInSnackBar(context, jsonResponse['message'], _scaffoldKey);
    }
  }
}
