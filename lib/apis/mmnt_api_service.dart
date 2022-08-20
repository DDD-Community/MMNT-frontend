import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MmntApiService {
  Dio? _dio;
  String tag = "MMNT API :";
  static final Dio mDio = Dio();

  static final MmntApiService _instance = MmntApiService._internal();

  factory MmntApiService() {
    return _instance;
  }

  MmntApiService._internal() {
    _dio = initApiServiceDio();
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return token;
  }

  Dio initApiServiceDio() {

    final baseOption = BaseOptions(
      connectTimeout: 45 * 1000,
      receiveTimeout: 45 * 1000,
      // baseUrl: 'https://maps.googleapis.com/maps/api/place/',
      baseUrl: 'https://dev.mmnt.link',
      contentType: 'application/json',
      headers: {'Authorization':'Bearer ${getToken()}'},
    );

    mDio.options = baseOption;

    final mInterceptorsWrapper =
    InterceptorsWrapper(onRequest: (options, handler) {
      debugPrint(
          "$tag ${options.method} "
              "${options.baseUrl.toString() + options.path}",
          wrapWidth: 1024);

      debugPrint("$tag ${options.headers.toString()}", wrapWidth: 1024);
      debugPrint("$tag ${options.queryParameters.toString()}", wrapWidth: 1024);
      debugPrint("$tag ${options.data.toString()}", wrapWidth: 1024);
      return handler.next(options); //continue
    }, onResponse: (response, handler) {
      debugPrint("Code  ${response.statusCode.toString()}", wrapWidth: 1024);
      debugPrint("Response ${response.toString()}", wrapWidth: 1024);
      return handler.next(response); // continue
    }, onError: (DioError e, handler) {
      debugPrint("$tag ${e.error.toString()}", wrapWidth: 1024);
      debugPrint("$tag ${e.response.toString()}", wrapWidth: 1024);
      return handler.next(e); //continue
    });

    mDio.interceptors.add(mInterceptorsWrapper);
    return mDio;
  }

  Future<Response> get(
      String endUrl,
      BuildContext context, {
        Map<String, dynamic>? params,
        Options? options,
      }) async {
    try {
      var isConnected = await checkInternet();
      if (!isConnected) {
        return Future.error("Internet not connected");
      }
      return await (_dio!.get(
        endUrl,
        queryParameters: params,
        options: options,
      ));
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout) {
        return Future.error("Poor internet connection");
      }
      rethrow;
    }
  }

  Future<Response> patch(
      String endUrl,
      BuildContext context,
      Map<String, dynamic>? params,
      Options? options,
      ) async {
    try {
      var isConnected = await checkInternet();
      if (!isConnected) {
        return Future.error("Internet not connected");
      }
      return await (_dio!.patch(
        endUrl,
        data: jsonEncode(params),
        // queryParameters: params,
        options: options,
      ));
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout) {
        return Future.error("Poor internet connection");
      }
      rethrow;
    }
  }

  Future<bool> checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}
