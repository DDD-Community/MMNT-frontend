import 'dart:io';
import 'dart:ui' as ui;
import 'package:dash_mement/constants/file_constants.dart';
import 'package:dash_mement/providers/map_provider.dart';
import 'package:dash_mement/utils/permission_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Position currentPosition;
  late GoogleMapController _mapController;
  late String _mapStyle;
  Set<Marker> _showMarkers = {};
  int markerSizeMedium = Platform.isIOS ? 65 : 45;
  GlobalKey? _keyGoogleMap = GlobalKey();
  bool _isCameraReCenter = false;
  static const CameraPosition _kGooglePlex =  CameraPosition(
    target: LatLng(0.347596, 32.582520),
    zoom: 14.4746,
  );
  final Map<String, Marker> _markers = {};
  Map<CircleId, Circle> circles = <CircleId, Circle>{};

  CircleId? selectedCircle;



  void getCurrentPosition() async{
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latlngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: latlngPosition, zoom: 14);
    _mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }



  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      rootBundle.loadString(FileConstants.mapStyle).then((string) {
        _mapStyle = string;
      });
      // _getUserLocation(context);
    });
  }

  // Future<void> _getUserLocation(BuildContext context) async {
  //   PermissionUtils?.requestPermission(Permission.location, context,
  //       isOpenSettings: true, permissionGrant: () async {
  //         await LocationService().fetchCurrentLocation(context, _getPharmacyList,
  //             updatePosition: updateCameraPosition);
  //       }, permissionDenied: () {
  //         Fluttertoast.showToast(
  //             backgroundColor: Colors.blue,
  //             msg:
  //             "Please grant the required permission from settings to access this feature.");
  //       });
  // }



  @override
  Widget build(BuildContext context) {
    return Material(

      child: SlidingUpPanel(
        backdropEnabled: true,
        body: Scaffold(
            body: GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
              key: _keyGoogleMap,
              markers: _showMarkers,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _mapController.setMapStyle(_mapStyle);
                getCurrentPosition();
              },
              onCameraIdle: () {
                setState(() {
                  _isCameraReCenter = false;
                });
              },
            )
        ),
        panel: Center(child: Text('panel'),),
      ),
    );
  }
}
