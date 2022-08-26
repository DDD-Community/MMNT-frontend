import 'dart:convert';
import 'package:dash_mement/providers/app_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../component/error_dialog.dart';
import '../models/error_model.dart';
import '../screens/login_screen.dart';
import 'mmnt_api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  void postUser(String email, String password) async {
    try {
      BaseOptions options = BaseOptions(

          connectTimeout: 10000,
          receiveTimeout: 10000,

          headers: {
            'Authorization':'Bearer ${dotenv.env['NOTION_API_KEY']}',
            'Notion-Version': '2022-06-28',
          }
      );
      const url = 'https://api.notion.com/v1/pages';

      Dio dio = Dio(options);
      // TODO: PATCH 테스트
      Response response = await dio.post(url, data: {
        "parent": {
          "database_id": dotenv.env['NOTION_USER_DATABASE_ID'] ?? ""
        },
        "properties": {
          "email": {
            "title": [
              {
                "text": {
                  "content": email
                }
              }
            ]
          },
          "password": {
            "rich_text": [
              {
                "text": {
                  "content": password
                }
              }
            ]
          }
        }
      });
      debugPrint(response.data);
      if(response.statusCode == 200) {
        final data = jsonDecode(response.data) as Map<String, dynamic>;
      }




    } catch(e) {
      debugPrint(e.toString());

    }

  }

  Future<void> postPin(String email, Map<String, dynamic> params) async {
    try {
      var data = <String, dynamic>{
        "title": params["title"],
        "description": params["description"],
        "imageUrl": params["imageUrl"],
        "youtubeUrl": params["youtubeUrl"],
        "music": params["music"],
        "artist": params["artist"],
        "pinX": params["pinX"],
        "pinY": params["pinY"],
      };

      BaseOptions options = BaseOptions(

          connectTimeout: 10000,
          receiveTimeout: 10000,

          headers: {
            'Authorization':'Bearer ${dotenv.env['NOTION_API_KEY']}',
            'Notion-Version': '2022-06-28',
          }
      );
      const url = 'https://api.notion.com/v1/pages';

      Dio dio = Dio(options);
      // TODO: PATCH 테스트
      Response response = await dio.post(url, data: {


        "parent": {
          "database_id": dotenv.env['NOTION_PIN_DATABASE_ID'] ?? ""
        },




        "properties": {
          "title": {
            "title": [
              {
                "text": {
                  "content": params["title"]
                }
              }
            ]
          },
          "description": {
            "rich_text": [
              {
                "text": {
                  "content": params["description"]
                }
              }
            ]
          },
          "imageUrl": {
            "rich_text": [
              {
                "text": {
                  "content": params["imageUrl"]
                }
              }
            ]
          },
          "youtubeUrl": {
            "rich_text": [
              {
                "text": {
                  "content": params["youtubeUrl"]
                }
              }
            ]
          },
          "music": {
            "rich_text": [
              {
                "text": {
                  "content": params["music"]
                }
              }
            ]
          },
          "artist": {
            "rich_text": [
              {
                "text": {
                  "content": params["artist"]
                }
              }
            ]
          },
          "longitude_x": {
            "rich_text": [
              {
                "text": {
                  "content": params["pinX"].toString()
                }
              }
            ]
          },
          "latitude_y": {
            "rich_text": [
              {
                "text": {
                  "content": params["pinY"].toString()
                }
              }
            ]
          },
          "email": {
            "rich_text": [
              {
                "text": {
                  "content": email
                }
              }
            ]
          },


        }
      });
      debugPrint(response.data);
      if(response.statusCode == 200) {
        final data = jsonDecode(response.data) as Map<String, dynamic>;
      }




    } catch(e) {
      debugPrint(e.toString());

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
