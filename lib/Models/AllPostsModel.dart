// To parse this JSON data, do
//
//     final allPostsModel = allPostsModelFromJson(jsonString);

import 'dart:convert';

AllPostsModel allPostsModelFromJson(String str) =>
    AllPostsModel.fromJson(json.decode(str));

String allPostsModelToJson(AllPostsModel data) => json.encode(data.toJson());

class AllPostsModel {
  AllPostsModel({
    this.success,
    this.count,
    this.data,
  });

  bool success;
  int count;
  List<Datum> data;

  factory AllPostsModel.fromJson(Map<String, dynamic> json) => AllPostsModel(
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
    this.postImages,
    this.likes,
    this.comments,
    this.postCreatedAt,
    this.id,
    this.title,
    this.body,
    this.postedBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  List<String> postImages;
  List<dynamic> likes;
  List<dynamic> comments;
  String postCreatedAt;
  String id;
  String title;
  String body;
  PostedBy postedBy;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        postImages: json["postImages"] == null
            ? null
            : List<String>.from(json["postImages"].map((x) => x)),
        likes: json["likes"] == null
            ? null
            : List<dynamic>.from(json["likes"].map((x) => x)),
        comments: json["comments"] == null
            ? null
            : List<dynamic>.from(json["comments"].map((x) => x)),
        postCreatedAt:
            json["postCreatedAt"] == null ? null : json["postCreatedAt"],
        id: json["_id"] == null ? null : json["_id"],
        title: json["title"] == null ? null : json["title"],
        body: json["body"] == null ? null : json["body"],
        postedBy: json["postedBy"] == null
            ? null
            : PostedBy.fromJson(json["postedBy"]),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"] == null ? null : json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "postImages": postImages == null
            ? null
            : List<dynamic>.from(postImages.map((x) => x)),
        "likes": likes == null ? null : List<dynamic>.from(likes.map((x) => x)),
        "comments": comments == null
            ? null
            : List<dynamic>.from(comments.map((x) => x)),
        "postCreatedAt": postCreatedAt == null ? null : postCreatedAt,
        "_id": id == null ? null : id,
        "title": title == null ? null : title,
        "body": body == null ? null : body,
        "postedBy": postedBy == null ? null : postedBy.toJson(),
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
        "__v": v == null ? null : v,
      };
}

class PostedBy {
  PostedBy({
    this.id,
    this.name,
  });

  String id;
  String name;

  factory PostedBy.fromJson(Map<String, dynamic> json) => PostedBy(
        id: json["_id"] == null ? null : json["_id"],
        name: json["name"] == null ? null : json["name"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id == null ? null : id,
        "name": name == null ? null : name,
      };
}
