import 'dart:convert';

import 'package:dash_mement/providers/map_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';


import '../component/error_dialog.dart';
import '../domain/error_model.dart';
import 'mmnt_api_service.dart';
import '../constants/token_temp_file.dart' as Token;

class ApiManager {
  final MmntApiService _mmntApiService = MmntApiService();

  Future<dynamic> getPins(String url, BuildContext context) async {
    try {
      var latlng = Provider.of<MapProvider>(context, listen: false).currentLatLng;

      BaseOptions options = BaseOptions(

          connectTimeout: 10000,
          receiveTimeout: 10000,

          // TODO 배포전 수정
          headers: {'Authorization':'Bearer ${Token.jwt_token}',

          // headers: {'Authorization':'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjE0IiwiZW1haWwiOiJwcmFjb25maUBuYXZlci5jb20iLCJpYXQiOjE2NTg0MDg2MTQsImV4cCI6MTY1OTYxODIxNH0.zGKHTCnmLLF6SBnPdEAgBLxyN1czfLoHTmXwUh1X75E',

          }
      );

      Dio dio = new Dio(options);
      // TODO: PATCH 테스트
      Response response = await dio.patch(url, data: {
        "locationX": latlng!.longitude,
        "locationY": latlng!.latitude,
        "radius": 5000
      });
      return response;

    } on DioError catch (error) {
      if(error.response?.data['statusCode'] == 401) {
        errorDialog(context, '로그인 토큰 만료');
        // return;

      }
      var errorMsg = ErrorModel.fromJson(error.response?.data);
      errorDialog(context, errorMsg.message.toString());
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
}
