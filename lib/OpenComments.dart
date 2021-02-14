// import 'package:bikingapp/Models/AllComments.dart';
// import 'package:flutter/material.dart';

// class OpenComments extends StatefulWidget {
//   final String postIndex;

//   const OpenComments({Key key, this.postIndex}) : super(key: key);
//   @override
//   _OpenCommentsState createState() => _OpenCommentsState();
// }

// class _OpenCommentsState extends State<OpenComments> {
//   AllComments _allComments;
//   @override
//   Widget build(BuildContext context) {
//     return null();
//   }

//   void showComments() {
//     showModalBottomSheet(
//         isScrollControlled: true,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(25), topRight: Radius.circular(25))),
//         context: context,
//         isDismissible: true,
//         elevation: 1,
//         enableDrag: true,
//         builder: (BuildContext context) {
//           return StatefulBuilder(
//             builder: (context, state) {
//               return Container(
//                 height: MediaQuery.of(context).size.height / 1.7,
//                 padding: EdgeInsets.only(
//                     bottom: MediaQuery.of(context).viewInsets.bottom),
//                 margin: EdgeInsets.all(10),
//                 color: Colors.transparent,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.max,
//                   children: <Widget>[
//                     GestureDetector(
//                       onTap: () {
//                         // scrollTimer.cancel();
//                         Navigator.pop(context);
//                       },
//                       child: Container(
//                         margin: EdgeInsets.all(10),
//                         alignment: Alignment.center,
//                         child: Icon(Icons.close),
//                       ),
//                     ),
//                     Expanded(
//                       child: ListView(
//                           // reverse: true,
//                           // controller: _scrollController,
//                           shrinkWrap: true,
//                           children: _allComments.data.length > 0
//                               ? List.generate(
//                                   allPostsModel.data[widget.postIndex].comments
//                                       .length, (index) {
//                                   return ListTile(
//                                     leading: ClipOval(
//                                       child: Image(
//                                         height: 45,
//                                         fit: BoxFit.cover,
//                                         image: AssetImage(
//                                             'assets/images/biker.png'),
//                                       ),
//                                     ),
//                                     title: Text(
//                                         allPostsModel
//                                             .data[widget.postIndex]
//                                             .comments[index]
//                                             .commentedByUserName,
//                                         style: TextStyle(
//                                             color: color1,
//                                             fontWeight: FontWeight.w700)),
//                                     subtitle: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: <Widget>[
//                                         Text(
//                                             allPostsModel.data[widget.postIndex]
//                                                 .comments[index].commentText,
//                                             style:
//                                                 TextStyle(color: Colors.black)),
//                                         Container(
//                                           margin: EdgeInsets.only(top: 5),
//                                           child: Text(
//                                               timeago
//                                                   .format(
//                                                       DateTime.parse(
//                                                           allPostsModel
//                                                               .data[widget
//                                                                   .postIndex]
//                                                               .comments[index]
//                                                               .createdAt
//                                                               .toString()),
//                                                       locale: 'en_short')
//                                                   .replaceAll('~', ''),
//                                               style: TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 8)),
//                                         ),
//                                       ],
//                                     ),
//                                     trailing: allPostsModel
//                                                 .data[widget.postIndex]
//                                                 .comments[index]
//                                                 .commentedByUserId ==
//                                             SessionData().data[0].id
//                                         ? GestureDetector(
//                                             onTap: () {
//                                               hitdeleteComment(index,
//                                                   widget.postIndex, state);
//                                             },
//                                             child:
//                                                 Icon(FontAwesomeIcons.trashAlt))
//                                         : null,
//                                   );
//                                 })
//                               : List.generate(1, (index) {
//                                   return Align(
//                                     alignment: Alignment.center,
//                                     child: Center(
//                                       child: Text(
//                                           'No Comments yet ! Be the first to comment.'),
//                                     ),
//                                   );
//                                 })),
//                     ),
//                     SingleChildScrollView(
//                       child: Row(
//                         children: <Widget>[
//                           Expanded(
//                             child: Container(
//                               // margin: EdgeInsets.only(left: 5, right: 5),
//                               padding: EdgeInsets.only(left: 10),
//                               // width: 230,
//                               height: 45,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.rectangle,
//                                 borderRadius: new BorderRadius.only(
//                                     bottomLeft: Radius.circular(10)),
//                                 // color: _color,
//                               ),
//                               child: TextField(
//                                 enabled: true,
//                                 controller: commentText,
//                                 // cursorColor: FlavorConfig.instance.textColor,
//                                 style: TextStyle(
//                                   color: color1,
//                                 ),
//                                 decoration: const InputDecoration(
//                                   hintText: 'Add Comment...',
//                                   hintStyle: TextStyle(
//                                     fontSize: 17,
//                                     color: Color(0xFF7E0D74),
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius: const BorderRadius.only(
//                                       topLeft: Radius.circular(10.0),
//                                       bottomLeft: Radius.circular(10.0),
//                                     ),
//                                   ),
//                                   contentPadding: const EdgeInsets.symmetric(
//                                       vertical: 5.0, horizontal: 10),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             height: 45,
//                             width: 60,
//                             child: FloatingActionButton.extended(
//                               elevation: 0,
//                               heroTag: 'Reply',
//                               onPressed: () {
//                                 if (commentText.text.isNotEmpty) {
//                                   hitPostComment(widget.postIndex, state);
//                                 }
//                               },
//                               // backgroundColor: FlavorConfig.instance.textColor,
//                               shape: RoundedRectangleBorder(
//                                 // side: BorderSide(color: Colors.grey[500]),
//                                 borderRadius: new BorderRadius.only(
//                                     bottomRight: Radius.circular(10),
//                                     topRight: Radius.circular(10)),
//                               ),
//                               label: Icon(
//                                 Icons.send,
//                                 size: 35,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         });
//   }
// }
