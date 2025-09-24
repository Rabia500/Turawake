import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool isSoundEnabled = true;
  bool isVibrateEnabled = true;
  bool isPopupEnabled = true;
  bool isHighPriorityEnabled = true;
  String selectedTone = 'Default';

  final List<String> notificationTones = [
    'Default',
    'assets/soft_alarm.ogg',
    'assets/sound_of_the_sea.ogg',
    'assets/squirrel.ogg',
    'assets/stepping_stone.ogg',
    'assets/dolphin.ogg',
    'assets/argon.ogg',
    'assets/caron.ogg',
    'assets/helium.ogg',
    'assets/krypton.ogg',
    'assets/neon.ogg',
    'assets/osmium.ogg',
    'assets/oxygen.ogg',
    'assets/platinum.ogg',
    'assets/timer.ogg',
    'assets/bedside.ogg',
    'assets/coil.ogg',
    'assets/frogs.ogg',
    'assets/incoming.ogg',
    'assets/kashio.ogg',
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();

  void changeNotificationTone(String tone) async {
    setState(() {
      selectedTone = tone;
    });

    await _audioPlayer.stop(); // Stop current audio

    if (tone != 'Default') {
      try {
        await _audioPlayer.setAsset(tone);
        await _audioPlayer.play();
      } catch (e) {
        print("Error loading the audio: $e");
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF1E2A78); // Dark Blue
    final Color accentColor = const Color(0xFFA4C639); // Lime Green

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1F3A), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            SwitchListTile(
              title: const Text('Enable Conversation Tones', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Sound for incoming messages', style: TextStyle(color: Colors.grey)),
              value: isSoundEnabled,
              activeThumbColor: accentColor,
              onChanged: (value) => setState(() => isSoundEnabled = value),
            ),
            Divider(color: accentColor),

            SwitchListTile(
              title: const Text('Enable Vibration', style: TextStyle(color: Colors.white)),
              value: isVibrateEnabled,
              activeThumbColor: accentColor,
              onChanged: (value) => setState(() => isVibrateEnabled = value),
            ),
            Divider(color: accentColor),

            SwitchListTile(
              title: const Text('Show Popup Notifications', style: TextStyle(color: Colors.white)),
              value: isPopupEnabled,
              activeThumbColor: accentColor,
              onChanged: (value) => setState(() => isPopupEnabled = value),
            ),
            Divider(color: accentColor),

            SwitchListTile(
              title: const Text('Enable High Priority Notifications', style: TextStyle(color: Colors.white)),
              value: isHighPriorityEnabled,
              activeThumbColor: accentColor,
              onChanged: (value) => setState(() => isHighPriorityEnabled = value),
            ),
            Divider(color: accentColor),

            // Label above dropdown on its own line
            const Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                'Select Notification Tone',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),

            DropdownButton<String>(
              isExpanded: true,
              dropdownColor: Colors.grey[900],
              value: selectedTone,
              iconEnabledColor: accentColor,
              onChanged: (String? newTone) {
                if (newTone != null) {
                  changeNotificationTone(newTone);
                }
              },
              items: notificationTones.map((tone) {
                return DropdownMenuItem<String>(
                  value: tone,
                  child: Text(
                    tone == 'Default' ? 'Default' : tone.split('/').last,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
