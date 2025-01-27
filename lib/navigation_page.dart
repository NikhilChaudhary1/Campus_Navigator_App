import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_project/routes.dart';

class NavigationPage extends StatefulWidget {
  final LatLng startLocation;
  final LatLng endLocation;
  final String method;

  const NavigationPage({
    required this.startLocation,
    required this.endLocation,
    required this.method,
    super.key,
  });

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final MapController _mapController = MapController();
  late RouteService _routeService;
  List<LatLng> _route = [];
  String _distance = '';
  String _duration = '';
  bool _isLoading = true;
  late Marker _userLocationMarker;
  late Marker _destinationMarker;

  @override
  void initState() {
    super.initState();
    _userLocationMarker = Marker(
      point: widget.startLocation,
      child: const Icon(
        Icons.person_pin_circle,
        size: 40,
        // color: Colors.green,
      ),
    );
    _destinationMarker = Marker(
      point: widget.endLocation,
      child: const Icon(
        Icons.location_on,
        size: 40,
        color: Colors.red,
      ),
    );
    _routeService = RouteService();
    _calculateRoute();
  }

  Future<void> _calculateRoute() async {
    String method;
    switch (widget.method.toLowerCase()) {
      case 'walking':
        method = 'foot-walking';
        break;
      case 'bicycle':
        method = 'cycling-regular';
        break;
      case 'bus':
        method = 'driving-hgv';
        break;
      default:
        method = 'driving-car';
    }

    // Calculate the route using the RouteService
    final routeDetails = await _routeService.getRoute(
      widget.startLocation,
      widget.endLocation,
      method,
    );

    final distance = routeDetails['distance'] / 1000;
    final duration = routeDetails['duration'] / 60;

    setState(() {
      _route = routeDetails['coordinates'];
      _distance = '${distance.toStringAsFixed(2)} km';
      _duration = '${duration.toStringAsFixed(0)} mins';
      _isLoading = false;
    });

    // Move the map to start location after route is calculated
    _mapController.move(widget.startLocation, 18.0);
  }

  IconData _getNavigationModeIcon() {
    switch (widget.method) {
      case 'walking':
        return Icons.directions_walk;
      case 'bicycle':
        return Icons.directions_bike;
      case 'bus':
        return Icons.directions_bus;
      default:
        return Icons.directions_car;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, 'back');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Navigation'),
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: widget.startLocation,
                    initialZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _route,
                          strokeWidth: 10.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        _userLocationMarker,
                        _destinationMarker,
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 15,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context, 'back');
                          },
                          icon: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 32,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _duration,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const Divider(
                                color: Colors.black26,
                                height: 2,
                                indent: 80,
                                endIndent: 80,
                              ),
                              Text(
                                _distance,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            _getNavigationModeIcon(),
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
