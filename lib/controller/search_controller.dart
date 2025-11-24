// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, prefer_if_null_operators

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/homesearchmodel.dart';
import 'package:gotocarefinder/model/search_info.dart';
import 'package:http/http.dart' as http;

class SearchPropertyController extends GetxController implements GetxService {
  TextEditingController search = TextEditingController();

  List<SearchInfo> searchData = []; // Keep for backward compatibility or "All" tab
  List<SearchInfo> homes = [];
  List<SearchInfo> advertisedProperties = [];
  List<SearchInfo> agencies = [];
  bool isLoading = false;

  String searchText = "";

  changeValueUpdate(String value) {
    searchText = value;
    update();
  }

  HomesearchModel? homesearchData;
  Future getSearchData({String? countryId}) async {
    try {
      Map map = {
        "keyword": search.text,
        "uid": getData.read("UserLogin")["id"].toString(),
        "country_id": countryId,
      };
      Uri uri = Uri.parse(Config.path + Config.searchApi);
      print("uri {$uri}");

      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("response::::::::::::::::: {${response.body}}");

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result);
        homesearchData = homesearchModelFromJson(response.body);
        
        searchData = [];
        homes = [];
        advertisedProperties = [];
        agencies = [];

        // Populate lists
        if (homesearchData?.homes != null) {
          for (var element in homesearchData!.homes!) {
             // Convert SearchPropety to SearchInfo if needed, or just use SearchPropety in UI
             // SearchInfo seems to be a separate model. Let's check SearchInfo.fromJson
             // Assuming SearchInfo is compatible or we should use SearchPropety directly.
             // The original code used SearchInfo.fromJson(element) where element was raw JSON map.
             // But here we have parsed objects.
             // Let's use the raw JSON from result["homes"] etc.
          }
        }
        
        if (result["homes"] != null) {
          for (var element in result["homes"]) {
            // Normalize field names: pricing → price
            var normalized = Map<String, dynamic>.from(element);
            normalized['id'] = element['id'].toString();
            normalized['name'] = element['name'] ?? '';
            normalized['price'] = element['pricing']?.toString() ?? '';
            normalized['capacity'] = element['capacity']?.toString() ?? '';
            normalized['city'] = element['city'] ?? '';
            normalized['image'] = element['image'] ?? '';
            normalized['property_type'] = element['property_type']?.toString() ?? '';
            normalized['property_type_title'] = element['property_type_title'] ?? '';
            normalized['rate'] = element['rate']?.toString() ?? '0';
            normalized['IS_FAVOURITE'] = element['IS_FAVOURITE'] ?? 0;
            homes.add(SearchInfo.fromJson(normalized));
          }
        }
        if (result["advertised_properties"] != null) {
          for (var element in result["advertised_properties"]) {
            // Normalize field names: title → name, beds → capacity
            var normalized = Map<String, dynamic>.from(element);
            normalized['id'] = element['id'].toString();
            normalized['name'] = element['title'] ?? '';
            normalized['capacity'] = element['beds']?.toString() ?? '';
            normalized['price'] = element['price']?.toString() ?? '';
            normalized['city'] = element['city'] ?? '';
            normalized['image'] = element['image'] ?? '';
            normalized['property_type'] = element['property_type']?.toString() ?? '';
            normalized['property_type_title'] = element['property_type_title'] ?? '';
            normalized['rate'] = element['rate']?.toString() ?? '0';
            normalized['IS_FAVOURITE'] = element['IS_FAVOURITE'] ?? 0;
            advertisedProperties.add(SearchInfo.fromJson(normalized));
          }
        }
        if (result["agencies"] != null) {
          for (var element in result["agencies"]) {
            // Normalize field names: pricing → price, add default capacity
            var normalized = Map<String, dynamic>.from(element);
            normalized['id'] = element['id'].toString();
            normalized['name'] = element['name'] ?? '';
            normalized['price'] = element['pricing']?.toString() ?? '';
            normalized['capacity'] = ''; // Agencies don't have capacity
            normalized['city'] = element['city'] ?? '';
            normalized['image'] = element['image'] ?? '';
            normalized['property_type'] = element['property_type']?.toString() ?? '';
            normalized['property_type_title'] = element['property_type_title'] ?? '';
            normalized['rate'] = element['rate']?.toString() ?? '0';
            normalized['IS_FAVOURITE'] = element['IS_FAVOURITE'] ?? 0;
            agencies.add(SearchInfo.fromJson(normalized));
          }
        }
        
        // For backward compatibility, populate searchData with homes
        if (result["search_propety"] != null) {
             for (var element in result["search_propety"]) {
              var normalized = Map<String, dynamic>.from(element);
              normalized['id'] = element['id'].toString();
              normalized['name'] = element['name'] ?? '';
              normalized['price'] = element['pricing']?.toString() ?? '';
              normalized['capacity'] = element['capacity']?.toString() ?? '';
              normalized['city'] = element['city'] ?? '';
              normalized['image'] = element['image'] ?? '';
              normalized['property_type'] = element['property_type']?.toString() ?? '';
              normalized['property_type_title'] = element['property_type_title'] ?? '';
              normalized['rate'] = element['rate']?.toString() ?? '0';
              normalized['IS_FAVOURITE'] = element['IS_FAVOURITE'] ?? 0;
              searchData.add(SearchInfo.fromJson(normalized));
            }
        }
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
