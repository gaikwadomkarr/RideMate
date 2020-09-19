import 'dart:convert';

import 'package:bikingapp/LoginPage.dart';
import 'package:bikingapp/ProfilePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController name = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Colors.blue, Colors.blue[900]]),
          ),
          child: Column(children: <Widget>[
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
                  textformfields(
                      Icon(
                        Icons.person,
                        color: Colors.blue[700],
                      ),
                      name,
                      'Full Name *',
                      false),
                  textformfields(Icon(Icons.email, color: Colors.blue[700]),
                      email, 'Email Id *', false),
                  textformfields(
                      Icon(Icons.lock_outline, color: Colors.blue[700]),
                      password,
                      'Password *',
                      true),
                  Container(
                    // alignment: Alignment.bottomCenter,
                    height: 50,
                    width: 100,
                    margin: EdgeInsets.fromLTRB(25, 15, 25, 10),
                    child: RaisedButton(
                      elevation: 1,
                      color: Colors.blue[400],
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
                    margin: EdgeInsets.only(top: 20),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'Already a member ?',
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () {
                          print('you clicked on login');
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  )
                ]),
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget textformfields(Icon icon, TextEditingController controller,
      String label, bool obscureText) {
    return Container(
      height: 55,
      margin: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
      child: TextFormField(
        obscureText: obscureText,
        controller: controller,
        style: TextStyle(fontFamily: "WorkSansMedium", fontSize: 15),
        decoration: InputDecoration(
            prefixIcon: icon,
            labelText: label,
            labelStyle: TextStyle(
                color: Colors.blue[300], fontFamily: "WorkSansMedium"),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey))),
      ),
    );
  }

  Future<void> signUp() async {
    var data = json.encode({
      'name': name.text.toString(),
      'email': email.text.toString(),
      'password': password.text.toString()
    });

    final response = await http.post('http://192.168.0.105:4000/auth/signup',
        body: data,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        });
    print(data);
    print('this is the statuscode ' + response.statusCode.toString());

    if (response.statusCode == 200) {
      print(response.body.toString());
      print('sccess');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      print(response.body.toString());
      print('failed');
    }
  }
}
