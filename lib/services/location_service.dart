import 'package:flutter/material.dart';
import 'location_service.dart';  // assuming this is your LocationService file

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _locationMessage = 'Press the button to get location';

  final LocationService _locationService = LocationService();

  Future<void> _getLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _locationMessage = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
      });
    } else {
      setState(() {
        _locationMessage = 'Could not get location. Make sure permissions are granted.';
      });
    }
  }

  static const Color primaryColor = Color(0xFF1E2A78); // TruAwake Blue
  static const Color accentColor = Color(0xFFA4C639);  // TruAwake Green

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _locationMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: primaryColor),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _getLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationService {
  getCurrentLocation() {}
}
