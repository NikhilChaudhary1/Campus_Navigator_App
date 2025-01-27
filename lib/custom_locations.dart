import 'package:latlong2/latlong.dart';

class CustomLocation {
  final String name;
  final LatLng coordinates;

  CustomLocation({required this.name, required this.coordinates});
}

class LocationRepository {
  // List of predefined locations
  static final List<CustomLocation> locations = [
    ..._generateLocations(
      baseName: "LT",
      numbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
      coordinates: LatLng(30.268812, 77.993483),
    ),
    ..._generateLocations(
      baseName: "LT",
      numbers: [12, 13, 14, 15, 16, 17, 18],
      coordinates: LatLng(30.267604, 77.995080),
    ),
    ..._generateLocations(
      baseName: "CR",
      numbers: [01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14],
      coordinates: LatLng(30.268812, 77.993483),
    ),
    ..._generateLocations(
      baseName: "CR",
      numbers: [15, 16, 17, 18, 19],
      coordinates: LatLng(30.267604, 77.995080),
    ),
    ..._generateLocations(
      baseName: "CR",
      numbers: [20, 21, 22, 23],
      coordinates: LatLng(30.266885, 77.995319),
    ),
    CustomLocation(
      name: "GEU Main Block",
      coordinates: LatLng(30.267604, 77.995080),
    ),
    CustomLocation(
      name: "CSIT Block",
      coordinates: LatLng(30.268812, 77.993483),
    ),
    CustomLocation(
      name: "Civil Block",
      coordinates: LatLng(30.266885, 77.995319),
    ),
    CustomLocation(
      name: "Param Lab",
      coordinates: LatLng(30.26749603763097, 77.99598426779154),
    ),
    CustomLocation(
      name: "Aryabhatt Lab",
      coordinates: LatLng(30.267639289753316, 77.9956165541746),
    ),
    CustomLocation(
      name: "Santosh Anand Library",
      coordinates: LatLng(30.26743792586152, 77.99574016854308),
    ),
  ];

  // Function to generate a list of CustomLocation for classrooms or LTs
  static List<CustomLocation> _generateLocations({
    required String baseName,
    required List<int> numbers,
    required LatLng coordinates,
  }) {
    return numbers
        .map((number) => CustomLocation(
      name: "$baseName-$number",
      coordinates: coordinates,
    ))
        .toList();
  }

  // Function to search for a place in the predefined list
  static List<CustomLocation> searchLocations(String query) {
    return locations
        .where((location) =>
        location.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
