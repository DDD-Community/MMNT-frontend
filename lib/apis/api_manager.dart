import 'package:dash_mement/providers/map_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';


import '../domain/error_model.dart';
import 'mmnt_api_service.dart';

class ApiManager {
  final MmntApiService _mmntApiService = MmntApiService();

  Future<dynamic> getPins(String url, BuildContext context) async {
    try {
      var latlng = context.watch<MapProvider>().currentLatLng;
      Map<String, dynamic>? params = {
          "locationX": latlng!.longitude,
          "locationY": latlng!.latitude,
          "radius": 50
      };

      Options options = Options(
        headers: {
          "authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjE0IiwiZW1haWwiOiJwcmFjb25maUBuYXZlci5jb20iLCJpYXQiOjE2NTgxNTI1ODYsImV4cCI6MTY1ODE1NjE4Nn0.8WmnHaY7sm6HtN0q0yqJR19RVSFkpos-WD9GxNHRw6I",
        },
      );

      final response = await _mmntApiService.patch(url, context, params, options);
      // .currentLatLng!.latitude,

      return response;
    } on DioError catch (error) {
      throw ErrorModel.fromJson(error.response?.data);
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
