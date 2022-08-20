import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:dash_mement/constants/file_constants.dart';
import 'package:dash_mement/models/moment_model.dart';
import 'package:dash_mement/providers/app_provider.dart';
import 'package:dash_mement/providers/map_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as Lottie;
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../apis/api_manager.dart';
import '../constants/api_constants.dart';
import '../constants/style_constants.dart';
import 'package:http/http.dart' as http;
import '../domain/story.dart';
import '../models/error_model.dart';
import '../models/pin_model.dart';
import '../providers/pushstory_provider.dart';
import '../providers/sliidng_panel_provider.dart';
import '../providers/storylist_provider.dart';
import '../showstory/show_story.dart';
import '../showstory/show_story_arguments.dart';
import '../userpage/user_page.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map-screen';
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final PanelController _pc = PanelController();
  final Set<Marker> _showMarkers = {};
  final double _initFabHeight = 60.h;
  final double _panelHeightOpen = 284.h;
  final double _panelHeightClosed = 50.h;
  final int _markerSizeMedium = Platform.isIOS ? 65 : 45;
  final GlobalKey? _keyGoogleMap = GlobalKey();
  final List<PinModel> _pins = [];
  bool _isCameraReCenter = false;

  late double _fabHeight = 0;
  late String _mapStyle;
  late GoogleMapController _mapController;
  late Position currentPosition;
  late BitmapDescriptor _momentMarker;

  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  // static const CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(37.532600, 127.024612),
  //   zoom: 14.4746,
  // );
  // double _currentZoom = 14.4746;
  // late BitmapDescriptor _pharmacyMarker;
  // late BitmapDescriptor _farPharmacyMarker;
  // List<Story> _stories = [];

  // final List<LatLng> _nearestPharmacies = [];
  // PharmacyDetailsModel? _pharmacyDetailsModel;
  // List<PharmacyDetailsModel> _pharmacies = [];

  // int _minClusterZoom = 0;
  // int _maxClusterZoom = 19;

  @override
  void initState() {
    super.initState();
    _initialiseMarkerBitmap(context);
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      // Provider.of<SlidingPanelProvider>(context, listen: false)
      //     .updateWidth(MediaQuery.of(context).size.width);
      // Provider.of<SlidingPanelProvider>(context, listen: false)
      //     .updateHeight(_getMapHeight());
      rootBundle.loadString(FileConstants.mapStyle).then((string) {
        _mapStyle = string;
      });
      _getUserLocation(context);
    });
    _fabHeight = _initFabHeight;
  }

  // _getMapHeight() {
  //   RenderBox? renderBoxRed =
  //       _keyGoogleMap?.currentContext?.findRenderObject() as RenderBox?;
  //   final size = renderBoxRed?.size;
  //   return size?.height;
  // }

  void _push(BuildContext context, PinModel pinModel) async {
    StoryListProvider storyListProvider = Provider.of<StoryListProvider>(context, listen: false);
    storyListProvider.clear();
    MapProvider mapProvider = Provider.of<MapProvider>(context, listen: false);
    Provider.of<PushStoryProvider>(context, listen: false).setLatLng(double.parse(pinModel.latitude_y), double.parse(pinModel.longitude_x),);

    List<Story> storyList = await _getMomentList(pinModel.id);
    if (storyList != null) {
      storyList.forEach((element) => storyListProvider.add(element));
      Navigator.pushNamed(context, ShowStory.routeName,
          arguments: ShowStoryArguments(
            firstUrl: storyList[0].link,
            lat_y: mapProvider.currentLatLng!.latitude,
            lng_x: mapProvider.currentLatLng!.longitude,
          ));
    } else {}
  }

  Future<List<Story>> _getMomentList(String currentPinIndex) async {
    // final token =
    //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjE0IiwiZW1haWwiOiJwcmFjb25maUBuYXZlci5jb20iLCJpYXQiOjE2NjAxODAzMTIsImV4cCI6MTY2MTM4OTkxMn0.JFyfKkE7udj5IAAXttGOmRK-_bbRdY4vENypAsjZ1Qg";
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final url = Uri.parse(
        "https://dev.mmnt.link/moment/pin/$currentPinIndex?page=1&limit=4");
    final response = await http.get(url, headers: {
      "accept": "application/json; charset=utf-8",
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body)["result"];

      final List<Story> list =
          json.map<Story>((js) => Story.fromJson(js)).toList();

      return list;
    } else {
      print(response.statusCode.toString());
      throw Exception;
    }
  }

  // TODO 위치 수정 필요
  Future<String> _getAddress(double lat, double lng) async {
    try {
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
    } catch (e) {
      return '해외';
    } finally {}
  }

  Future<void> _getUserLocation(BuildContext context) async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    currentPosition = position;
    LatLng latlngPosition = LatLng(position.latitude, position.longitude);
    String newAddress = await _getAddress(
        position.latitude!.toDouble(), position.longitude!.toDouble());

    Provider.of<MapProvider>(context, listen: false)
        .updateCurrentAddress(newAddress);
    Provider.of<MapProvider>(context, listen: false)
        .updateCurrentLocation(latlngPosition);
    PushStoryProvider pushStory =
        Provider.of<PushStoryProvider>(context, listen: false);
    pushStory.latitude_y = position.latitude!.toDouble();
    pushStory.longitude_x = position.longitude!.toDouble();

    _getPinsList(context, latlngPosition);

    // await LocationService().fetchCurrentLocation(context, _getPinsList,
    //     updatePosition: updateCameraPosition);
    // LatLng latlngPosition = LatLng(position.latitude, position.longitude);
    // CameraPosition cameraPosition =
    //     new CameraPosition(target: latlngPosition, zoom: 14);
    // _mapController
    //     .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    //
    // PermissionUtils?.requestPermission(Permission.location, context,
    //     isOpenSettings: true, permissionGrant: () async {
    //   await LocationService().fetchCurrentLocation(context, _getPinsList,
    //       updatePosition: updateCameraPosition);
    // }, permissionDenied: () {
    //   Fluttertoast.showToast(
    //       backgroundColor: Colors.blue,
    //       msg:
    //           "Please grant the required permission from settings to access this feature.");
    // });
    // context.read<AppProvider>().updateAppState(AppStatus.loaded);
  }

  void updateCameraPosition(CameraPosition cameraPosition) {
    _mapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _initialiseMarkerBitmap(BuildContext context) async {
    await _bitmapDescriptorFromSvgAsset(
            context, FileConstants.icMomentPin, _markerSizeMedium)
        .then((value) => _momentMarker = value);
    // await _bitmapDescriptorFromSvgAsset(
    //         context, FileConstants.icPharmacyMarker, _markerSizeMedium)
    //     .then((value) => _pharmacyMarker = value);
    // await _bitmapDescriptorFromSvgAsset(
    //         context, FileConstants.icFarPharmacyMarker, _markerSizeMedium)
    //     .then((value) => _farPharmacyMarker = value);
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

  void _getPinsList(BuildContext context, LatLng latlngPosition) async {
    Provider.of<AppProvider>(context, listen: false)
        .updateAppState(AppStatus.loading);

    ApiManager()
        .getPins(context, ApiConstants.getPins(), latlngPosition)
        .then((value) {
      setState(() {
        _pins.clear();

        // _pharmacies.clear();
        value.data['result'][0]['pinLists'].forEach((element) {
          _pins.add(PinModel(
            id: element['pin_idx']!,
            latitude_y: element['pin_y']!,
            longitude_x: element['pin_x']!,
          ));
          //     LatLng(
          //   double.parse(element['pin_y']!),
          //   double.parse(element['pin_x']!),
          // )
        });
        if (value.data['result'][1]['mainPin'].isNotEmpty) {
          MomentModel mainMoment = MomentModel.fromJson(value.data['result'][1]['mainPin']);
          Provider.of<MapProvider>(context, listen: false).updateMainMoment(mainMoment);
        }
      });
      _setMarkerUi(context, latlngPosition);
    }).catchError((e) {
      if (e is ErrorModel) {
        debugPrint("${e.response}");
      }
      Fluttertoast.showToast(
          backgroundColor: Colors.blue, msg: "${e.response}");
    });
  }

  // void _getPlaceList() async {
  //   ApiManager()
  //       .getPlaces(
  //           ApiConstants.getPlaces(
  //               Provider.of<MapProvider>(context, listen: false).currentLatLng!,
  //               "AIzaSyCVeSxT9CRICi1ly2W3XUXFmmpZwRplXQQ"),
  //           context)
  //       .then((value) {
  //     setState(() {
  //       _nearestPharmacies.clear();
  //       _pharmacies.clear();
  //       value.data[KeyConstants.resultsKey].forEach((element) {
  //         _nearestPharmacies.add(LatLng(
  //             element[KeyConstants.geometryKey][KeyConstants.locationKey]
  //                     [KeyConstants.latKey]
  //                 .toDouble(),
  //             element[KeyConstants.geometryKey][KeyConstants.locationKey]
  //                     [KeyConstants.lngKey]
  //                 .toDouble()));
  //         _pharmacies.add(PharmacyDetailsModel(
  //             icon: element[KeyConstants.iconKey].toString(),
  //             iconBackgroundColor:
  //                 element[KeyConstants.iconBackgroundColorKey].toString(),
  //             placeId: element[KeyConstants.placeIdKey].toString(),
  //             name: element[KeyConstants.nameKey].toString(),
  //             vicinity: element[KeyConstants.vicinityKey].toString(),
  //             geometry: Geometry(
  //                 location: Location(
  //                     lat: element[KeyConstants.geometryKey]
  //                         [KeyConstants.locationKey][KeyConstants.latKey],
  //                     lng: element[KeyConstants.geometryKey]
  //                         [KeyConstants.locationKey][KeyConstants.lngKey]),
  //                 viewport: ViewPort(
  //                     northeast: Location(lat: 0.0, lng: 0.0),
  //                     southwest: Location(lat: 0.0, lng: 0.0))),
  //             distance: 0.00,
  //             rating: element[KeyConstants.ratingKey] != null
  //                 ? element[KeyConstants.ratingKey].toDouble()
  //                 : 0.00,
  //             openingHours: element[KeyConstants.openingHoursKey] != null
  //                 ? OpeningHours(openNow: element[KeyConstants.openingHoursKey][KeyConstants.openNowKey])
  //                 : OpeningHours(openNow: false)));
  //       });
  //     });
  //     _setMarkerUiforPlaces();
  //     // _setMarkerUi();
  //   }).catchError((e) {
  //     if (e is ErrorModel) {
  //       debugPrint("${e.response}");
  //     }
  //   });
  // }
  //
  // void _setMarkerUiforPlaces() async {
  //   List<Marker> _generatedMapMarkers = [];
  //   // var i = 0;
  //
  //   _nearestPharmacies.forEach((element) {
  //     // i++;
  //     _generatedMapMarkers.add(
  //       Marker(
  //           markerId: MarkerId(element.hashCode.toString()),
  //           icon: _momentMarker,
  //           position: LatLng(element.latitude, element.longitude),
  //           onTap: () {
  //             _pc.open();
  //
  //
  //           }),
  //     );
  //   });
  //   setState(() {
  //     _showMarkers.clear();
  //     _showMarkers.addAll(_generatedMapMarkers);
  //   });
  //   _mapController.animateCamera(
  //       CameraUpdate.newLatLngBounds(_getBounds(_nearestPharmacies), 50));
  //
  //
  //   // context.read<AppProvider>().updateAppState(AppStatus.loaded);
  //   Future.delayed(const Duration(seconds: 3), _pc.open);
  // }

  void _setMarkerUi(BuildContext context, LatLng latlngPosition) async {
    // context.watch<AppProvider>().updateAppState(AppStatus.loading);
    MapProvider mapProvider = Provider.of<MapProvider>(context, listen: false);
    List<Marker> _generatedMapMarkers = [];
    // var i = 0;
    _pins.forEach((element) {
      // i++;
      _generatedMapMarkers.add(
        Marker(
            markerId: MarkerId(element.hashCode.toString()),
            icon: _momentMarker,
            // icon: markerbitmap,
            position: LatLng(double.parse(element.latitude_y), double.parse(element.longitude_x)),
            onTap: () {
              HapticFeedback.lightImpact();
              _push(context, element);
              // _pc.open
            }),
      );
    });
    List<LatLng> _pinBound = _pins.map((element) {
      return LatLng(double.parse(element.latitude_y), double.parse(element.longitude_x));
    }).toList();
    Provider.of<AppProvider>(context, listen: false)
        .updateAppState(AppStatus.loaded);

    setState(() {
      _showMarkers.clear();
      _showMarkers.addAll(_generatedMapMarkers);
    });

    if (_pins.isEmpty) {
      CameraPosition cameraPosition =
          new CameraPosition(target: latlngPosition, zoom: 14);
      _mapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    } else {
      _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(_getBounds(_pinBound), 50));
    }

    Future.delayed(const Duration(seconds: 3), _pc.open);
    _mapController
        .animateCamera(CameraUpdate.newLatLngBounds(_getBounds(_pinBound), 50));

    Future.delayed(const Duration(seconds: 2), _pc.open);
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
    final state = context.watch<AppProvider>();
    final MapProvider mapProvider = context.watch<MapProvider>();

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
              child: Scaffold(body: Consumer<SlidingPanelProvider>(
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
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.pushNamed(context, UserPage.routeName);
                                  },
                                  child: CircleAvatar(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.black,
                                    child: Icon(Icons.person),
                                  ),
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
                  child: _showMarkers.isEmpty
                      ? const NoPinMoment()
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  mapProvider.mainMoment.title,
                                  style: kWhiteBold20,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 16.h,
                            ),
                            Container(
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
                              height: 160.h,
                              width: 335.w,
                              color: Color(0xff1E1E21),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            mapProvider.mainMoment.title,
                                            style: kGrayBold18.copyWith(
                                                color: Colors.white),
                                          ),
                                          Text(
                                            mapProvider.mainMoment.artist,
                                            style: kGray12,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: Lottie.Lottie.asset(
                                              "assets/json/equalizer.json"))
                                    ],
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(50),
                                    ),
                                    child: const Text(
                                      '지금 이곳에 기록된 모먼트 보기',
                                    ),
                                    onPressed: () {
                                      // Provider.of<StoryListProvider>(context, listen: false).getStoryList(context, state.mainMoment.pin_idx);
                                      // Navigator.pushNamed(
                                      //   context,
                                      //   ShowStory.routeName,
                                      //   arguments: ShowStoryArguments(
                                      //       'https://youtu.be/oxs3K8SPXpI',
                                      //       state.currentLatLng!.latitude,
                                      //       state.currentLatLng!.longitude),
                                      // );
                                      _push(
                                          context,
                                          PinModel(
                                              id: mapProvider
                                                  .mainMoment.pin_idx,
                                              latitude_y: mapProvider
                                                  .mainMoment.latitude_y!,
                                              longitude_x: mapProvider
                                                  .mainMoment.longitude_x!));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                )
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
                      HapticFeedback.mediumImpact();
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
                        HapticFeedback.mediumImpact();
                        Navigator.pushNamed(context, '/pin-create-screen');
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

          state.appStatus == AppStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : Container(),
        ],
      ),
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
              child: Image.asset(
                'assets/images/no-pin.png',
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
