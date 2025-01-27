import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:maps_project/navigation_page.dart';
import 'package:maps_project/search_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  late LatLng _currentCenter;
  double _zoomLevel = 18.0;
  late Marker _userLocationMarker;
  late LatLng _newCenter;

  LatLng? _selectedPosition;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];

  bool _isSearching = false;
  bool _isLoading = false;
  // List<Polyline> _polylines = [];

  // Instantiate services
  // final RouteService _routeService = RouteService();
  final SearchService _searchService = SearchService();

  bool _buildRoute = false;

  // Route details
  // String _distance = '';
  // String _duration = '';
  String _selectedRouteMethod = 'Car';

  @override
  void initState() {
    super.initState();
    _currentCenter = const LatLng(30.267604, 77.995080);
    _newCenter = _currentCenter;
    _userLocationMarker = Marker(
      point: _currentCenter,
      child: const Icon(
        Icons.person_pin_circle_sharp,
        size: 40.0,
        color: Colors.blue,
      ),
    );
    _getUserLocation();
    _searchController.addListener(() {
      _searchPlaces(_searchController.text);
    });
  }

  // Get the user's current location
  Future<void> _getUserLocation() async {
    setState(() {
      _isLoading = true;
    });

    LocationPermission permission = await _checkPermissions();
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission is denied.")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _currentCenter = LatLng(position.latitude, position.longitude);
      _newCenter = _currentCenter;
      _zoomLevel = 18.0;
      _userLocationMarker = Marker(
        point: _currentCenter,
        child: const Icon(
          Icons.person_pin_circle_sharp,
          size: 40.0,
          color: Colors.blue,
        ),
      );
      _isLoading = false;
    });

    _mapController.move(_currentCenter, _zoomLevel);
  }

  // Check location permissions
  Future<LocationPermission> _checkPermissions() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      return LocationPermission.whileInUse;
    } else if (status.isDenied) {
      return LocationPermission.denied;
    } else {
      return LocationPermission.deniedForever;
    }
  }

  // Search for places (local and then web)
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      final results = await _searchService.searchPlaces(query);

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error searching places")),
      );
    }
  }

  // Move map to selected position and clear search
  void _moveToLocation(double lat, double lon) {
    setState(() {
      _selectedPosition = LatLng(lat, lon);
      _searchResults = [];
      _isSearching = false;
      _searchController.clear();
    });
    _mapController.move(_selectedPosition!, _zoomLevel);
  }

  Widget _buildRouteButtons() {
    if (_selectedPosition == null) {
      return SizedBox.shrink();
    }
    _buildRoute = true;
    return Positioned(
      bottom: 20,
      left: 15,
      right: 15,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _routeMethodButton(Icons.directions_car, 'Car'),
                _routeMethodButton(Icons.directions_walk, 'Walking'),
                _routeMethodButton(Icons.directions_bike, 'Bicycle'),
                _routeMethodButton(Icons.directions_bus, 'Bus'),
              ],
            ),
            const SizedBox(height: 10),
            // "Get Directions" Button
            FloatingActionButton.extended(
              onPressed: () async {
                // setState(() {
                //   _isLoading = true;
                // });

                // try {
                //   String method;
                //   switch (_selectedRouteMethod.toLowerCase()) {
                //     case 'walking':
                //       method = 'foot-walking';
                //       break;
                //     case 'bicycle':
                //       method = 'cycling-regular';
                //       break;
                //     case 'bus':
                //       method = 'driving-hgv';
                //       break;
                //     default:
                //       method = 'driving-car';
                //   }

                //   final routeDetails = await _routeService.getRoute(
                //     _currentCenter,
                //     _selectedPosition!,
                //     method,
                //   );

                //   final distance = routeDetails['distance'] / 1000;
                //   final duration = routeDetails['duration'] / 60;

                //   setState(() {
                //     _isLoading = false;
                //     _polylines = [
                //       _routeService.getPolyline(routeDetails['coordinates'])
                //     ];
                //     _distance = '${distance.toStringAsFixed(2)} km';
                //     _duration = '${duration.toStringAsFixed(0)} mins';
                //   });

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NavigationPage(
                      startLocation: _currentCenter,
                      endLocation: _selectedPosition!,
                      method: _selectedRouteMethod.toLowerCase(),
                    ),
                  ),
                );
                if (result == 'back') {
                  setState(() {
                    // _polylines = [];
                    _selectedPosition = null;
                    _buildRoute = false;
                  });
                }
                // } catch (e) {
                //   setState(() {
                //     _isLoading = false;
                //   });
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(content: Text("Failed to fetch directions")),
                //   );
                // }
              },
              backgroundColor: Colors.blue,
              label: Row(
                children: const [
                  Icon(Icons.directions, color: Colors.white),
                  SizedBox(width: 5),
                  Text('Get Directions', style: TextStyle(color: Colors.white)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

// Helper for route buttons
  Widget _routeMethodButton(IconData icon, String method) {
    final isSelected = _selectedRouteMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRouteMethod = method;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.blue : Colors.black),
          const SizedBox(height: 4),
          Text(
            method,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Zoom In functionality
  void _zoomIn() {
    if (_zoomLevel < 20.0) {
      setState(() {
        _zoomLevel += 1;
      });
      _mapController.move(_newCenter, _zoomLevel);
    }
  }

  // Zoom Out functionality
  void _zoomOut() {
    if (_zoomLevel > 3.0) {
      setState(() {
        _zoomLevel -= 1;
      });
      _mapController.move(_newCenter, _zoomLevel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Campus Navigator')),
        backgroundColor: Colors.greenAccent,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: _zoomLevel,
              onPositionChanged: (position, hasGesture) {
                setState(() {
                  _newCenter = position.center;
                  _zoomLevel = position.zoom;
                });
              },
            ),
            children: [
              mapTile,
              MarkerLayer(
                markers: [
                  _userLocationMarker,
                  if (_selectedPosition != null)
                    Marker(
                      point: _selectedPosition!,
                      width: 40.0,
                      height: 40.0,
                      child: const Icon(
                        Icons.location_on,
                        size: 40.0,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
              // PolylineLayer(
              //   polylines: _polylines,
              // ),
            ],
          ),

          // Search bar
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Column(
              children: [
                SizedBox(
                    height: 55.0,
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(30, 0, 0, 0),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ]),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                            hintText: 'Search places',
                            filled: true,
                            fillColor: Colors.white,
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _isSearching
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _isSearching = false;
                                        _searchResults = [];
                                      });
                                    },
                                    icon: const Icon(Icons.clear))
                                : null),
                        onTap: () {
                          setState(() {
                            _isSearching = true;
                          });
                        },
                      ),
                    )),
                if (_isSearching && _searchResults.isNotEmpty)
                  Container(
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final place = _searchResults[index];
                        return ListTile(
                          title: Text(place['name']),
                          onTap: () {
                            _moveToLocation(
                              place['lat'],
                              place['lon'],
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              ),
            ),

          _buildRouteButtons(),
        ],
      ),
      floatingActionButton: _buildRoute == false
          ? Stack(
              children: <Widget>[
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        onPressed: _zoomIn,
                        mini: true,
                        backgroundColor:
                            const Color.fromARGB(255, 230, 230, 230),
                        child: const Icon(Icons.add),
                      ),
                      FloatingActionButton(
                        onPressed: _zoomOut,
                        mini: true,
                        backgroundColor:
                            const Color.fromARGB(255, 230, 230, 230),
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 100,
                  right: 0,
                  child: FloatingActionButton(
                    onPressed: _getUserLocation,
                    mini: true,
                    backgroundColor: Colors.greenAccent,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  TileLayer get mapTile => TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      );
}
