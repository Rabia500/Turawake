import 'package:flutter/material.dart';
import 'package:Truawake/userdashboard/camera_activation.dart'; // Make sure this path is correct

class CameraSettingsScreen extends StatefulWidget {
  const CameraSettingsScreen({super.key});

  @override
  _CameraSettingsScreenState createState() => _CameraSettingsScreenState();
}

class _CameraSettingsScreenState extends State<CameraSettingsScreen> {
  String _selectedResolution = "High";
  bool _isAudioEnabled = true;
  bool _isFrontCamera = true;
  bool _isDetectionStarted = false;

  final Color primaryColor = const Color(0xFF1E2A78);
  final Color accentColor = const Color(0xFFA4C639);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera Settings"),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1F3A), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text("Resolution", style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      _selectedResolution,
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                    trailing: DropdownButton<String>(
                      dropdownColor: Colors.grey[900],
                      value: _selectedResolution,
                      iconEnabledColor: accentColor,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedResolution = newValue!;
                        });
                      },
                      items: <String>["Low", "Medium", "High"]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                    ),
                  ),
                  Divider(color: accentColor),

                  SwitchListTile(
                    title: Text("Enable Audio Recording", style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      _isAudioEnabled ? "On" : "Off",
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                    value: _isAudioEnabled,
                    activeThumbColor: accentColor,
                    onChanged: (bool value) {
                      setState(() {
                        _isAudioEnabled = value;
                      });
                    },
                  ),
                  Divider(color: accentColor),

                  SwitchListTile(
                    title: Text("Use Front Camera", style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      _isFrontCamera ? "Front Camera" : "Back Camera",
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                    value: _isFrontCamera,
                    activeThumbColor: accentColor,
                    onChanged: (bool value) {
                      setState(() {
                        _isFrontCamera = value;
                      });
                    },
                  ),
                  Divider(color: accentColor),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isDetectionStarted = !_isDetectionStarted;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isDetectionStarted
                          ? 'Detection started!'
                          : 'Detection stopped.'),
                      backgroundColor: accentColor,
                    ),
                  );

                  if (_isDetectionStarted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(
                          isFrontCamera: _isFrontCamera,
                          resolution: _selectedResolution,
                          isAudioEnabled: _isAudioEnabled,
                        ),
                      ),
                    );
                  }
                },
                icon: Icon(_isDetectionStarted ? Icons.pause : Icons.play_arrow),
                label: Text(
                  _isDetectionStarted ? 'Stop Detection' : 'Start Detection',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
