import 'dart:convert';
import 'dart:io';
import 'package:bikingapp/Helpers/AppConstants.dart';
import 'package:bikingapp/Helpers/ShowNotificationHelper.dart';
import 'package:bikingapp/HomeScreen.dart';
import 'package:bikingapp/Models/SessionData.dart';
import 'package:bikingapp/Models/ViewProfile.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:http/http.dart' as http;

class AddUpdateBike extends StatefulWidget {
  final ViewProfile viewProfile;
  final int index;
  final bool isNewBike;
  AddUpdateBike(
      {@required this.viewProfile, @required this.index, this.isNewBike});
  @override
  _AddUpdateBikeState createState() => _AddUpdateBikeState();
}

class _AddUpdateBikeState extends State<AddUpdateBike> {
  TextEditingController manufacturerTxtController = new TextEditingController();
  TextEditingController modelTxtController = new TextEditingController();
  TextEditingController manufacturinyearTxtController =
      new TextEditingController();
  TextEditingController displacementTxtController = new TextEditingController();
  TextEditingController prosconsTxtController = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  double handlingRating = 0.0;
  double comfortRating = 0.0;
  double brakingRating = 0.0;
  double stabilityRating = 0.0;

  var image1;
  File imagepath;
  File croppedFile1;
  String fileName;

  bool _isDialogShowing = false;

  void initState() {
    print('calling initState');
    super.initState();
    imageCache.clear();
    if (!widget.isNewBike) {
      manufacturerTxtController.text =
          widget.viewProfile.myGarage[widget.index].manufacturer;
      modelTxtController.text = widget.viewProfile.myGarage[widget.index].model;
      manufacturinyearTxtController.text = widget
          .viewProfile.myGarage[widget.index].manufacturingYear
          .toString();
      displacementTxtController.text =
          widget.viewProfile.myGarage[widget.index].displacement.toString();
    }
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
        await _cropImage();
      }
    } else {
      image1 = await imagePicker.getImage(source: ImageSource.gallery);
      setState(() {
        imagepath = File(image1.path);
        fileName = imagepath.path.split('/').last;
      });
      await _cropImage();
    }
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imagepath.path,
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
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Select Image Area',
        ));
    if (croppedFile != null) {
      setState(() {});
      croppedFile1 = croppedFile;
      print(croppedFile1.path);
    }
  }

  DecorationImage getImageFromDecorationBox() {
    if (widget.isNewBike) {
      if (croppedFile1 != null) {
        return DecorationImage(
            fit: BoxFit.cover, image: FileImage(File(croppedFile1.path)));
      } else {
        return DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/placeholder2.png'));
      }
    } else {
      if (widget.viewProfile.myGarage[widget.index].imageUrl != null &&
          croppedFile1 == null) {
        return DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(
                widget.viewProfile.myGarage[widget.index].imageUrl));
      } else if (croppedFile1 != null) {
        return DecorationImage(
            fit: BoxFit.cover, image: FileImage(File(croppedFile1.path)));
      } else {
        return DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/placeholder2.png'));
      }
    }
  }

  void addUpdateapi() async {
    Dio dio = new Dio();
    dio.options.headers['Authorization'] = 'Bearer ' + SessionData().token;
    dio.options.headers['Content-Type'] = 'apllication/json';
    dio.options.responseType = ResponseType.json;

    String url;
    var my = int.parse(manufacturinyearTxtController.text.toString());
    var d = double.parse(displacementTxtController.text.toString());
    if (widget.isNewBike) {
      url = commonapi + '/garage/addNewVehicle';
    } else {
      url = commonapi +
          '/garage/update/' +
          widget.viewProfile.myGarage[widget.index].id;
    }
    showLoaderDialog(context, "Adding your Bike");
    setState(() {
      _isDialogShowing = true;
    });
    print('this is url $url');

    FormData formData = FormData.fromMap({
      'manufacturer': manufacturerTxtController.text,
      'model': modelTxtController.text,
      'manufacturingYear': int.parse(manufacturinyearTxtController.text),
      'displacement': double.parse(displacementTxtController.text)
    });

    if (croppedFile1 != null) {
      if (widget.isNewBike) {
        print('uploading new image');
        formData.files.add(MapEntry('addVehicleImage',
            MultipartFile.fromFileSync(croppedFile1.path, filename: fileName)));
      } else {
        print('updating image');
        formData.files.add(MapEntry('updateVehicleImage',
            MultipartFile.fromFileSync(croppedFile1.path, filename: fileName)));
      }
    }

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
            MaterialPageRoute(builder: (context) => HomeScreen(index: 4)));
      }
    } on DioError catch (e) {
      if (_isDialogShowing) {
        Navigator.pop(context);
        setState(() {
          _isDialogShowing = false;
        });
      }
      print('failed');
    }
  }

  void deleteBikeApi() async {
    Dio dio = new Dio();
    dio.options.headers['Authorization'] = 'Bearer ' + SessionData().token;
    dio.options.responseType = ResponseType.json;
    showLoaderDialog(context, 'Deleting...');
    setState(() {
      _isDialogShowing = true;
    });

    try {
      final request = await dio.delete(commonapi +
          '/garage/delete/' +
          widget.viewProfile.myGarage[widget.index].id);
      print(request.statusCode);
      if (request.statusCode == 200 || request.statusCode == 201) {
        if (_isDialogShowing) {
          Navigator.pop(context);
          setState(() {
            _isDialogShowing = false;
          });
        }
      }
      showInSnackBar(
          context,
          'You removed ' +
              widget.viewProfile.myGarage[widget.index].manufacturer +
              ' ' +
              widget.viewProfile.myGarage[widget.index].model +
              ' from your garage',
          _scaffoldKey);
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomeScreen(index: 4)));
      });
    } on DioError catch (e) {
      print(e.response.statusCode);
      print(e.response.statusMessage);
      if (_isDialogShowing) {
        Navigator.pop(context);
        setState(() {
          _isDialogShowing = false;
        });
      }
      showInSnackBar(
          context,
          'Failed to remove ' +
              widget.viewProfile.myGarage[widget.index].manufacturer +
              ' ' +
              widget.viewProfile.myGarage[widget.index].model +
              ' from your garage. Please try again. !',
          _scaffoldKey);
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
              child: Text(
                widget.isNewBike ? 'Add Bike' : 'Update Bike',
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
                    Hero(
                      tag: "bikeImage${widget.index}",
                      child: Container(
                        width: 150,
                        margin: EdgeInsets.only(top: 15),
                        child: GestureDetector(
                          onTap: () {
                            // getImageFromCamera(context, false);
                          },
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              Container(
                                  height: 150,
                                  width: 150,
                                  padding: EdgeInsets.all(10),
                                  decoration: new BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(0.0, 1.0),
                                        blurRadius: 10,
                                      ),
                                    ],
                                    image: getImageFromDecorationBox(),
                                  )),
                              Align(
                                // alignment: Alignment.bottomRight,
                                child: GestureDetector(
                                  onTap: () {
                                    showProfileOptions();
                                  },
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25.0)),
                                    child: Container(
                                      color: color2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildTextFormFields(
                        context,
                        "Manufacturer",
                        manufacturerTxtController,
                        TextInputType.text,
                        TextInputAction.next,
                        true,
                        1),
                    _buildTextFormFields(context, "Model", modelTxtController,
                        TextInputType.text, TextInputAction.next, true, 1),
                    _buildTextFormFields(
                        context,
                        "Manufacturing Year",
                        manufacturinyearTxtController,
                        TextInputType.number,
                        TextInputAction.next,
                        true,
                        1),
                    _buildTextFormFields(
                        context,
                        "Displacement",
                        displacementTxtController,
                        TextInputType.number,
                        TextInputAction.send,
                        true,
                        1),
                    Container(
                      margin: EdgeInsets.fromLTRB(20, 30, 20, 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                margin: EdgeInsets.all(10),
                                child: Text(
                                  'Ownership Review',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: color1),
                                )),
                            smoothStarRating('Handling', handlingRating),
                            smoothStarRating('Comfort', comfortRating),
                            smoothStarRating('Braking', brakingRating),
                            smoothStarRating('Stability', stabilityRating),
                            _buildTextFormFields(
                                context,
                                "Pros/Cons (optional)",
                                prosconsTxtController,
                                TextInputType.text,
                                TextInputAction.done,
                                true,
                                3),
                            SizedBox(height: 15)
                          ]),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    !widget.isNewBike
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
                                      deleteBikeApi();
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
                                addUpdateapi();
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
      int maxLines) {
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
      ),
    );
  }

  Widget smoothStarRating(String ratingText, double ratingcontroller) {
    return Container(
      margin: EdgeInsets.fromLTRB(30, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(ratingText, style: TextStyle(fontSize: 15, color: color1)),
          SmoothStarRating(
              allowHalfRating: true,
              onRated: (v) {
                ratingcontroller = v;
                setState(() {});
                // print('this is rating => $rating');
              },
              starCount: 5,
              rating: ratingcontroller,
              size: 25.0,
              filledIconData: Icons.star,
              halfFilledIconData: Icons.star_half,
              color: Colors.yellow[800],
              borderColor: Colors.yellow[800],
              spacing: 0.0),
        ],
      ),
    );
  }

  void showProfileOptions() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (BuildContext context) {
          return Container(
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Container(
                      // margin: EdgeInsets.only(left: 10),
                      child: IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 25,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context)),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Text('Select one to Update your Profile',
                        style: TextStyle(color: Colors.grey[600])),
                    const Spacer(flex: 3)
                  ],
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  child: Container(
                    height: 35,
                    width: 200,
                    color: color2,
                    child: MaterialButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.white24,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Text(
                            "Pick from Gallery",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          getImageFromCamera(context, true);
                        }),
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  child: Container(
                    height: 35,
                    width: 200,
                    color: color2,
                    child: MaterialButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.white24,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Text(
                            "Take a Photo",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          getImageFromCamera(context, false);
                        }),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
