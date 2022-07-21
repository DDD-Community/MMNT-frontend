import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dash_mement/providers/map_provider.dart';
import 'package:dash_mement/utils/reusable_methods.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();
  Location location = Location();

  Future<void> fetchCurrentLocation(BuildContext context, Function mapData,
      {Function? updatePosition}) async {
    LocationData? getLocation;
    await location.changeSettings(accuracy: LocationAccuracy.high);
    try {
      var _hasLocationPermission = await location.hasPermission();
      if (_hasLocationPermission == PermissionStatus.granted) {
        grantedPermissionMethod(context, getLocation, mapData,
            updatePosition: updatePosition);

      } else if (_hasLocationPermission == PermissionStatus.denied) {
        var _permissionGranted = await location.requestPermission();
        if (_permissionGranted == PermissionStatus.granted) {
          grantedPermissionMethod(context, getLocation, mapData,
              updatePosition: updatePosition);
        } else if (_permissionGranted == PermissionStatus.denied) {
          serviceDisabledMethod(context, mapData);
        }
      }
    } on PlatformException catch (e) {
      debugPrint("${e.code}");
    }
  }

  void grantedPermissionMethod(
      BuildContext context, LocationData? locData, Function? mapData,
      {Function? updatePosition}) async {
    var _hasLocationServiceEnabled = await location.serviceEnabled();
    if (_hasLocationServiceEnabled) {
      serviceEnabledMethod(locData, context, mapData!,
          updatePosition: updatePosition);
    } else {
      var _serviceEnabled = await location.requestService();
      if (_serviceEnabled) {
        serviceEnabledMethod(locData, context, mapData!,
            updatePosition: updatePosition);
      } else {
        serviceDisabledMethod(context, mapData!);
      }
    }
  }

  void serviceEnabledMethod(
      LocationData? getLoc, BuildContext context, Function getMapData,
      {Function? updatePosition}) async {
    getLoc = await location.getLocation();
    Provider.of<MapProvider>(context, listen: false).updateCurrentLocation(
        LatLng(getLoc.latitude!.toDouble(), getLoc.longitude!.toDouble()));
    updatePosition!(CameraPosition(
        zoom: 0,
        target:
        LatLng(getLoc.latitude!.toDouble(), getLoc.longitude!.toDouble())));
    if (Provider.of<MapProvider>(context, listen: false).currentLatLng !=
        null) {
      await getMapData();
      _getLocationUpdates(context, getLoc, getMapData);
      String newAddress = await _getAddress(getLoc.latitude!.toDouble(), getLoc.longitude!.toDouble());
      Provider.of<MapProvider>(context, listen: false).updateCurrentAddress(newAddress);

    }
  }

  void serviceDisabledMethod(BuildContext context, Function getMapData) {
    debugPrint("Disable Permission");
  }

  Future<void> _getLocationUpdates(BuildContext context,
      LocationData locationData, Function callUpdateData) async {
    location.onLocationChanged.listen((value) async {
      final distance = calculateDistance(value.latitude, value.longitude,
          locationData.latitude, locationData.longitude);

      Provider.of<MapProvider>(context, listen: false).updateCurrentLocation(
          LatLng(value.latitude!.toDouble(), value.longitude!.toDouble()));
      locationData = value;
      if (distance > 0.5) {
        callUpdateData();
      }
    });
  }
}


// TODO 위치 수정 필요
Future<String> _getAddress(double lat, double lng) async {
  String? API_KEY = dotenv.env["TMAP_KEY"];
  final url_main = Uri.parse(
      "https://apis.openapi.sk.com/tmap/geo/reversegeocoding?version=1&lat=$lat&lon=$lng&coordType=WGS84GEO&addressType=A03&newAddressExtend=Y");
  final url_building = Uri.parse(
      "https://apis.openapi.sk.com/tmap/geo/reversegeocoding?version=1&lat=$lat&lon=$lng&coordType=WGS84GEO&addressType=A04&newAddressExtend=Y");
  final response_main = await http.get(url_main,
      headers: {"Accept": "aplication/json", "appKey": API_KEY!});
  final response_building = await http.get(url_building,
      headers: {"Accept": "aplication/json", "appKey": API_KEY});

  // 도로명 + 건물 번호
  return "${jsonDecode(response_main.body)["addressInfo"]['fullAddress']} ${jsonDecode(response_building.body)["addressInfo"]["buildingIndex"]}";
}