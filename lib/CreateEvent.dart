import 'dart:io';

import 'package:bikingapp/Helpers/AppConstants.dart';
import 'package:bikingapp/Helpers/ShowNotificationHelper.dart';
import 'package:bikingapp/HomeScreen.dart';
import 'package:bikingapp/Models/SessionData.dart';
import 'package:bikingapp/PostsScreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CreateEvent extends StatefulWidget {
  final bool isNew;
  CreateEvent({@required this.isNew});
  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  List<String> eventTypes = ['Invitation', 'Meetup', 'Unboxing', 'Ride'];
  String selectedtype;

  TextEditingController _titlecntrlr = new TextEditingController();
  TextEditingController _descriptioncntrlr = new TextEditingController();
  TextEditingController _datecntrlr = new TextEditingController();
  TextEditingController _timecntrlr = new TextEditingController();

  var image1;
  File imagepath;
  File croppedFile1;
  String fileName;
  List<MultipartFile> images = new List<MultipartFile>();
  String selectedEventDate;
  String selectedEventTime;
  bool _isDialogShowing = false;

  void initState() {
    super.initState();
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
            ? [CropAspectRatioPreset.ratio3x2]
            : [CropAspectRatioPreset.ratio3x2],
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
      images.add(MultipartFile.fromFileSync(croppedFile1.path,
          filename: croppedFile1.path.split('/').last));
    }
  }

  Widget getImageFromDecorationBox() {
    // if (widget.allPostsModel != null && croppedFile1 == null) {
    //   return Image.network(widget.allPostsModel.data[widget.index].photoUrl);
    // }
    if (croppedFile1 != null) {
      return Image.file(
        File(croppedFile1.path),
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset('assets/images/placeholder2.png', fit: BoxFit.fill);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              'Event',
              style: TextStyle(color: color1),
            ),
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => PostsScreen()));
              },
              child: Icon(
                Icons.arrow_back,
                color: color1,
              ),
            ),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        Container(
                          width: 200,
                          margin: EdgeInsets.only(bottom: 15),
                          child: GestureDetector(
                            onTap: () {
                              showProfileOptions(
                                  context,
                                  "Pick from Gallery",
                                  "Pick Video",
                                  "Take a Picture",
                                  () {
                                    Navigator.pop(context);
                                    getImageFromCamera(context, true);
                                  },
                                  () {},
                                  () {
                                    Navigator.pop(context);
                                    getImageFromCamera(context, false);
                                  });
                            },
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: <Widget>[
                                (croppedFile1 != null)
                                    ? Container(
                                        height: 200,
                                        padding: EdgeInsets.all(10),
                                        margin: EdgeInsets.all(10),
                                        decoration: new BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(0.0, 1.0),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        // child: Image.file(File(croppedFile1.path)),
                                        child: getImageFromDecorationBox(),
                                      )
                                    : Container(
                                        margin: EdgeInsets.all(10),
                                        child: Text('Tap to add photo')),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: DropdownButtonFormField(
                            autovalidate: true,
                            style: regularTxtStyle.copyWith(color: color1),
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Select event type',
                                labelStyle:
                                    regularTxtStyle.copyWith(color: color2),
                                alignLabelWithHint: true,
                                border: OutlineInputBorder()),
                            elevation: 2,
                            icon: Icon(Icons.arrow_drop_down),
                            value: selectedtype,
                            onChanged: (value) {
                              setState(() {});
                              selectedtype = value;
                            },
                            items: eventTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  style: TextStyle(color: Colors.black),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          enabled: true,
                          maxLines: 1,
                          controller: _titlecntrlr,
                          keyboardType: TextInputType.text,
                          // textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                          decoration: new InputDecoration(
                            labelText: 'Event Title',
                            labelStyle: regularTxtStyle.copyWith(
                                color: color2), // add hinttext in case Design
                            counterText: "",
                            // hintStyle: regularTxtStyle.copyWith(color: Colors.black45),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          minLines: 1,
                          maxLines: 5,
                          controller: _descriptioncntrlr,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: new InputDecoration(
                            labelText: 'Event Description',
                            labelStyle: regularTxtStyle.copyWith(
                                color: color2), // add hinttext in case Design
                            counterText: "",
                            // hintStyle: regularTxtStyle.copyWith(color: Colors.black45),
                          ),
                        ),
                        Row(children: [
                          Flexible(
                            flex: 5,
                            child: InkWell(
                              onTap: () async {
                                var selectedDate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  initialDate: DateTime.now(),
                                  lastDate:
                                      DateTime.now().add(Duration(days: 180)),
                                );

                                setState(() {
                                  print(selectedDate.toString());
                                  _datecntrlr.text = DateFormat('dd/MM/yyyy')
                                      .format(selectedDate);
                                });
                              },
                              child: TextFormField(
                                enabled: false,
                                controller: _datecntrlr,
                                decoration: InputDecoration(
                                    disabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black45),
                                    ),
                                    labelText: 'Select Date',
                                    labelStyle: regularTxtStyle.copyWith(
                                        color: color2)),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 5,
                            child: InkWell(
                              onTap: () async {
                                var selectedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now());
                                setState(() {
                                  _timecntrlr.text =
                                      selectedTime.format(context);
                                  String hours =
                                      selectedTime.hour.toString().length == 1
                                          ? '0${selectedTime.hour.toString()}'
                                          : selectedTime.hour.toString();

                                  String minutes =
                                      selectedTime.minute.toString().length == 1
                                          ? '0${selectedTime.minute.toString()}'
                                          : selectedTime.minute.toString();
                                  selectedEventTime = hours + ':' + minutes;
                                });
                              },
                              child: TextFormField(
                                  controller: _timecntrlr,
                                  enabled: false,
                                  decoration: InputDecoration(
                                    disabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black45),
                                    ),
                                    labelText: 'Select Time',
                                    labelStyle:
                                        regularTxtStyle.copyWith(color: color2),
                                  )),
                            ),
                          ),
                        ]),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              !widget.isNew
                                  ? Container(
                                      margin: EdgeInsets.only(right: 20),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50.0)),
                                        child: Container(
                                          height: 40,
                                          color: color2,
                                          child: MaterialButton(
                                              highlightColor:
                                                  Colors.transparent,
                                              splashColor: Colors.white24,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 10),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
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
                              padding:
                                  const EdgeInsets.only(left: 10.0, right: 10),
                              // child: Text(
                              //   widget.isNewBike ? 'Add Bike' : 'Update Bike',
                              //   style: TextStyle(color: Colors.white),
                              // ),
                              child: _isDialogShowing
                                  ? SizedBox(
                                      width: 20,
                                      child: SpinKitCircle(
                                        color: Colors.white,
                                        size: 20.0,
                                        duration: Duration(milliseconds: 1000),
                                      ),
                                    )
                                  : Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    )),
                          onPressed: () async {
                            sendEventData();
                          }),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendEventData() async {
    setState(() {
      _isDialogShowing = true;
    });

    Dio dio = new Dio();
    dio.options.headers['Authorization'] = 'Bearer ' + SessionData().token;
    dio.options.headers['Content-Type'] = 'multipart/form-data';
    dio.options.responseType = ResponseType.json;

    String url = commonapi + '/api/v1/event/createEvent';
    print(url);
    print(images);
    FormData formData = FormData.fromMap({
      'eventType': selectedtype,
      'title': _titlecntrlr.text,
      'description': _descriptioncntrlr.text,
      'eventDate': _datecntrlr.text,
      'eventTime': _timecntrlr.text,
      'multiple_image': [
        MultipartFile.fromFileSync(croppedFile1.path, filename: fileName),
      ]
    });
    print(formData.fields);
    try {
      final request = await dio.post(url, data: formData);

      if (request.statusCode == 200) {
        print('success');
        print(request.data.toString());
        setState(() {
          _isDialogShowing = false;
        });
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomeScreen(index: 2)));
      }
    } on DioError catch (e) {
      print('failed');
      print(e.response.data.toString());
      setState(() {
        _isDialogShowing = false;
      });
    }
  }
}
