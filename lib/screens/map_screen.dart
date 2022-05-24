import 'dart:io';
import 'dart:ui' as ui;
import 'package:dash_mement/constants/file_constants.dart';
import 'package:dash_mement/providers/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  late String _mapStyle;
  Set<Marker> _showMarkers = {};
  int markerSizeMedium = Platform.isIOS ? 65 : 45;
  GlobalKey? _keyGoogleMap = GlobalKey();
  bool _isCameraReCenter = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      rootBundle.loadString(FileConstants.mapStyle).then((string) {
        _mapStyle = string;
      });
    });
  }

  CameraPosition _getLocationTarget() {
    var initialCameraPosition;
    if (Provider.of<MapProvider>(context, listen: false).currentLatLng !=
        null) {
      initialCameraPosition = CameraPosition(
        target: LatLng(
            Provider.of<MapProvider>(context, listen: false)
                .currentLatLng!
                .latitude,
            Provider.of<MapProvider>(context, listen: false)
                .currentLatLng!
                .longitude),
        zoom: 0,
      );
    } else {
      initialCameraPosition = CameraPosition(zoom: 0, target: LatLng(0, 0));
    }
    return initialCameraPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GoogleMap(
          myLocationEnabled: true,
          mapToolbarEnabled: false,
          key: _keyGoogleMap,
          markers: _showMarkers,
          initialCameraPosition: _getLocationTarget(),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _mapController.setMapStyle(_mapStyle);
          },
          onCameraIdle: () {
            setState(() {
              _isCameraReCenter = false;
            });
          },
        )
    );
  }
}
