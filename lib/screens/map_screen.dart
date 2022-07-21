import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:dash_mement/constants/file_constants.dart';
import 'package:dash_mement/providers/map_provider.dart';
import 'package:dash_mement/utils/permission_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/style_constants.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String address = "지구어딘가";
  final double _initFabHeight = 60.h;
  double _fabHeight = 0;
  double _panelHeightOpen = 284.h;
  double _panelHeightClosed = 50.h;
  late Position currentPosition;
  late GoogleMapController _mapController;
  late String _mapStyle;
  Set<Marker> _showMarkers = {};
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  int markerSizeMedium = Platform.isIOS ? 65 : 45;
  GlobalKey? _keyGoogleMap = GlobalKey();
  bool _isCameraReCenter = false;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.532600, 127.024612),
    zoom: 14.4746,
  );


  final Map<String, Marker> _markers = {
    'abc': Marker(
      markerId: MarkerId('123'),
      position: LatLng(
        37.532800,
        127.025612,
      ),
    ),
    '22abc': Marker(
      markerId: MarkerId('12233'),
      position: LatLng(
        37.532800,
        127.025612,
      ),
    ),
    'cd2abc': Marker(
      markerId: MarkerId('1223we3'),
      position: LatLng(37.5438072, 126.970694),
    )


  };
  Map<CircleId, Circle> circles = <CircleId, Circle>{};

  CircleId? selectedCircle;

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
    String newAddress =
        await _getAddress(position.latitude, position.longitude);
    setState(() {
      address = newAddress;
    });
  }


  int _markerIdCounter= 0;
  static const LatLng center = LatLng(37.5438072, 126.970694);
  void _add() {
    final int markerCount = markers.length;

    if (markerCount == 12) {
      return;
    }

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        center.latitude + sin(_markerIdCounter * pi / 6.0) / 20.0,
        center.longitude + cos(_markerIdCounter * pi / 6.0) / 20.0,
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      // onTap: () => _onMarkerTapped(markerId),
      // onDragEnd: (LatLng position) => _onMarkerDragEnd(markerId, position),
      // onDrag: (LatLng position) => _onMarkerDrag(markerId, position),
    );

    setState(() {
      markers[markerId] = marker;
    });
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

  addMarker(cordinate) {
    int id = Random().nextInt(100);

    setState(() {
      _markers['$id'] =
          Marker(position: cordinate, markerId: MarkerId(id.toString()));
      // markers
      //     .add(Marker(position: cordinate, markerId: MarkerId(id.toString())));
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
                  onTap: (cordinate) {
                    // _controller.animateCamera(CameraUpdate.newLatLng(cordinate));
                    addMarker(cordinate);
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
                      ])),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Opacity(
                          opacity: 0,
                          child: Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: CircleAvatar(),
                          )),
                      Text(address),
                      Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: SizedBox(
                            height: 35.h,
                            width: 35.w,
                            child: CircleAvatar(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.black,
                              child: Icon(Icons.person),
                            )),
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
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.0))),
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
                    heroTag: "current_location",
                    backgroundColor: const Color(0xFFD9D9D9),
                    foregroundColor: Colors.white,
                    child: const Icon(
                      Icons.gps_fixed,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      getCurrentPosition();
                    },
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  '현재 위치',
                  style: kFabTextStyle,
                )
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
                    heroTag: "create_pin",
                    child: SvgPicture.asset(
                      'assets/svgs/pin.svg',
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _add();
                    }
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  '핀 생성',
                  style: kFabTextStyle,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
