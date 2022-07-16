import 'dart:io';
import 'dart:ui' as ui;
import 'package:dash_mement/constants/file_constants.dart';
import 'package:dash_mement/providers/map_provider.dart';
import 'package:dash_mement/utils/permission_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/style_constants.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final double _initFabHeight = 60.h;
  double _fabHeight = 0;
  double _panelHeightOpen = 284.h;
  double _panelHeightClosed = 50.h;
  late Position currentPosition;
  late GoogleMapController _mapController;
  late String _mapStyle;
  Set<Marker> _showMarkers = {};
  int markerSizeMedium = Platform.isIOS ? 65 : 45;
  GlobalKey? _keyGoogleMap = GlobalKey();
  bool _isCameraReCenter = false;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.532600, 127.024612),
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
    _fabHeight = _initFabHeight;
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      rootBundle.loadString(FileConstants.mapStyle).then((string) {
        _mapStyle = string;
      });
      // _getUserLocation(context);
    });
  }


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
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            // minHeight: 50,
            // maxHeight: 284.h,
            color: const Color(0xFF111111).withOpacity(0.8),
            borderRadius: slidingPanelRadius,
            backdropEnabled: true,
            onPanelSlide: (double pos) => setState(() {
              _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                  _initFabHeight;
            }),
            body: SafeArea(
              child: Scaffold(
                  body: Stack(children: [
                    GoogleMap(
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      // zoomGesturesEnabled: true,
                      // zoomControlsEnabled: true,
                      key: _keyGoogleMap,
                      markers: _showMarkers,
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                        _mapController.setMapStyle(_mapStyle);
                        getCurrentPosition();
                      },

                    ),
                    Container(
                      height: 80.h,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.black.withOpacity(0.6),
                                Colors.black.withOpacity(0.1)
                              ]
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Opacity(opacity: 0, child: Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: CircleAvatar(),
                          )),
                          Text('서울특별시 강남구 선릉로551',),
                          Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: SizedBox(height: 35.h, width: 35.w, child: CircleAvatar(foregroundColor: Colors.white, backgroundColor: Colors.black, child: Icon(Icons.person),)),
                          )
                        ],
                      ),
                    )
                  ])),
            ),
            panel: Column(
              children: [
                SizedBox(
                  height: 12.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 4.h,
                      width: 34.w,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.all(Radius.circular(12.0))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // the fab
          Positioned(
            right: 20.0,
            bottom: _fabHeight,
            child: Column(
              children: [
                SizedBox(
                  height: 56.h,
                  width: 56.w,
                  child: FloatingActionButton(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    child: const Icon(
                      Icons.gps_fixed,
                    ),
                    onPressed: () {
                      getCurrentPosition();
                    },
                  ),
                ),
                SizedBox(height: 5.h,),
                Text('현재 위치', style: kFabTextStyle,)
              ],
            ),
          ),
          Positioned(
            right: 20.0,
            bottom: _fabHeight + 80.h,
            child: Column(
              children: [
                SizedBox(
                  height: 56.h,
                  width: 56.w,
                  child: FloatingActionButton(
                    child: SvgPicture.asset(
                      'assets/svgs/pin.svg',
                    ),
                    onPressed: () {},
                  ),
                ),
                SizedBox(height: 5.h,),
                Text('핀 생성', style: kFabTextStyle,)
              ],
            ),
          ),
        ],

      ),
    );
  }
}
