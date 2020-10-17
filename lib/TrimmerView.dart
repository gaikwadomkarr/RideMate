import 'dart:io';

import 'package:bikingapp/NewPost.dart';
import 'package:flutter/material.dart';
import 'package:video_trimmer/storage_dir.dart';
import 'package:video_trimmer/trim_editor.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_trimmer/video_viewer.dart';

class TrimmerView extends StatefulWidget {
  final Trimmer _trimmer;
  TrimmerView(this._trimmer);
  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String _value;

    await widget._trimmer
        .saveTrimmedVideo(
            startValue: _startValue,
            endValue: _endValue,
            storageDir: StorageDir.externalStorageDirectory)
        .then((value) {
      setState(() {
        _progressVisibility = false;
        _value = value;
      });
    });

    return _value;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewPost(
                    isNewPost: true,
                    viewProfile: null,
                    index: null,
                    allPostsModel: null)));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Video Trimmer"),
        ),
        body: Builder(
          builder: (context) => Center(
            child: Container(
              padding: EdgeInsets.only(bottom: 30.0),
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Visibility(
                    visible: _progressVisibility,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.red,
                    ),
                  ),
                  RaisedButton(
                    onPressed: _progressVisibility
                        ? null
                        : () async {
                            _saveVideo().then((outputPath) {
                              File file = File(outputPath);
                              var newPath = file.renameSync(file.path
                                  .replaceAll(":", "_")
                                  .replaceAll(",", "_")
                                  .replaceAll('-', '_'));
                              print('OUTPUT PATH: ${newPath.path}');
                              final snackBar = SnackBar(
                                content: Text('Video Saved successfully'),
                              );
                              Scaffold.of(context).showSnackBar(snackBar);
                              Navigator.pop(context, newPath.path);
                            });
                          },
                    child: Text("SAVE"),
                  ),
                  Expanded(
                    child: VideoViewer(),
                  ),
                  Center(
                    child: TrimEditor(
                      viewerHeight: 50.0,
                      viewerWidth: MediaQuery.of(context).size.width,
                      maxVideoLength: Duration(seconds: 30),
                      onChangeStart: (value) {
                        _startValue = value;
                      },
                      onChangeEnd: (value) {
                        _endValue = value;
                      },
                      onChangePlaybackState: (value) {
                        setState(() {
                          _isPlaying = value;
                        });
                      },
                    ),
                  ),
                  FlatButton(
                    child: _isPlaying
                        ? Icon(
                            Icons.pause,
                            size: 80.0,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.play_arrow,
                            size: 80.0,
                            color: Colors.white,
                          ),
                    onPressed: () async {
                      bool playbackState =
                          await widget._trimmer.videPlaybackControl(
                        startValue: _startValue,
                        endValue: _endValue,
                      );
                      setState(() {
                        _isPlaying = playbackState;
                      });
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
