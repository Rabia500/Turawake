import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: BreakReminderScreen(),
    theme: ThemeData.dark(), // Base dark theme
    debugShowCheckedModeBanner: false,
  ));
}

class BreakReminderScreen extends StatefulWidget {
  const BreakReminderScreen({super.key});

  @override
  _BreakReminderScreenState createState() => _BreakReminderScreenState();
}

class _BreakReminderScreenState extends State<BreakReminderScreen> {
  bool _isBreakReminderEnabled = true;
  int _breakInterval = 60;
  DateTime? _nextBreakTime;
  late String _timerText;

  final Color _backgroundStart = const Color(0xFF0B1F3A);
  final Color _backgroundEnd = Colors.black;
  final Color _primaryGreen = const Color(0xFF7BC043);
  final Color _textWhite = Colors.white;

  @override
  void initState() {
    super.initState();
    _updateNextBreakTime();
  }

  void _updateNextBreakTime() {
    if (_isBreakReminderEnabled) {
      setState(() {
        _nextBreakTime = DateTime.now().add(Duration(minutes: _breakInterval));
        _timerText =
            "Next break at: ${_nextBreakTime!.hour}:${_nextBreakTime!.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  void _startBreakTimer() {
    if (_nextBreakTime != null) {
      Duration duration = _nextBreakTime!.difference(DateTime.now());
      if (duration.isNegative) {
        setState(() {
          _timerText = "Your break is due now!";
        });
      } else {
        setState(() {
          _timerText = "Next break in: ${duration.inMinutes} min";
        });
      }
    }
  }

  void _showBreakIntervalMenu() async {
    int? selectedInterval = await showModalBottomSheet<int>(
      backgroundColor: Colors.grey[900],
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                "Set Break Interval",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const Divider(color: Colors.white),
            for (int hours = 1; hours <= 5; hours++)
              ListTile(
                title: Text(
                  "$hours hour${hours > 1 ? 's' : ''}",
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context, hours * 60);
                },
              ),
          ],
        );
      },
    );

    if (selectedInterval != null) {
      setState(() {
        _breakInterval = selectedInterval;
        _updateNextBreakTime();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Break Reminder'),
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_backgroundStart, _backgroundEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(
                'Enable Break Reminder',
                style: TextStyle(color: _textWhite),
              ),
              value: _isBreakReminderEnabled,
              activeThumbColor: _primaryGreen,
              onChanged: (bool value) {
                setState(() {
                  _isBreakReminderEnabled = value;
                  if (value) {
                    _updateNextBreakTime();
                  } else {
                    _timerText = "Break reminder disabled.";
                  }
                });
              },
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                _timerText,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textWhite),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _isBreakReminderEnabled ? _showBreakIntervalMenu : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Set Break Reminder Time'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isBreakReminderEnabled
                        ? () {
                            _startBreakTimer();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Break reminder settings saved!'),
                                backgroundColor: _primaryGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Save and Start Timer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
