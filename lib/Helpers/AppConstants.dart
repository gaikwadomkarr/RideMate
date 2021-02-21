import 'package:bikingapp/Models/SessionData.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

final color1 = Color(0xFF00784B);
final color2 = Color(0xFF42A982);
final color3 = Color(0xFF088CE6);
final color4 = Color(0xFF7AC6FB);
final String commonapi = 'http://192.168.0.104:4000';

TextStyle smallTxtStyle = TextStyle(
  fontFamily: "Roboto",
  color: color1,
);

TextStyle smallTxtStyleBold =
    TextStyle(fontFamily: "Roboto", color: color1, fontWeight: FontWeight.w600);

TextStyle regularTxtStyle = TextStyle(
  fontFamily: "Roboto",
  color: color1,
);

TextStyle medTxtStyle = TextStyle(
  fontFamily: "Roboto",
  color: color1,
);
TextStyle largeTxtStyle = TextStyle(
  fontFamily: "Roboto",
  color: color1,
);
TextStyle menuTxtStyleSemiBold =
    TextStyle(fontFamily: "Roboto", color: color1, fontWeight: FontWeight.w600);

TextStyle medTxtStyleSemiBold =
    TextStyle(fontFamily: "Roboto", color: color1, fontWeight: FontWeight.w600);

TextStyle semiBoldTxtStyle =
    TextStyle(fontFamily: "Roboto", color: color1, fontWeight: FontWeight.w600);

TextStyle boldTxtStyle = TextStyle(
  fontFamily: "Roboto",
  color: color1,
);

TextStyle extraLightTxtStyle = TextStyle(
  fontFamily: "Roboto",
  color: color1,
);
TextStyle statsTxtStyleSemiBold =
    TextStyle(fontFamily: "Roboto", color: color1, fontWeight: FontWeight.w600);

Dio getDio() {
  Dio dio = new Dio();
  dio.options.followRedirects = false;
  dio.options.validateStatus = (status) {
    return status <= 500;
  };
  dio.options.headers['content-Type'] = 'application/json';
  dio.options.headers['Accept'] = 'application/json';
  if (SessionData().token != null) {
    dio.options.headers['Authorization'] = 'Bearer ' + SessionData().token;
  }
  // dio.interceptors.add(DioFirebasePerformanceInterceptor());
  dio.options.responseType = ResponseType.json;

  return dio;
}
