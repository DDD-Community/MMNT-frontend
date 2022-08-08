import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dash_mement/constants/file_constants.dart';
import 'package:dash_mement/domain/story.dart';
import 'package:dash_mement/providers/app_provider.dart';
import 'package:dash_mement/providers/map_provider.dart';
import 'package:dash_mement/utils/permission_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as Lottie;
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../apis/api_manager.dart';
import '../constants/api_constants.dart';
import '../constants/key_constants.dart';
import '../constants/style_constants.dart';
import 'package:http/http.dart' as http;

import '../domain/error_model.dart';
import '../domain/pharmacy_details_model.dart';
import '../location/location_manager.dart';
import '../providers/info_window_provider.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final PanelController _pc = PanelController();
  late GoogleMapController _mapController;
  late String _mapStyle;
  Set<Marker> _showMarkers = {};
  final double _initFabHeight = 60.h;
  double _fabHeight = 0;
  double _panelHeightOpen = 284.h;
  double _panelHeightClosed = 50.h;

  late Position currentPosition;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  int markerSizeMedium = Platform.isIOS ? 65 : 45;
  final GlobalKey? _keyGoogleMap = GlobalKey();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.532600, 127.024612),
    zoom: 14.4746,
  );

  double _currentZoom = 14.4746;
  late BitmapDescriptor _momentMarker;
  late BitmapDescriptor _pharmacyMarker;
  late BitmapDescriptor _farPharmacyMarker;

  List<Story> _stories = [];
  List<LatLng> _pins = [];

  List<LatLng> _nearestPharmacies = [];
  PharmacyDetailsModel? _pharmacyDetailsModel;
  List<PharmacyDetailsModel> _pharmacies = [];

  bool _isCameraReCenter = false;
  int _minClusterZoom = 0;
  int _maxClusterZoom = 19;

  @override
  void initState() {
    super.initState();
    _initialiseMarkerBitmap(context);
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      Provider.of<InfoWindowProvider>(context, listen: false)
          .updateWidth(MediaQuery.of(context).size.width);
      Provider.of<InfoWindowProvider>(context, listen: false)
          .updateHeight(_getMapHeight());
      rootBundle.loadString(FileConstants.mapStyle).then((string) {
        _mapStyle = string;
      });
      _getUserLocation(context);
    });
    _fabHeight = _initFabHeight;
  }

  _getMapHeight() {
    RenderBox? renderBoxRed =
        _keyGoogleMap?.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBoxRed?.size;
    return size?.height;
  }

  Future<void> _getUserLocation(BuildContext context) async {
    context.read<AppProvider>().updateAppState(AppStatus.loading);

    PermissionUtils?.requestPermission(Permission.location, context,
        isOpenSettings: true, permissionGrant: () async {
      await LocationService().fetchCurrentLocation(context, _getPinsList,
          updatePosition: updateCameraPosition);
    }, permissionDenied: () {
      Fluttertoast.showToast(
          backgroundColor: Colors.blue,
          msg:
              "Please grant the required permission from settings to access this feature.");
    });
    context.read<AppProvider>().updateAppState(AppStatus.loaded);
  }

  void updateCameraPosition(CameraPosition cameraPosition) {
    _mapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _initialiseMarkerBitmap(BuildContext context) async {
    await _bitmapDescriptorFromSvgAsset(
            context, FileConstants.icMomentPin, markerSizeMedium)
        .then((value) => _momentMarker = value);
    await _bitmapDescriptorFromSvgAsset(
            context, FileConstants.icPharmacyMarker, markerSizeMedium)
        .then((value) => _pharmacyMarker = value);
    await _bitmapDescriptorFromSvgAsset(
            context, FileConstants.icFarPharmacyMarker, markerSizeMedium)
        .then((value) => _farPharmacyMarker = value);
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromSvgAsset(
      BuildContext context, String assetName, int width) async {
    var svgString = await DefaultAssetBundle.of(context).loadString(assetName);
    var svgDrawableRoot = await svg.fromSvgString(svgString, "");
    var picture = svgDrawableRoot.toPicture(
        size: Size(width.toDouble(), width.toDouble()));
    var image = await picture.toImage(width, width);
    var bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  void _getPinsList() async {
    ApiManager().getPins(ApiConstants.getPins(), context).then((value) {
      setState(() {
        _pins.clear();

        _pharmacies.clear();
        value.data['result'][0]['pinLists'].forEach((element) {
          _pins.add(LatLng(
            double.parse(element['pin_y']!),
            double.parse(element['pin_x']!),
          ));
          // _stories.add(
          //     Story(
        });
      });
      _setMarkerUi();
    }).catchError((e) {
      if (e is ErrorModel) {
        debugPrint("${e.response}");
      }
    });
  }

  void _getPlaceList() async {
    ApiManager()
        .getPlaces(
            ApiConstants.getPlaces(
                Provider.of<MapProvider>(context, listen: false).currentLatLng!,
                "AIzaSyCVeSxT9CRICi1ly2W3XUXFmmpZwRplXQQ"),
            context)
        .then((value) {
      setState(() {
        _nearestPharmacies.clear();
        _pharmacies.clear();
        value.data[KeyConstants.resultsKey].forEach((element) {
          _nearestPharmacies.add(LatLng(
              element[KeyConstants.geometryKey][KeyConstants.locationKey]
                      [KeyConstants.latKey]
                  .toDouble(),
              element[KeyConstants.geometryKey][KeyConstants.locationKey]
                      [KeyConstants.lngKey]
                  .toDouble()));
          _pharmacies.add(PharmacyDetailsModel(
              icon: element[KeyConstants.iconKey].toString(),
              iconBackgroundColor:
                  element[KeyConstants.iconBackgroundColorKey].toString(),
              placeId: element[KeyConstants.placeIdKey].toString(),
              name: element[KeyConstants.nameKey].toString(),
              vicinity: element[KeyConstants.vicinityKey].toString(),
              geometry: Geometry(
                  location: Location(
                      lat: element[KeyConstants.geometryKey]
                          [KeyConstants.locationKey][KeyConstants.latKey],
                      lng: element[KeyConstants.geometryKey]
                          [KeyConstants.locationKey][KeyConstants.lngKey]),
                  viewport: ViewPort(
                      northeast: Location(lat: 0.0, lng: 0.0),
                      southwest: Location(lat: 0.0, lng: 0.0))),
              distance: 0.00,
              rating: element[KeyConstants.ratingKey] != null
                  ? element[KeyConstants.ratingKey].toDouble()
                  : 0.00,
              openingHours: element[KeyConstants.openingHoursKey] != null
                  ? OpeningHours(openNow: element[KeyConstants.openingHoursKey][KeyConstants.openNowKey])
                  : OpeningHours(openNow: false)));
        });
      });
      _setMarkerUiforPlaces();
      // _setMarkerUi();
    }).catchError((e) {
      if (e is ErrorModel) {
        debugPrint("${e.response}");
      }
    });
  }

  void _setMarkerUiforPlaces() async {
    List<Marker> _generatedMapMarkers = [];
    // var i = 0;

    _nearestPharmacies.forEach((element) {
      // i++;
      _generatedMapMarkers.add(
        Marker(
            markerId: MarkerId(element.hashCode.toString()),
            icon: _momentMarker,
            position: LatLng(element.latitude, element.longitude),
            onTap: _pc.open),
      );
    });
    setState(() {
      _showMarkers.clear();
      _showMarkers.addAll(_generatedMapMarkers);
    });
    _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(_getBounds(_nearestPharmacies), 50));

    Future.delayed(const Duration(seconds: 3), _pc.open);
  }

  void _setMarkerUi() async {
    List<Marker> _generatedMapMarkers = [];
    // var i = 0;
    _pins.forEach((element) {
      // i++;
      _generatedMapMarkers.add(
        Marker(
            markerId: MarkerId(element.hashCode.toString()),
            icon: _momentMarker,
            // icon: markerbitmap,
            position: LatLng(element.latitude, element.longitude),
            onTap: _pc.open),
      );
    });
    setState(() {
      _showMarkers.clear();
      _showMarkers.addAll(_generatedMapMarkers);
    });

    if(_pins.isEmpty) {
      // todoL zoom
    } else {
      _mapController
          .animateCamera(CameraUpdate.newLatLngBounds(_getBounds(_pins), 50));
    }

    Future.delayed(const Duration(seconds: 3), _pc.open);
  }

  LatLngBounds _getBounds(List<LatLng> markerLocations) {
    var lngs = markerLocations.map<double>((m) => m.longitude).toList();
    var lats = markerLocations.map<double>((m) => m.latitude).toList();

    var topMost = lngs.reduce(max);
    var leftMost = lats.reduce(min);
    var rightMost = lats.reduce(max);
    var bottomMost = lngs.reduce(min);

    var bounds = LatLngBounds(
      northeast: LatLng(rightMost, topMost),
      southwest: LatLng(leftMost, bottomMost),
    );

    return bounds;
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
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
    BorderRadiusGeometry slidingPanelRadius = const BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return Material(
      child: Stack(
        children: [
          SlidingUpPanel(
            controller: _pc,
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
              child: Scaffold(body: Consumer<InfoWindowProvider>(
                builder: (BuildContext contex, infoWindowProvider, __) {
                  final GlobalKey<ScaffoldState> _scaffoldKey =
                      GlobalKey<ScaffoldState>();
                  return Stack(children: [
                    GoogleMap(
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      // zoomGesturesEnabled: true,
                      // zoomControlsEnabled: true,
                      key: _keyGoogleMap,
                      markers: _showMarkers,
                      initialCameraPosition: _getLocationTarget(),
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                        _mapController.setMapStyle(_mapStyle);
                      },
                      onCameraMove: (CameraPosition position) {
                        // _updateInfoWindowsWithMarkers(
                        //     infoWindowProvider, position);
                        Provider.of<MapProvider>(context, listen: false)
                            .updateCurrentLocation(LatLng(
                                position.target.latitude,
                                position.target.longitude));
                      },
                      onCameraIdle: () {
                        setState(() {
                          _isCameraReCenter = false;
                        });
                      },
                      onTap: (LatLng latLng) {
                        if (infoWindowProvider.showInfoWindowData) {
                          infoWindowProvider.updateVisibility(false);
                          infoWindowProvider.rebuildInfoWindow();
                        }
                      },
                    ),
                    if (infoWindowProvider.showInfoWindowData)
                      Positioned(
                          left: infoWindowProvider.leftMarginData,
                          bottom: infoWindowProvider.bottomMarginData,
                          child: Container()),
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
                          Text(context.watch<MapProvider>().currentAddress),
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
                  ]);
                },
              )),
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
                SizedBox(
                  height: 42.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child:
                      _showMarkers.isEmpty ? DummyMainMoment() : NoPinMoment(),
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
                      _pc.close();
                      _getUserLocation(context);
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
            bottom: _fabHeight + 90.h,
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
                        // _add();
                      }),
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

class DummyMainMoment extends StatelessWidget {
  const DummyMainMoment({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '여기 완전 노을 맛집',
              style: kWhiteBold20,
            ),
          ],
        ),
        SizedBox(
          height: 16.h,
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
          height: 160.h,
          width: 335.w,
          color: Color(0xff1E1E21),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        'Dar+ling',
                        style: kGrayBold18.copyWith(color: Colors.white),
                      ),
                      Text(
                        'SEVENTEEN',
                        style: kGray12,
                      ),
                    ],
                  ),
                  SizedBox(
                      width: 40,
                      height: 40,
                      child: Lottie.Lottie.asset("assets/json/equalizer.json"))
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  '지금 이곳에 기록된 모먼트 보기',
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NoPinMoment extends StatelessWidget {
  const NoPinMoment({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 16.h,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 115.h,
              width: 115.w,
              child: SvgPicture.asset(
                'assets/svgs/no-pin.svg',
              ),
            ),
            Text(
              '근처 핀 없음',
              style: kGrayBold18.copyWith(color: Colors.white),
            ),
            Text(
              '핀이 있는 위치 근처로 이동해주세요',
              style: kGray12,
            ),
          ],
        ),
      ],
    );
  }
}
