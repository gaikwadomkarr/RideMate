import 'package:bikingapp/Helpers/AppConstants.dart';
import 'package:bikingapp/Helpers/LayoutHelpers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class CarouselSliderBuilder extends StatefulWidget {
  final List<String> postImages;
  final int index;

  CarouselSliderBuilder(this.postImages, this.index);

  @override
  _CarouselSliderBuilderState createState() => _CarouselSliderBuilderState();
}

class _CarouselSliderBuilderState extends State<CarouselSliderBuilder> {
  int current = 0;
  SharedPreferences prefs;
  int seconds = 0;
  int totalDuration = 0;
  double minScale = 1;
  List<dynamic> _videocontroller = new List<dynamic>();
  PageController _controller =
      new PageController(keepPage: true, initialPage: 0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // for (int i = 0; i < widget.postImages.length; i++) {
    //   print('inside interate');

    _videocontroller = [];
    for (int i = 0; i < widget.postImages.length; i++) {
      if (widget.postImages[i].contains('mp4')) {
        _videocontroller.add(FlickManager(
            autoPlay: false,
            autoInitialize: true,
            videoPlayerController:
                VideoPlayerController.network(widget.postImages[i])));
      } else {
        _videocontroller.add(widget.postImages[i]);
      }
    }

    // for (int i = 0; i < _videocontroller.length; i++) {
    //   if (widget.postImages[i].contains('mp4')) {
    //     print('inside found mp4');
    //     print(_videocontroller[i].toString());
    //     _videocontroller[i].
    //       ..initialize().then((value) async {
    //         setState(() {});
    //         _videocontroller[i].addListener(() {
    //           setState(() {
    //             seconds = _videocontroller[i].value.position.inSeconds;
    //             totalDuration = _videocontroller[i].value.duration.inSeconds;
    //           });
    //         });
    //         _videocontroller[i].setLooping(true);
    //         _videocontroller[i].pause();
    //       });
    //   }
    // }

    // _videocontroller = VideoPlayerController.network(widget.postImages[0])
    //   ..initialize().then((value) async {
    //     _videocontroller.setLooping(true);
    //     _videocontroller.addListener(() {
    //       setState(() {
    //         seconds = _videocontroller.value.position.inSeconds;
    //       });
    //     });
    //     // _videocontroller.seekTo(Duration(seconds: 12));
    //     // _videocontroller.play();
    //     setState(() {
    //       totalDuration = _videocontroller.value.duration.inSeconds;
    //     });
    //   });
    // }
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
    for (int i = 0; i < _videocontroller.length; i++) {
      // _videocontroller[i].removeListener(() {});
      if (widget.postImages[i].contains("mp4")) {
        _videocontroller[i].dispose();
      }
    }
  }

  void refreshUI() {}

  @override
  Widget build(BuildContext context) {
    return widget.postImages.length > 1
        ? Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              CarouselSlider(
                  options: CarouselOptions(
                      // pageViewKey: PageStorageKey('post${widget.index}'),
                      carouselController: _controller,
                      viewportFraction: 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                          current = index;
                          // if (_videocontroller[index] ==
                          //     VideoPlayerController) {
                          //   _videocontroller[index].pause();
                          // }
                        });
                        print(current);
                      },
                      disableCenter: false,
                      enableInfiniteScroll: false,
                      enlargeCenterPage: true,
                      aspectRatio: 1 / 1),
                  items: List.generate(widget.postImages.length, (index) {
                    if (widget.postImages[index].contains('jpg') ||
                        widget.postImages[index].contains("png")) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black,
                        child: Image.network(
                          widget.postImages[index],
                          fit: BoxFit.contain,
                        ),
                      );
                    } else {
                      // return _videocontroller[index]
                      //     ? AspectRatio(
                      //         aspectRatio:1/1,
                      //         child: Stack(
                      //           children: [
                      //             VideoPlayer(_videocontroller[index]),
                      // PlayPauseOverlay(
                      //     controller: _videocontroller[index]),
                      // Container(
                      //   margin: EdgeInsets.only(bottom: 3, left: 2),
                      //   child: Align(
                      //     alignment: Alignment.bottomLeft,
                      //     child: seconds.toString().length == 1
                      //         ? Text(
                      //             '00 : 0' + seconds.toString(),
                      //             style: regularTxtStyle.copyWith(
                      //                 color: Colors.white,
                      //                 fontSize: 11),
                      //           )
                      //         : Text(
                      //             '00 : ' + seconds.toString(),
                      //             style: regularTxtStyle.copyWith(
                      //                 color: Colors.white,
                      //                 fontSize: 11),
                      //           ),
                      //   ),
                      // ),
                      // Align(
                      //   alignment: Alignment.bottomCenter,
                      //   child: VideoProgressIndicator(
                      //     _videocontroller[index],
                      //     allowScrubbing: true,
                      //   ),
                      // ),
                      //       ],
                      //     ))
                      // : Container(
                      //     height: 50,
                      //   );
                      return FlickVideoPlayer(
                        flickManager: _videocontroller[index],
                        // flickVideoWithControls: FlickPortraitControls(),
                      );
                    }
                  })
                  // return Container(
                  //   child: Image.network(
                  //     e,
                  //     fit: BoxFit.contain,
                  //   ),
                  // );

                  ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.postImages.length,
                            (index) {
                              return Container(
                                key: PageStorageKey("postdot$index"),
                                width: current == index ? 10.0 : 7.0,
                                height: current == index ? 10.0 : 7.0,
                                margin: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: current == index
                                        ? color4
                                        : color4.withOpacity(0.5)),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : (widget.postImages[0].contains('jpg') ||
                widget.postImages[0].contains("png"))
            ? InteractiveViewer(
                minScale: 1.0,
                // maxScale: minScale,
                // onInteractionStart: (value) {
                //   setState(() {
                //     minScale = value;
                //   });
                // },
                panEnabled: true,
                onInteractionUpdate: (value) {
                  setState(() {
                    minScale = value.scale;
                  });
                },
                onInteractionEnd: (value) {
                  setState(() {
                    print('this is value $value');
                    minScale = 1;
                  });
                },
                child: Image.network(
                  widget.postImages[0],
                  fit: BoxFit.contain,
                ),
              )
            // : _videocontroller[0].value.initialized
            //     ? AspectRatio(
            //         aspectRatio: _videocontroller[0].value.aspectRatio,
            //         child: Stack(
            //           children: [
            //             VideoPlayer(_videocontroller[0]),
            //             PlayPauseOverlay(controller: _videocontroller[0]),
            //             Container(
            //               margin: EdgeInsets.only(bottom: 3, left: 2),
            //               child: Align(
            //                 alignment: Alignment.bottomLeft,
            //                 child: seconds.toString().length == 1
            //                     ? Text(
            //                         '00 : 0' + seconds.toString(),
            //                         style: regularTxtStyle.copyWith(
            //                             color: Colors.white, fontSize: 11),
            //                       )
            //                     : Text(
            //                         '00 : ' + seconds.toString(),
            //                         style: regularTxtStyle.copyWith(
            //                             color: Colors.white, fontSize: 11),
            //                       ),
            //               ),
            //             ),
            //             Align(
            //               alignment: Alignment.bottomCenter,
            //               child: VideoProgressIndicator(
            //                 _videocontroller[0],
            //                 allowScrubbing: true,
            //               ),
            //             ),
            //           ],
            //         ))
            //     : Container(
            //         height: 50,
            //       );
            : FlickVideoPlayer(
                flickManager: _videocontroller[0],
              );
  }
}

class PlayPauseOverlay extends StatelessWidget {
  const PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          switchInCurve: Curves.bounceIn,
          switchOutCurve: Curves.bounceOut,
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
