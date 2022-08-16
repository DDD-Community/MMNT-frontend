import 'package:dash_mement/models/moment_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/pin_model.dart';

class MapProvider extends ChangeNotifier {
  LatLng? currentLatLng;
  int currentPinIndex = 0;
  String currentAddress = '지구 어딘가';
  MomentModel mainMoment = MomentModel(music: '', artist: '', youtube_url: '', distance: 0, title: '', pin_idx: '', moment_idx: '');
  List<PinModel> pinsList = [];

  void updateMainMoment(MomentModel moment) {
    mainMoment = moment;
    notifyListeners();
  }

  void updateCurrentAddress(String address) {
    currentAddress = address;
    notifyListeners();
  }

  void updateCurrentLocation(LatLng latLng) {
    currentLatLng = latLng;
    notifyListeners();
  }

  void resetMapProvider() {
    currentLatLng = null;
    notifyListeners();
  }
}