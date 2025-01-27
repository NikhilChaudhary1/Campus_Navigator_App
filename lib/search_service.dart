// import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'custom_locations.dart';

class SearchService {
  // This function combines both local search and external web search
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    // First, check in the custom locations
    List<CustomLocation> localResults =
        LocationRepository.searchLocations(query);

    // If we found results locally, return them
    if (localResults.isNotEmpty) {
      return localResults.map((location) {
        return {
          'name': location.name,
          'lat': location.coordinates.latitude,
          'lon': location.coordinates.longitude,
        };
      }).toList();
    } else {
      // final String url =
      //     'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&accept-language=en';
      // final response = await http.get(Uri.parse(url));

      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   return data.isNotEmpty ? List<Map<String, dynamic>>.from(data) : [];
      // } else {
        throw Exception('Failed to search places');
      }
    // }
  }
}
