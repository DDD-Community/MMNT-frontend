import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../component/error_dialog.dart';
import '../models/error_model.dart';
import '../screens/login_screen.dart';
import 'mmnt_api_service.dart';

class ApiManager {
  final MmntApiService _mmntApiService = MmntApiService();

  Future<dynamic> getPins(BuildContext context, String url, LatLng latlngPosition) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      var params = {
        "locationX": latlngPosition!.longitude,
        "locationY": latlngPosition!.latitude,
        "radius": 5000
      };
      Options options = Options(
        headers: {'Authorization':'Bearer $token'}
      );

      final response = await _mmntApiService.patch(url,context, params, options);

      return response;

    } on DioError catch (error) {
      if(error.response?.data['statusCode'] == 401) {

        Fluttertoast.showToast(
            backgroundColor: Colors.blue,
            msg: "${error.response}");

        Navigator.popUntil(context, ModalRoute.withName(LoginScreen.routeName));
      }

      var errorMsg = ErrorModel.fromJson(error.response?.data);
      errorDialog(context, errorMsg.message.toString());
    }
  }

  Future<dynamic> getPinDetail(BuildContext context, String url, LatLng latlngPosition) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      BaseOptions options = BaseOptions(

          connectTimeout: 10000,
          receiveTimeout: 10000,

          // TODO 배포전 수정
          headers: {
            'Authorization':'Bearer $token',
          }
      );

      Dio dio = Dio(options);
      // TODO: PATCH 테스트
      Response response = await dio.patch(url, data: {
        "locationX": latlngPosition!.longitude,
        "locationY": latlngPosition!.latitude,
        "radius": 5000
      });
      return response;

    } on DioError catch (error) {
      if(error.response?.data['statusCode'] == 401) {

        // errorDialog(context, '로그인 토큰 만료');
        // return;

        Fluttertoast.showToast(
            backgroundColor: Colors.blue,
            msg: "${error.response}");
        Navigator.popUntil(context, ModalRoute.withName(LoginScreen.routeName));
      }
      var errorMsg = ErrorModel.fromJson(error.response?.data);

      // errorDialog(context, errorMsg.message.toString());
    }
  }

  Future<dynamic> getPlaces(String url, BuildContext context) async {
    try {
      final response = await _mmntApiService.get(url, context);
      return response;
    } on DioError catch (error) {
      throw ErrorModel.fromJson(error.response?.data);
    }
  }

  Future<dynamic> getStories(BuildContext context, String url, String index) async {
    // try {
    //
    //   final response = await _mmntApiService.get(url + '/$index?page=1&limit=10', context);
    //   return response;
    // } on DioError catch (error) {
    //   throw ErrorModel.fromJson(error.response?.data);
    // }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      BaseOptions options = BaseOptions(

          connectTimeout: 10000,
          receiveTimeout: 10000,
          headers: {'Authorization':'Bearer $token'}
      );

      Dio dio = Dio(options);

      Response response = await dio.get('https://dev.mmnt.link' +url + '/12?page=1&limit=10');
      print(response.toString());
      return response;

    } on DioError catch (error) {
      throw ErrorModel.fromJson(error.response?.data);
    }
  }

}
