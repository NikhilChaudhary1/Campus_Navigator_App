import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteService {
  Future<Map<String, dynamic>> getRoute(
      LatLng from, LatLng to, String method) async {
    final String apiKey =
        '5b3ce3597851110001cf6248ea7b4bf3a5de4c598c33447e45d8a32d'; // API key
    final String url =
        'https://api.openrouteservice.org/v2/directions/$method?api_key=$apiKey&start=${from.longitude},${from.latitude}&end=${to.longitude},${to.latitude}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'coordinates': (data['features'][0]['geometry']['coordinates'] as List)
            .map((c) => LatLng(c[1], c[0]))
            .toList(),
        'distance': data['features'][0]['properties']['segments'][0]
            ['distance'],
        'duration': data['features'][0]['properties']['segments'][0]
            ['duration'],
      };
    } else {
      throw Exception('Failed to fetch route');
    }
  }

  // Function to create the polyline layer for the route
  Polyline getPolyline(List<LatLng> route) {
    return Polyline(
      points: route,
      strokeWidth: 5.0,
      color: Colors.lightBlue,
    );
  }
}
