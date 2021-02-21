// To parse this JSON data, do
//
//     final singlePostComments = singlePostCommentsFromJson(jsonString);

import 'dart:convert';

SinglePostComments singlePostCommentsFromJson(String str) =>
    SinglePostComments.fromJson(json.decode(str));

String singlePostCommentsToJson(SinglePostComments data) =>
    json.encode(data.toJson());

class SinglePostComments {
  SinglePostComments({
    this.success,
    this.postDetails,
  });

  bool success;
  PostDetails postDetails;

  factory SinglePostComments.fromJson(Map<String, dynamic> json) =>
      SinglePostComments(
        success: json["success"] == null ? null : json["success"],
        postDetails: json["singlePostComments"] == null
            ? null
            : PostDetails.fromJson(json["singlePostComments"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : success,
        "singlePostComments": postDetails == null ? null : postDetails.toJson(),
      };
}

class PostDetails {
  PostDetails({
    this.comments,
    this.id,
  });

  List<Comment> comments;
  String id;

  factory PostDetails.fromJson(Map<String, dynamic> json) => PostDetails(
        comments: json["comments"] == null
            ? null
            : List<Comment>.from(
                json["comments"].map((x) => Comment.fromJson(x))),
        id: json["_id"] == null ? null : json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "comments": comments == null
            ? null
            : List<dynamic>.from(comments.map((x) => x.toJson())),
        "_id": id == null ? null : id,
      };
}

class Comment {
  Comment({
    this.id,
    this.commentText,
    this.commentedByUserId,
    this.commentedByUserName,
    this.createdAt,
  });

  String id;
  String commentText;
  String commentedByUserId;
  String commentedByUserName;
  DateTime createdAt;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["_id"] == null ? null : json["_id"],
        commentText: json["commentText"] == null ? null : json["commentText"],
        commentedByUserId: json["commentedByUserId"] == null
            ? null
            : json["commentedByUserId"],
        commentedByUserName: json["commentedByUserName"] == null
            ? null
            : json["commentedByUserName"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id == null ? null : id,
        "commentText": commentText == null ? null : commentText,
        "commentedByUserId":
            commentedByUserId == null ? null : commentedByUserId,
        "commentedByUserName":
            commentedByUserName == null ? null : commentedByUserName,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
      };
}
