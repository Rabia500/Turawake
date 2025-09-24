import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  LatLng? _destination;
  String? _currentAddress;
  String? _destinationAddress;
  final TextEditingController _searchController = TextEditingController();
  List<LatLng> _routePoints = [];
  double? _distanceInKm;

  // 🎯 Your OpenRouteService API Key
  static const String orsApiKey =
      "5b3ce3597851110001cf62485e47a2ed31b84a84a762d204b548e14e";

  static const Color primaryColor = Color(0xFF1E2A78); // Deep blue
  static const Color accentColor = Color(0xFFA4C639); // Lime green

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng userLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentLocation = userLocation;
      _routePoints.clear();
    });

    _mapController.move(userLocation, 15.0);
    _getAddressFromLatLng(userLocation, isDestination: false);
  }

  Future<void> _getAddressFromLatLng(LatLng latLng,
      {required bool isDestination}) async {
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=${latLng.latitude}&lon=${latLng.longitude}");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        if (isDestination) {
          _destinationAddress = data["display_name"];
        } else {
          _currentAddress = data["display_name"];
        }
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    final url =
        Uri.parse("https://nominatim.openstreetmap.org/search?format=json&q=$query");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List results = json.decode(response.body);
      if (results.isNotEmpty) {
        double lat = double.parse(results[0]["lat"]);
        double lon = double.parse(results[0]["lon"]);

        LatLng destination = LatLng(lat, lon);

        setState(() {
          _destination = destination;
          _destinationAddress = results[0]["display_name"];
        });

        _mapController.move(destination, 15.0);
        _getRoute();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No results found")),
        );
      }
    }
  }

  Future<void> _getRoute() async {
    if (_currentLocation == null || _destination == null) return;

    final url =
        "https://api.openrouteservice.org/v2/directions/driving-car?api_key=$orsApiKey&start=${_currentLocation!.longitude},${_currentLocation!.latitude}&end=${_destination!.longitude},${_destination!.latitude}";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // ✅ Correct path for ORS response
      final List<dynamic> coordinates =
          data["features"][0]["geometry"]["coordinates"];
      double distance = data["features"][0]["properties"]["summary"]["distance"] / 1000;

      setState(() {
        _routePoints = coordinates
            .map((coord) => LatLng(coord[1], coord[0]))
            .toList();
        _distanceInKm = distance;
      });
    } else {
      print("Failed to fetch route: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TruAwake: Set Destination"),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search destination...",
                filled: true,
                fillColor: Colors.grey[200],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: accentColor),
                  onPressed: () => _searchLocation(_searchController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📍 Current + Destination + Distance
          if (_currentAddress != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.my_location, color: primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Your Location: $_currentAddress",
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          if (_destinationAddress != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.location_pin, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Destination: $_destinationAddress",
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          if (_distanceInKm != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.directions, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    "Distance: ${_distanceInKm!.toStringAsFixed(2)} km",
                    style: TextStyle(fontSize: 14, color: Colors.green[700]),
                  ),
                ],
              ),
            ),

          // 🗺 Map view
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLocation ?? LatLng(33.6844, 73.0479),
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      if (_currentLocation != null)
                        Marker(
                          point: _currentLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.my_location,
                              color: primaryColor, size: 40),
                        ),
                      if (_destination != null)
                        Marker(
                          point: _destination!,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_pin,
                              color: Colors.red, size: 40),
                        ),
                    ],
                  ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          color: accentColor,
                          strokeWidth: 5.0,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // 📡 Find My Location button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.gps_fixed),
              label: const Text("Find My Location"),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
