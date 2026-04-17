// ignore_for_file: prefer_const_constructors, avoid_print, prefer_interpolation_to_compose_strings, unused_field

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/screen/home_screen.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as osm;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  HomePageController homePageController = Get.find();

  final MapController mapController = MapController();
  final osm.LatLng startLocation = osm.LatLng(lat, long);
  String location = "Search Location".tr;

  osm.LatLng? newLatLng;

  @override
  void initState() {
    super.initState();
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
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

  Future<List<_NominatimPlace>> _searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeQueryComponent(query)}&format=jsonv2&limit=8',
    );

    final res = await http.get(
      uri,
      headers: const {
        'User-Agent': 'caresoko-app/1.0',
        'Accept-Language': 'en',
      },
    );

    if (res.statusCode != 200) return [];
    final List data = jsonDecode(res.body) as List;
    return data
        .map((e) => _NominatimPlace.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.lat != null && e.lng != null)
        .toList();
  }

  Future<void> _openSearchDialog() async {
    final controller = TextEditingController();
    List<_NominatimPlace> results = [];

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return AlertDialog(
              title: Text('Search Location'.tr),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Type address, city, zipcode'.tr,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            final r = await _searchPlaces(controller.text);
                            setLocalState(() => results = r);
                          },
                        ),
                      ),
                      onSubmitted: (_) async {
                        final r = await _searchPlaces(controller.text);
                        setLocalState(() => results = r);
                      },
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final item = results[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.location_on),
                            title: Text(item.displayName, maxLines: 2, overflow: TextOverflow.ellipsis),
                            onTap: () {
                              Navigator.pop(ctx, item);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((selected) {
      if (selected is _NominatimPlace && selected.lat != null && selected.lng != null) {
        final picked = osm.LatLng(selected.lat!, selected.lng!);
        setState(() {
          newLatLng = picked;
          location = selected.displayName;
        });
        homePageController.getChangeLocation(location);
        mapController.move(picked, 16);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    final markerPosition = newLatLng ?? startLocation;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: startLocation,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.caresoko.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: markerPosition,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 34),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 10,
              child: InkWell(
                onTap: _openSearchDialog,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

class _NominatimPlace {
  _NominatimPlace({required this.displayName, required this.lat, required this.lng});

  final String displayName;
  final double? lat;
  final double? lng;

  factory _NominatimPlace.fromJson(Map<String, dynamic> json) {
    return _NominatimPlace(
      displayName: (json['display_name'] ?? '').toString(),
      lat: double.tryParse((json['lat'] ?? '').toString()),
      lng: double.tryParse((json['lon'] ?? '').toString()),
    );
  }
}
