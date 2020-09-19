// To parse this JSON data, do
//
//     final allEventsModel = allEventsModelFromJson(jsonString);

import 'dart:convert';

AllEventsModel allEventsModelFromJson(String str) =>
    AllEventsModel.fromJson(json.decode(str));

String allEventsModelToJson(AllEventsModel data) => json.encode(data.toJson());

class AllEventsModel {
  AllEventsModel({
    this.success,
    this.count,
    this.data,
  });

  bool success;
  int count;
  List<Datum> data;

  factory AllEventsModel.fromJson(Map<String, dynamic> json) => AllEventsModel(
        success: json["success"] == null ? null : json["success"],
        count: json["count"] == null ? null : json["count"],
        data: json["data"] == null
            ? null
            : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : success,
        "count": count == null ? null : count,
        "data": data == null
            ? null
            : List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    this.joinEvent,
    this.eventComments,
    this.eventImages,
    this.id,
    this.eventType,
    this.title,
    this.description,
    this.eventDate,
    this.eventTime,
    this.organizedById,
    this.organizedByUser,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  List<dynamic> joinEvent;
  List<dynamic> eventComments;
  List<String> eventImages;
  String id;
  String eventType;
  String title;
  String description;
  String eventDate;
  String eventTime;
  String organizedById;
  String organizedByUser;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        joinEvent: json["joinEvent"] == null
            ? null
            : List<dynamic>.from(json["joinEvent"].map((x) => x)),
        eventComments: json["eventComments"] == null
            ? null
            : List<dynamic>.from(json["eventComments"].map((x) => x)),
        eventImages: json["eventImages"] == null
            ? null
            : List<String>.from(json["eventImages"].map((x) => x)),
        id: json["_id"] == null ? null : json["_id"],
        eventType: json["eventType"] == null ? null : json["eventType"],
        title: json["title"] == null ? null : json["title"],
        description: json["description"] == null ? null : json["description"],
        eventDate: json["eventDate"] == null ? null : json["eventDate"],
        eventTime: json["eventTime"] == null ? null : json["eventTime"],
        organizedById:
            json["organizedById"] == null ? null : json["organizedById"],
        organizedByUser:
            json["organizedByUser"] == null ? null : json["organizedByUser"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"] == null ? null : json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "joinEvent": joinEvent == null
            ? null
            : List<dynamic>.from(joinEvent.map((x) => x)),
        "eventComments": eventComments == null
            ? null
            : List<dynamic>.from(eventComments.map((x) => x)),
        "eventImages": eventImages == null
            ? null
            : List<dynamic>.from(eventImages.map((x) => x)),
        "_id": id == null ? null : id,
        "eventType": eventType == null ? null : eventType,
        "title": title == null ? null : title,
        "description": description == null ? null : description,
        "eventDate": eventDate == null ? null : eventDate,
        "eventTime": eventTime == null ? null : eventTime,
        "organizedById": organizedById == null ? null : organizedById,
        "organizedByUser": organizedByUser == null ? null : organizedByUser,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
        "__v": v == null ? null : v,
      };
}
