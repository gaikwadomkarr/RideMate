// To parse this JSON data, do
//
//     final sessionData = sessionDataFromJson(jsonString);

// import 'dart:convert';

// SessionData sessionDataFromJson(String str) => SessionData.fromJson(json.decode(str));

// String sessionDataToJson(SessionData data) => json.encode(data.toJson());

class SessionData {
    String message;
    String token;
    List<Datum> data;
    bool isFromHomePage;

    SessionData._internal();

  static final SessionData _instance = SessionData._internal();

  factory SessionData() => _instance;

    setData(message, token, data) {
        this.message = message;
        this.token = token;
        this.data = data;
    }

    setIsFromHomepage(bool isFromHomepage){
        this.isFromHomePage = isFromHomepage;
    }

    factory SessionData.fromJson(Map<String, dynamic> json) {
        String message = json["message"] == null ? null : json["message"];
        String token = json["token"] == null ? null : json["token"];
        List<Datum> data =  json["data"] == null ? null : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x)));

        return _instance.setData(message, token, data);
    }

    Map<String, dynamic> toJson() => {
        "message": message == null ? null : message,
        "token": token == null ? null : token,
        "data": data == null ? null : List<dynamic>.from(data.map((x) => x.toJson())),
    };

}

class Datum {
    String id;
    String name;
    String email;
    String password;
    int v;
    String city;

    Datum({
        this.id,
        this.name,
        this.email,
        this.password,
        this.v,
        this.city,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"] == null ? null : json["_id"],
        name: json["name"] == null ? null : json["name"],
        email: json["email"] == null ? null : json["email"],
        password: json["password"] == null ? null : json["password"],
        v: json["__v"] == null ? null : json["__v"],
        city: json["city"] == null ? null : json["city"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id == null ? null : id,
        "name": name == null ? null : name,
        "email": email == null ? null : email,
        "password": password == null ? null : password,
        "__v": v == null ? null : v,
        "city": city == null ? null : city,
    };
}
