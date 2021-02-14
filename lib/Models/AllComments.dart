// To parse this JSON data, do
//
//     final allComments = allCommentsFromJson(jsonString);

import 'dart:convert';

AllComments allCommentsFromJson(String str) =>
    AllComments.fromJson(json.decode(str));

String allCommentsToJson(AllComments data) => json.encode(data.toJson());

class AllComments {
  AllComments({
    this.success,
    this.count,
    this.data,
  });

  bool success;
  int count;
  List<SingleComments> data;

  factory AllComments.fromJson(Map<String, dynamic> json) => AllComments(
        success: json["success"] == null ? null : json["success"],
        count: json["count"] == null ? null : json["count"],
        data: json["data"] == null
            ? null
            : List<SingleComments>.from(
                json["data"].map((x) => SingleComments.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : success,
        "count": count == null ? null : count,
        "data": data == null
            ? null
            : List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class SingleComments {
  SingleComments({
    this.commentedAt,
    this.id,
    this.commentText,
    this.commentedByUserId,
    this.commentedByUserName,
    this.postDetails,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  String commentedAt;
  String id;
  String commentText;
  String commentedByUserId;
  String commentedByUserName;
  String postDetails;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  factory SingleComments.fromJson(Map<String, dynamic> json) => SingleComments(
        commentedAt: json["commentedAt"] == null ? null : json["commentedAt"],
        id: json["_id"] == null ? null : json["_id"],
        commentText: json["commentText"] == null ? null : json["commentText"],
        commentedByUserId: json["commentedByUserId"] == null
            ? null
            : json["commentedByUserId"],
        commentedByUserName: json["commentedByUserName"] == null
            ? null
            : json["commentedByUserName"],
        postDetails: json["postDetails"] == null ? null : json["postDetails"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"] == null ? null : json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "commentedAt": commentedAt == null ? null : commentedAt,
        "_id": id == null ? null : id,
        "commentText": commentText == null ? null : commentText,
        "commentedByUserId":
            commentedByUserId == null ? null : commentedByUserId,
        "commentedByUserName":
            commentedByUserName == null ? null : commentedByUserName,
        "postDetails": postDetails == null ? null : postDetails,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
        "__v": v == null ? null : v,
      };
}
