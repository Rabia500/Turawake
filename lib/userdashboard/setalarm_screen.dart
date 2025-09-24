import 'package:flutter/material.dart';

class AlarmMenuScreen extends StatefulWidget {
  const AlarmMenuScreen({super.key});

  @override
  _AlarmMenuScreenState createState() => _AlarmMenuScreenState();
}

class _AlarmMenuScreenState extends State<AlarmMenuScreen> {
  String _selectedTone = "Default Tone";
  bool _isVibrationOn = false;
  double _alarmVolume = 0.5;
  int _alarmDuration = 3; // in minutes
  int _preAlarmNotification = 5; // default pre-alarm notification time in minutes

  final List<String> _tones = ["Default Tone", "Morning Bell", "Birds Chirping"];
  final List<int> _durations = [1, 3, 5, 10];
  final List<int> _preAlarmOptions = [5, 10, 15, 20]; // Pre-alarm notification options in minutes

  // Alarm Tone
  void _showToneSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black, // Black modal background
      builder: (context) {
        return ListView(
          children: _tones.map((tone) {
            return ListTile(
              title: Text(tone, style: const TextStyle(color: Colors.white)), // White text
              onTap: () {
                setState(() {
                  _selectedTone = tone;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background
      appBar: AppBar(
        title: const Text("Alarm Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E), // Dark Indigo for app bar
        iconTheme: const IconThemeData(color: Colors.white), // White back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Pre-Alarm Notification
            ListTile(
              title: const Text("Pre-Alarm Notification", style: TextStyle(color: Colors.white)),
              subtitle: Text("$_preAlarmNotification minutes before", style: const TextStyle(color: Colors.white70)),
              trailing: DropdownButton<int>(
                dropdownColor: Colors.black, // Black dropdown
                value: _preAlarmNotification,
                onChanged: (int? value) {
                  setState(() {
                    _preAlarmNotification = value!;
                  });
                },
                items: _preAlarmOptions.map((time) {
                  return DropdownMenuItem<int>(
                    value: time,
                    child: Text("$time minutes", style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
            ),
            const Divider(color: Color(0xFF1A237E)), // Dark Indigo divider

            // Alarm Tone
            ListTile(
              title: const Text("Alarm Tone", style: TextStyle(color: Colors.white)),
              subtitle: Text(_selectedTone, style: const TextStyle(color: Colors.white70)),
              trailing: const Icon(Icons.music_note, color: Color(0xFF1A237E)), // Dark Indigo icon
              onTap: _showToneSelection,
            ),
            const Divider(color: Color(0xFF1A237E)),

            // Vibration
            SwitchListTile(
              title: const Text("Vibration", style: TextStyle(color: Colors.white)),
              value: _isVibrationOn,
              activeThumbColor: const Color(0xFF1A237E), // Dark Indigo switch
              onChanged: (bool value) {
                setState(() {
                  _isVibrationOn = value;
                });
              },
            ),
            const Divider(color: Color(0xFF1A237E)),

            // Alarm Volume
            ListTile(
              title: const Text("Alarm Volume", style: TextStyle(color: Colors.white)),
              subtitle: Slider(
                value: _alarmVolume,
                activeColor: const Color(0xFF1A237E), // Dark Indigo slider
                onChanged: (double value) {
                  setState(() {
                    _alarmVolume = value;
                  });
                },
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: "${(_alarmVolume * 100).toInt()}%",
              ),
            ),
            const Divider(color: Color(0xFF1A237E)),

            // Alarm Duration
            ListTile(
              title: const Text("Alarm Duration", style: TextStyle(color: Colors.white)),
              subtitle: Text("$_alarmDuration minutes", style: const TextStyle(color: Colors.white70)),
              trailing: DropdownButton<int>(
                dropdownColor: Colors.black,
                value: _alarmDuration,
                onChanged: (int? value) {
                  setState(() {
                    _alarmDuration = value!;
                  });
                },
                items: _durations.map((duration) {
                  return DropdownMenuItem<int>(
                    value: duration,
                    child: Text("$duration minutes", style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
