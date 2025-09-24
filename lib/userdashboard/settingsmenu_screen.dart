import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Truawake/appsettings/Privacy_terms_screen.dart';
import 'package:Truawake/appsettings/Q_A_screen.dart';
import 'package:Truawake/appsettings/breakreminder_screen.dart';
import 'package:Truawake/appsettings/camerasetting_screen.dart';
import 'package:Truawake/appsettings/language_region.dart';
import 'package:Truawake/appsettings/notificationsettings_screen.dart';
import 'package:Truawake/appsettings/update_vehicle.dart';
import 'package:Truawake/appsettings/updateprofile_screen.dart';
import 'package:Truawake/theme/settings_screen.dart';
import 'package:Truawake/appsettings/time_date_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<QueryDocumentSnapshot> _vehicles = [];

  final List<Map<String, dynamic>> settingsOptions = [
    {'title': 'Camera Settings', 'icon': Icons.camera_alt},
    {'title': 'Notification Settings', 'icon': Icons.notifications},
    {'title': 'Update Profile', 'icon': Icons.person},
    {'title': 'Update Vehicle', 'icon': Icons.car_repair},
    {'title': 'Themes & UI Customization', 'icon': Icons.color_lens},
    {'title': 'Language and Region', 'icon': Icons.language},
    {'title': 'Set Date & Time', 'icon': Icons.access_time},
    {'title': 'Break Reminder', 'icon': Icons.timer},
    {'title': 'Privacy Policy & Terms', 'icon': Icons.privacy_tip},
    {'title': 'Q&A', 'icon': Icons.question_answer},
  ];

  Future<void> _fetchVehiclesByUID() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('userId', isEqualTo: user.uid)
          .get();

      _vehicles = snapshot.docs;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching vehicles: $e')),
      );
    }
  }

  void _onUpdateVehicleTap() async {
    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF39FF14)),
        ),
      ),
    );

    // Fetch vehicles
    await _fetchVehiclesByUID();

    // Close loading spinner
    Navigator.pop(context);

    // If no vehicles found
    if (_vehicles.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Vehicles Found'),
          content: const Text('No vehicles registered to your account. Please add one first.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    // Show vehicle selector
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Vehicle to Update'),
          children: _vehicles.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final vehicleNumber = data['vehicleNumber'] ?? 'Unknown';

            return SimpleDialogOption(
              child: Text(vehicleNumber),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateVehicleScreen(
                      vehicleId: doc.id,
                      vehicleData: data,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _navigateToScreen(String title) {
    switch (title) {
      case 'Camera Settings':
        Navigator.push(context, MaterialPageRoute(builder: (_) => CameraSettingsScreen()));
        break;
      case 'Notification Settings':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()));
        break;
      case 'Update Profile':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateProfileScreen()));
        break;
      case 'Update Vehicle':
        _onUpdateVehicleTap();
        break;
      case 'Themes & UI Customization':
        Navigator.push(context, MaterialPageRoute(builder: (_) => ThemeScreen()));
        break;
      case 'Language and Region':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageRegionScreen()));
        break;
      case 'Set Date & Time':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DateTimeSettingsScreen()));
        break;
      case 'Break Reminder':
        Navigator.push(context, MaterialPageRoute(builder: (_) => BreakReminderScreen()));
        break;
      case 'Privacy Policy & Terms':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyAndTermsScreen()));
        break;
      case 'Q&A':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const QnAScreen()));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screen not implemented yet')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 5,
      ),
      backgroundColor: const Color(0xFF121212),
      body: ListView.builder(
        itemCount: settingsOptions.length,
        itemBuilder: (context, index) {
          final option = settingsOptions[index];
          return Card(
            color: const Color(0xFF1E1E1E),
            shadowColor: Colors.black,
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Icon(option['icon'], color: const Color(0xFF39FF14), size: 28),
              title: Text(
                option['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white70),
              onTap: () => _navigateToScreen(option['title']),
            ),
          );
        },
      ),
    );
  }
}
