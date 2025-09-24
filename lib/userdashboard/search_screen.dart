import 'package:flutter/material.dart';
import 'package:Truawake/userdashboard/myprofile_screen.dart';
import 'package:Truawake/userdashboard/register_vehicle.dart';
import 'package:Truawake/userdashboard/setalarm_screen.dart';
import 'package:Truawake/userdashboard/settingsmenu_screen.dart';
import 'package:Truawake/userdashboard/verify_licence.dart';
import 'package:Truawake/userdashboard/activities_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> allItems = [
    {'title': 'My Profile', 'screen': MyProfileScreen()},
    {'title': 'Settings', 'screen': SettingsScreen()},
    {'title': 'Register Vehicle', 'screen': VehicleScreen()},
    {'title': 'Verify Licence', 'screen': LicenseVerificationScreen()},
    {'title': 'Set Alarm', 'screen': AlarmMenuScreen()},
    {'title': 'Weather Forecast', 'screen': null}, // No screen yet
    {'title': 'Set Location', 'screen': null}, // No screen yet
    {'title': 'Activities', 'screen': ActivitiesMenuScreen()},
    {'title': 'Drowsiness Detection History', 'screen': null}, // Data-based navigation needed
    {'title': 'Recorded Videos', 'screen': null}, // Data-based navigation needed
    {'title': 'Recorded Photos', 'screen': null}, // Data-based navigation needed
  ];

  List<Map<String, dynamic>> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = allItems;
  }

  void _search(String query) {
    setState(() {
      filteredItems = allItems
          .where((item) =>
              item['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background to black
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _search,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white70), // Dimmed white hint text
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white), // White input text
          cursorColor: Color(0xFF39FF14), // Neon Green cursor
        ),
        backgroundColor: Color(0xFF00796B), // Deep Teal for the AppBar
        foregroundColor: Colors.white, // White text/icons for AppBar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004D40), Color(0xFF00796B)], // Teal gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.black.withOpacity(0.7), // Semi-transparent black background for the cards
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners for the card
              ),
              elevation: 8, // Elevation for a floating effect
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  filteredItems[index]['title'],
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Bold white text
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF39FF14), // Neon Green arrow
                ),
                onTap: () {
                  if (filteredItems[index]['screen'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => filteredItems[index]['screen']),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${filteredItems[index]['title']} screen not available yet!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.black,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
