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
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(0.347596, 32.582520),
    zoom: 14.4746,
  );
  final Map<String, Marker> _markers = {};
  Map<CircleId, Circle> circles = <CircleId, Circle>{};

  CircleId? selectedCircle;

  void getCurrentPosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latlngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latlngPosition, zoom: 14);
    _mapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
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

    BorderRadiusGeometry slidingPanelRadius = const BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return Material(
      child: Stack(
        children: [
          SlidingUpPanel(

            minHeight: 50,
            maxHeight: 280,
            color: Color(0xFF111111).withOpacity(0.8),
            borderRadius: slidingPanelRadius,
            backdropEnabled: true,
            body: SafeArea(
              child: Scaffold(
                  body: Stack(children: [
                    GoogleMap(
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
                    ),
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Colors.white,
                                Colors.white70,
                                Colors.white30
                              ]
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Opacity(opacity: 0, child: Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: CircleAvatar(),
                          )),
                          Text('서울특별시 강남구 선릉로551',),
                          Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: SizedBox(height: 33, width: 33, child: CircleAvatar(foregroundColor: Colors.white, backgroundColor: Colors.black, child: Icon(Icons.person),)),
                          )
                        ],
                      ),
                    )
                  ])),
            ),
            panel: Column(
              children: [
                SizedBox(
                  height: 12.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 34,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // the fab
          Positioned(
            right: 20.0,
            bottom: 60,
            child: SizedBox(
              height: 55,
              width: 55,
              child: FloatingActionButton(
                backgroundColor: Color(0xFF111111),
                foregroundColor: Colors.white,

                child: const Icon(
                  Icons.gps_fixed,
                ),
                onPressed: () {},
              ),
            ),
          ),
          Positioned(
            right: 20.0,
            bottom: 125,
            child: SizedBox(
              height: 55,
              width: 55,
              child: FloatingActionButton(
                backgroundColor: Color(0xFF01F982),
                foregroundColor: Colors.black,
                child: const Icon(
                  Icons.push_pin,

                ),
                onPressed: () {},
              ),
            ),
          ),
        ],

      ),
    );
  }
}
