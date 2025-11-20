// ignore_for_file: prefer_const_constructors, avoid_print, prefer_interpolation_to_compose_strings, unused_field, prefer_typing_uninitialized_variables, unused_local_variable
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart'
    as hoc;
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice2/places.dart' as maps;
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/screen/home_screen.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

var latt;
var longg;

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  HomePageController homePageController = Get.find();

  String googleApikey = Config.googleKey;
  GoogleMapController? mapController;
  CameraPosition? cameraPosition;
  LatLng startLocation = LatLng(lat, long);
  String location = "Search Location".tr;

  final List<Marker> _markers = <Marker>[];

  var newlatlang;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  loadData() async {
    final Uint8List markIcons =
        await getImages("assets/images/MapPin.png", 100);

    _markers.add(
      Marker(
        markerId: MarkerId(startLocation.toString()),
        icon: BitmapDescriptor.fromBytes(markIcons),
        position: newlatlang,
        infoWindow: InfoWindow(),
      ),
    );
    setState(() {});
  }

  late ColorNotifire notifire;
  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              zoomGesturesEnabled: true,
              initialCameraPosition: CameraPosition(
                target: startLocation,
                zoom: 14.0,
              ),
              markers: Set<Marker>.of(_markers),
              myLocationEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: true,
              zoomControlsEnabled: true,
              mapType: MapType.normal,
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },
            ),
            Positioned(
              top: 10,
              child: InkWell(
                onTap: () async {
                  var place = await hoc.PlacesAutocomplete.show(
                      context: context,
                      apiKey: googleApikey,
                      mode: hoc.Mode.overlay,
                      types: [],
                      resultTextStyle: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                        color: notifire.getwhiteblackcolor,
                      ),
                      strictbounds: false,
                      backArrowIcon: Icon(Icons.arrow_back),
                      onError: (err) {
                        print(err);
                      });
                  if (place != null) {
                    setState(() {
                      location = place.description.toString();
                      homePageController.getChangeLocation(location);
                    });

                    final plist = maps.GoogleMapsPlaces(
                      apiKey: googleApikey,
                      apiHeaders: await GoogleApiHeaders().getHeaders(),
                    );
                    String placeid = place.placeId ?? "0";
                    final detail = await plist.getDetailsByPlaceId(placeid);
                    final geometry = detail.result.geometry!;
                    final lat = geometry.location.lat;
                    final lang = geometry.location.lng;
                    newlatlang = LatLng(lat, lang);

                    mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: newlatlang, zoom: 17),
                      ),
                    );
                    setState(() {});
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(0),
                      width: MediaQuery.of(context).size.width - 40,
                      child: ListTile(
                        leading: Icon(Icons.location_on, color: blueColor),
                        title: Text(
                          location,
                          style: TextStyle(fontSize: 18),
                        ),
                        trailing: Icon(Icons.search),
                        dense: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
