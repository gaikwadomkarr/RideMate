// To parse this JSON data, do
//
//     final viewProfile = viewProfileFromJson(jsonString);

import 'dart:convert';

ViewProfile viewProfileFromJson(String str) => ViewProfile.fromJson(json.decode(str));

String viewProfileToJson(ViewProfile data) => json.encode(data.toJson());

class ViewProfile {
    ViewProfile({
        this.success,
        this.userDetails,
        this.userPostDetails,
        this.myGarage
    });

    bool success;
    UserDetails userDetails;
    List<UserPostDetail> userPostDetails;
    List<MyGarage> myGarage;

    factory ViewProfile.fromJson(Map<String, dynamic> json) => ViewProfile(
        success: json["success"] == null ? null : json["success"],
        userDetails: json["userDetails"] == null ? null : UserDetails.fromJson(json["userDetails"]),
        userPostDetails: json["userPostDetails"] == null ? null : List<UserPostDetail>.from(json["userPostDetails"].map((x) => UserPostDetail.fromJson(x))),
        myGarage: json['myGarage'] == null ? null : List<MyGarage>.from(json['myGarage'].map((x) => MyGarage.fromJson(x)))
    );

    Map<String, dynamic> toJson() => {
        "success": success == null ? null : success,
        "userDetails": userDetails == null ? null : userDetails.toJson(),
        "userPostDetails": userPostDetails == null ? null : List<dynamic>.from(userPostDetails.map((x) => x.toJson())),
        "myGarage": myGarage == null ? null : List<dynamic>.from(myGarage.map((x) => x.toJson()))
    };
}

class UserDetails {
    UserDetails({
        this.likedPostByYou,
        this.following,
        this.followers,
        this.id,
        this.name,
        this.email,
        this.city,
    });

    List<dynamic> likedPostByYou;
    List<Following> following;
    List<Followers> followers;
    String id;
    String name;
    String email;
    String city;

    factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        likedPostByYou: json["likedPostByYou"] == null ? null : List<dynamic>.from(json["likedPostByYou"].map((x) => x)),
        following: json["following"] == null ? null : List<Following>.from(json["following"].map((x) => Following.fromJson(x))),
        followers: json["followers"] == null ? null : List<Followers>.from(json["followers"].map((x) => Followers.fromJson(x))),
        id: json["_id"] == null ? null : json["_id"],
        name: json["name"] == null ? null : json["name"],
        email: json["email"] == null ? null : json["email"],
        city: json["city"] == null ? null : json["city"],
    );

    Map<String, dynamic> toJson() => {
        "likedPostByYou": likedPostByYou == null ? null : List<dynamic>.from(likedPostByYou.map((x) => x)),
        "following": following == null ? null : List<dynamic>.from(following.map((x) => x.toJson())),
        "followers": followers == null ? null : List<dynamic>.from(followers.map((x) => x.toJson())),
        "_id": id == null ? null : id,
        "name": name == null ? null : name,
        "email": email == null ? null : email,
        "city": city == null ? null : city,
    };
}

class Following {
    Following({
        this.id,
        this.name,
    });

    String id;
    String name;

    factory Following.fromJson(Map<String, dynamic> json) => Following(
        id: json["_id"] == null ? null : json["_id"],
        name: json["name"] == null ? null : json["name"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id == null ? null : id,
        "name": name == null ? null : name,
    };
}

class Followers {
    Followers({
        this.id,
        this.name,
    });

    String id;
    String name;

    factory Followers.fromJson(Map<String, dynamic> json) => Followers(
        id: json["_id"] == null ? null : json["_id"],
        name: json["name"] == null ? null : json["name"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id == null ? null : id,
        "name": name == null ? null : name,
    };
}


class UserPostDetail {
    UserPostDetail({
        this.likes,
        this.isLiked,
        this.comments,
        this.id,
        this.title,
        this.body,
        this.postedBy,
        this.photoUrl,
    });

    List<Following> likes;
    bool isLiked;
    List<Comment> comments;
    String id;
    String title;
    String body;
    Following postedBy;
    String photoUrl;

    factory UserPostDetail.fromJson(Map<String, dynamic> json) => UserPostDetail(
        likes: json["likes"] == null ? null : List<Following>.from(json["likes"].map((x) => Following.fromJson(x))),
        isLiked: json["isLiked"] == null ? null : json["isLiked"],
        comments: json["comments"] == null ? null : List<Comment>.from(json["comments"].map((x) => Comment.fromJson(x))),
        id: json["_id"] == null ? null : json["_id"],
        title: json["title"] == null ? null : json["title"],
        body: json["body"] == null ? null : json["body"],
        postedBy: json["postedBy"] == null ? null : Following.fromJson(json["postedBy"]),
        photoUrl: json["photoUrl"] == null ? null : json["photoUrl"],
    );

    Map<String, dynamic> toJson() => {
        "likes": likes == null ? null : List<dynamic>.from(likes.map((x) => x.toJson())),
        "isLiked": isLiked == null ? null : isLiked,
        "comments": comments == null ? null : List<dynamic>.from(comments.map((x) => x.toJson())),
        "_id": id == null ? null : id,
        "title": title == null ? null : title,
        "body": body == null ? null : body,
        "postedBy": postedBy == null ? null : postedBy.toJson(),
        "photoUrl": photoUrl == null ? null : photoUrl,
    };
}

class Comment {
    Comment({
        this.id,
        this.commentText,
        this.commentedByUserName,
    });

    String id;
    String commentText;
    String commentedByUserName;

    factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["_id"] == null ? null : json["_id"],
        commentText: json["commentText"] == null ? null : json["commentText"],
        commentedByUserName: json["commentedByUserName"] == null ? null : json["commentedByUserName"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id == null ? null : id,
        "commentText": commentText == null ? null : commentText,
        "commentedByUserName": commentedByUserName == null ? null : commentedByUserName,
    };
}

class MyGarage {
    MyGarage({
        this.vehicleCreatedAt,
        this.id,
        this.owner,
        this.manufacturer,
        this.model,
        this.displacement,
        this.imageUrl,
        this.createdAt,
        this.updatedAt,
        this.manufacturingYear,
        this.timeElapsed,
        this.myGarageId,
    });

    String vehicleCreatedAt;
    String id;
    Owner owner;
    String manufacturer;
    String model;
    double displacement;
    String imageUrl;
    DateTime createdAt;
    DateTime updatedAt;
    int manufacturingYear;
    String timeElapsed;
    String myGarageId;

    factory MyGarage.fromJson(Map<String, dynamic> json) => MyGarage(
        vehicleCreatedAt: json["vehicleCreatedAt"] == null ? null : json["vehicleCreatedAt"],
        id: json["_id"] == null ? null : json["_id"],
        owner: json["owner"] == null ? null : Owner.fromJson(json["owner"]),
        manufacturer: json["manufacturer"] == null ? null : json["manufacturer"],
        model: json["model"] == null ? null : json["model"],
        displacement: json["displacement"] == null ? null : json["displacement"].toDouble(),
        imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        manufacturingYear: json["manufacturingYear"] == null ? null : json["manufacturingYear"],
        timeElapsed: json["time-elapsed"] == null ? null : json["time-elapsed"],
        myGarageId: json["id"] == null ? null : json["id"],
    );

    Map<String, dynamic> toJson() => {
        "vehicleCreatedAt": vehicleCreatedAt == null ? null : vehicleCreatedAt,
        "_id": id == null ? null : id,
        "owner": owner == null ? null : owner.toJson(),
        "manufacturer": manufacturer == null ? null : manufacturer,
        "model": model == null ? null : model,
        "displacement": displacement == null ? null : displacement,
        "imageUrl": imageUrl == null ? null : imageUrl,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
        "manufacturingYear": manufacturingYear == null ? null : manufacturingYear,
        "time-elapsed": timeElapsed == null ? null : timeElapsed,
        "id": myGarageId == null ? null : myGarageId,
    };
}

class Owner {
    Owner({
        this.id,
        this.name,
    });

    String id;
    String name;

    factory Owner.fromJson(Map<String, dynamic> json) => Owner(
        id: json["_id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
    };
}

