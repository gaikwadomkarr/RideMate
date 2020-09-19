import 'package:bikingapp/HomeScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController name = new TextEditingController();
  TextEditingController city = new TextEditingController();
  TextEditingController email = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: null,
      child: SafeArea(
        child: Scaffold(
            body: Container(
          color: Colors.blue[600],
          child: Column(children: <Widget>[
            Container(
              height: 40,
              padding: EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                      },
                      child: Icon(Icons.arrow_back_ios,
                          size: 20, color: Colors.white)),
                  Icon(Icons.menu, size: 25, color: Colors.white),
                ],
              ),
            ),
            CircleAvatar(
                radius: 60, child: Image.asset('assets/images/biker.png')),
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              margin: EdgeInsets.only(top: 20),
              child: ListView(children: <Widget>[
                textformfields(name, 'Full Name *'),
                textformfields(email, 'Email Id *'),
                textformfields(city, 'City'),
                Divider(),
                Container(
                  alignment: Alignment.bottomCenter,
                  height: 40,
                  width: 120,
                  margin: EdgeInsets.fromLTRB(10, 15, 0, 10),
                  child: RaisedButton(
                    elevation: 1,
                    color: Colors.blue[400],
                    onPressed: () {
                      sendData();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      'Update',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                )
              ]),
            ))
          ]),
        )),
      ),
    );
  }

  Widget textformfields(TextEditingController controller, String label) {
    return Container(
      height: 55,
      margin: EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.blue[300],
            ),
            border: OutlineInputBorder()),
      ),
    );
  }

  Future<void> sendData() async {
    var data = json.encode({
      'name': name.text.toString(),
      'city': city.text.toString(),
      'email': email.text
    });

    final response = await http.post('http://192.168.0.105:4000/api/riders',
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
    } else {
      print(response.body.toString());
      print('failed');
    }
  }
}
