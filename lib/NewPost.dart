import 'dart:io';
import 'package:bikingapp/AddressSearch.dart';
import 'package:bikingapp/Helpers/AppConstants.dart';
import 'package:bikingapp/Helpers/ShowNotificationHelper.dart';
import 'package:bikingapp/HomeScreen.dart';
import 'package:bikingapp/Models/AllPostsModel.dart';
import 'package:bikingapp/Models/SessionData.dart';
import 'package:bikingapp/Models/ViewProfile.dart';
import 'package:bikingapp/place_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class NewPost extends StatefulWidget {
  final bool isNewPost;
  final ViewProfile viewProfile;
  final int index;
  final AllPostsModel allPostsModel;
  NewPost(
      {@required this.isNewPost,
      @required this.viewProfile,
      @required this.index,
      @required this.allPostsModel});
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  TextEditingController titleTxtController = new TextEditingController();
  TextEditingController captionTxtController = new TextEditingController();
  TextEditingController locationTxtController = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var image1;
  File imagepath;
  File croppedFile1;
  String fileName;
  bool _isDialogShowing = false;
  int current = 0;

  List<Asset> images = new List<Asset>();
  List<String> images1 = new List<String>();
  List<int> imageheights = new List<int>();
  List<MultipartFile> imagesmultipart = new List<MultipartFile>();
  List<dynamic> _videocontrollers = new List<dynamic>();

  String _error = 'No Error Dectected';

  @override
  void initState() {
    super.initState();
    images.clear();
    if (widget.allPostsModel != null) {
      titleTxtController.text = widget.allPostsModel.data[widget.index].title;
      captionTxtController.text = widget.allPostsModel.data[widget.index].body;
      images1.addAll(widget.allPostsModel.data[widget.index].postImages);
    }

    // titleTxtController.text = widget.allPostsModel.data[widget.index].title;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getImageFromCamera(
      BuildContext changeImgContext, bool pickFromGallery) async {
    ImagePicker imagePicker = new ImagePicker();
    if (!pickFromGallery) {
      image1 = await imagePicker.getImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front);
      print(image1.path);
      setState(() {
        imagepath = File(image1.path);
        fileName = imagepath.path.split('/').last;
      });
      if (imagepath != null) {
        await _cropImage(imagepath.path);
      }
    } else {
      image1 = await imagePicker.getImage(source: ImageSource.gallery);
      setState(() {
        imagepath = File(image1.path);
        fileName = imagepath.path.split('/').last;
      });
      await _cropImage(imagepath.path);
    }
  }

  Future getVideo(BuildContext changeImgContext) async {
    FilePickerResult image1 = await FilePicker.platform.pickFiles();
    images1.add(image1.files.single.path);
    print('this is video path => ' + image1.files.single.path);

    _videocontrollers = [];
    for (int i = 0; i < images1.length; i++) {
      if (images1[i].contains('mp4')) {
        _videocontrollers.add(VideoPlayerController.network(images1[i]));
      } else {
        _videocontrollers.add(images1[i]);
      }
    }

    for (int i = 0; i < _videocontrollers.length; i++) {
      if (images1[i].contains('mp4')) {
        print('inside found mp4');
        print(_videocontrollers[i].toString());
        _videocontrollers[i]
          ..initialize().then((value) async {
            setState(() {});
            _videocontrollers[i].addListener(() {});
            _videocontrollers[i].setLooping(true);
            _videocontrollers[i].pause();
          });
      }
    }
    print('images1 list => ' + images1.toString());
  }

  Future<void> loadAssets() async {
    // images.clear();
    images1.clear();
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 3,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });

//----Take asset and convert it to File to use and show in Carousel

    for (int i = 0; i < images.length; i++) {
      print(images[i]);
      final byteData = await images[i].getByteData(quality: 95);

      final path = (await getTemporaryDirectory()).path;
      final tempFile = File("$path/${images[i].name}");
      final file = await tempFile.writeAsBytes(
        byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
      images1.add(file.path);
      imageheights.add(resultList[i].originalHeight);
    }
    setState(() {});

    print('images1 list => ' + images1.toString());
  }

  Future<Null> _cropImage(String path) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        compressQuality: 70,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: color1,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          title: 'Select Image Area',
        ));
    if (croppedFile != null) {
      setState(() {});
      croppedFile1 = croppedFile;
      print(croppedFile1.path);

      images1[current] = croppedFile1.path;
      print('this is path after crop =>  ' + croppedFile.path);
    }
  }

  void _clearCachedFiles() {
    FilePicker.platform.clearTemporaryFiles().then((result) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: result ? Colors.green : Colors.red,
          content: Text((result
              ? 'Temporary files removed with success.'
              : 'Failed to clean temporary files')),
        ),
      );
    });
  }

  void addUpdatePost() async {
    Dio dio = new Dio();
    dio.options.headers['Authorization'] = 'Bearer ' + SessionData().token;
    dio.options.headers['Content-Type'] = 'apllication/json';
    dio.options.responseType = ResponseType.json;

    String url;
    if (widget.isNewPost) {
      url = commonapi + '/api/v1/post/createPost';
    } else {
      url = commonapi +
          '/bikesGallery/editPost/' +
          widget.allPostsModel.data[widget.index].id;
    }
    showLoaderDialog(
        context, widget.isNewPost ? "Adding your post" : "Updating your post");
    setState(() {
      _isDialogShowing = true;
    });
    print('this is url $url');

    FormData formData = FormData.fromMap({
      'title': titleTxtController.text,
      'body': captionTxtController.text,
      'multiple_image': imagesmultipart
    });

    // if (croppedFile1 != null) {
    //   if (widget.isNewPost) {
    //     print('uploading new image');
    //     formData.files.add(MapEntry('multiple_image',
    //         MultipartFile.fromFileSync(croppedFile1.path, filename: fileName)));
    //   } else {
    //     print('updating image');
    //     formData.files.add(MapEntry('multiple_image',
    //         MultipartFile.fromFileSync(croppedFile1.path, filename: fileName)));
    //   }
    // }

    print('this is json data => ' + formData.fields.toString());
    try {
      var request = await dio.post(url, data: formData);

      if (request.statusCode == 200 || request.statusCode == 201) {
        if (_isDialogShowing) {
          Navigator.pop(context);
          setState(() {
            _isDialogShowing = false;
          });
        }
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomeScreen(index: 0)));
      }
    } on DioError catch (e) {
      if (_isDialogShowing) {
        Navigator.pop(context);
        setState(() {
          _isDialogShowing = false;
        });
      }
      print('failed');
      print(e.response.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomeScreen(index: 4)));
      },
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 2,
            backgroundColor: Colors.white,
            title: Container(
              margin: EdgeInsets.only(left: 10),
              child: Text(
                widget.isNewPost ? 'New Post' : "Update Post",
                style: TextStyle(
                    color: color1, fontSize: 20, fontStyle: FontStyle.normal),
              ),
            ),
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreen(index: 4)));
              },
              child: Icon(
                Icons.arrow_back,
                color: color1,
              ),
            ),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      // height: MediaQuery.of(context).size.height / 1.5,
                      // width: MediaQuery.of(context).size.width / 1.5,

                      child: images1.length == 0
                          ? GestureDetector(
                              onTap: () {
                                showProfileOptions(context, "Pick from Gallery",
                                    "Pick Video", "Take a Picture", () {
                                  Navigator.pop(context);
                                  loadAssets();
                                }, () {
                                  Navigator.pop(context);
                                  getVideo(context);
                                }, () {
                                  Navigator.pop(context);
                                  getImageFromCamera(context, false);
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Text('Tap to add photo',
                                    style: regularTxtStyle.copyWith(
                                        color: Colors.black)),
                              ))
                          : Column(
                              children: [
                                Container(
                                  height: 300,
                                  width: 300,
                                  child: CarouselSlider(
                                      options: CarouselOptions(
                                          viewportFraction: 0.8,
                                          onPageChanged: (index, reason) {
                                            setState(() {
                                              current = index;
                                            });
                                          },
                                          disableCenter: false,
                                          enableInfiniteScroll: false,
                                          enlargeCenterPage: true,
                                          autoPlay: false,
                                          initialPage: 0,
                                          height: 300),
                                      items: List.generate(images1.length,
                                          (index) {
                                        if (images1[index].contains('jpg') ||
                                            images1[index].contains('png')) {
                                          print('image is here');
                                          return Image.file(
                                              File(images1[index]));
                                        } else {
                                          print('video is here');
                                          return _videocontrollers[index]
                                                  .value
                                                  .initialized
                                              ? AspectRatio(
                                                  aspectRatio:
                                                      _videocontrollers[index]
                                                          .value
                                                          .aspectRatio,
                                                  child: Stack(
                                                    children: [
                                                      VideoPlayer(
                                                          _videocontrollers[
                                                              index]),
                                                      PlayPauseOverlay(
                                                        controller:
                                                            _videocontrollers[
                                                                index],
                                                      )
                                                    ],
                                                  ),
                                                )
                                              : Container(
                                                  color: Colors.blue,
                                                );
                                        }
                                      })),
                                ),
                                Container(
                                  margin: EdgeInsets.all(5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            images1.length,
                                            (index) {
                                              return Container(
                                                width: current == index
                                                    ? 8.0
                                                    : 6.0,
                                                height: current == index
                                                    ? 8.0
                                                    : 6.0,
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 2.0),
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: current == index
                                                        ? Color.fromRGBO(
                                                            0, 0, 0, 0.9)
                                                        : Color.fromRGBO(
                                                            0, 0, 0, 0.4)),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                          onTap: () async {
                                            images1.removeAt(current);
                                            // _clearCachedFiles();
                                            _videocontrollers[current]
                                                .removeListener(() {});
                                            _videocontrollers.removeAt(current);
                                            // images.removeAt(current);
                                            setState(() {});
                                          },
                                          child: Icon(
                                              Icons.delete_outline_rounded)),
                                      GestureDetector(
                                        onTap: () {
                                          images1.length != 3
                                              ? showProfileOptions(
                                                  context,
                                                  "Pick from Gallery",
                                                  "Pick Video",
                                                  "Take a Picture", () {
                                                  Navigator.pop(context);
                                                  loadAssets();
                                                }, () {
                                                  Navigator.pop(context);
                                                  getVideo(context);
                                                }, () {
                                                  Navigator.pop(context);
                                                  getImageFromCamera(
                                                      context, false);
                                                })
                                              : null;
                                        },
                                        child: CircleAvatar(
                                            backgroundColor: images1.length == 3
                                                ? Colors.blueGrey
                                                : Colors.blue,
                                            radius: 15,
                                            child: Icon(Icons.add)),
                                      ),
                                      GestureDetector(
                                          onTap: () async {
                                            await _cropImage(
                                                await FlutterAbsolutePath
                                                    .getAbsolutePath(
                                                        images1[current]));
                                          },
                                          child: Icon(Icons.crop_outlined)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                    _buildTextFormFields(
                        context,
                        "Title",
                        titleTxtController,
                        TextInputType.text,
                        TextInputAction.next,
                        true,
                        1,
                        () {}),
                    _buildTextFormFields(
                        context,
                        "Caption",
                        captionTxtController,
                        TextInputType.text,
                        TextInputAction.next,
                        true,
                        1,
                        () {}),
                    _buildTextFormFields(
                        context,
                        "Location",
                        locationTxtController,
                        TextInputType.number,
                        TextInputAction.send,
                        true,
                        1, () async {
                      final sessionToken = Uuid().v4();
                      print("this is session token =>" + sessionToken);
                      final Suggestion result = await showSearch(
                        context: context,
                        delegate: AddressSearch(sessionToken),
                      );
                      // This will change the text displayed in the TextField
                      if (result != null) {
                        final placeDetails =
                            await PlaceApiProvider(sessionToken)
                                .getPlaceDetailFromId(result.placeId);
                        setState(() {
                          locationTxtController.text = result.description;
                        });
                      }
                    }),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    !widget.isNewPost
                        ? Container(
                            margin: EdgeInsets.only(right: 20),
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50.0)),
                              child: Container(
                                height: 40,
                                color: color2,
                                child: MaterialButton(
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.white24,
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10),
                                        // child: Text(
                                        //   widget.isNewBike ? 'Add Bike' : 'Update Bike',
                                        //   style: TextStyle(color: Colors.white),
                                        // ),
                                        child: Icon(
                                          FlutterIcons.delete_mco,
                                          color: Colors.white,
                                        )),
                                    onPressed: () async {
                                      //   deleteBikeApi();
                                    }),
                              ),
                            ),
                          )
                        : Container(),
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(100.0)),
                        child: Container(
                          height: 40,
                          color: color2,
                          child: MaterialButton(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.white24,
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10),
                                  // child: Text(
                                  //   widget.isNewBike ? 'Add Bike' : 'Update Bike',
                                  //   style: TextStyle(color: Colors.white),
                                  // ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  )),
                              onPressed: () async {
                                for (int i = 0; i < images1.length; i++) {
                                  imagesmultipart.add(
                                      MultipartFile.fromFileSync(images1[i],
                                          filename:
                                              images1[i].split('/').last));
                                }
                                addUpdatePost();
                              }),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormFields(
      BuildContext context,
      String hintText,
      TextEditingController _controller,
      TextInputType keyboardType,
      TextInputAction textInputAction,
      bool enabled,
      int maxLines,
      Function func) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: TextFormField(
        enabled: enabled,
        maxLines: maxLines,
        controller: _controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        decoration: new InputDecoration(
          labelText: hintText, // add hinttext in case Design
          counterText: "",
          // hintStyle: regularTxtStyle.copyWith(color: Colors.black45),
        ),
        onTap: func,
      ),
    );
  }

  // @override
  // // TODO: implement wantKeepAlive
  // bool get wantKeepAlive => true;
}

class PlayPauseOverlay extends StatelessWidget {
  const PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
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
