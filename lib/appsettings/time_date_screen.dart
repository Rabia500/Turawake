import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeSettingsScreen extends StatefulWidget {
  const DateTimeSettingsScreen({super.key});

  @override
  _DateTimeSettingsScreenState createState() => _DateTimeSettingsScreenState();
}

class _DateTimeSettingsScreenState extends State<DateTimeSettingsScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _autoUpdateTime = true;

  String get _formattedDate => DateFormat.yMMMd().format(_selectedDate);
  String get _formattedTime => _selectedTime.format(context);

  static const Color darkBlue = Color(0xFF0B1F3A); // TruAwake dark
  static const Color primaryGreen = Color(0xFF7BC043); // TruAwake green
  static const Color textWhite = Colors.white;
  static const Color textGrey = Colors.white70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Date & Time Settings',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [darkBlue, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text(
                'Current Date: $_formattedDate',
                style: const TextStyle(fontSize: 18, color: textWhite),
              ),
              const SizedBox(height: 8),
              Text(
                'Current Time: $_formattedTime',
                style: const TextStyle(fontSize: 18, color: textWhite),
              ),
              const SizedBox(height: 24),

              ListTile(
                title: const Text(
                  'Set Date',
                  style: TextStyle(fontWeight: FontWeight.w600, color: textWhite),
                ),
                subtitle: Text(_formattedDate, style: const TextStyle(color: textGrey)),
                trailing: const Icon(Icons.calendar_today, color: primaryGreen),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),

              ListTile(
                title: const Text(
                  'Set Time',
                  style: TextStyle(fontWeight: FontWeight.w600, color: textWhite),
                ),
                subtitle: Text(_formattedTime, style: const TextStyle(color: textGrey)),
                trailing: const Icon(Icons.access_time, color: primaryGreen),
                onTap: _selectTime,
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Enable Automatic Time Update', style: TextStyle(color: textWhite)),
                value: _autoUpdateTime,
                activeThumbColor: primaryGreen,
                onChanged: (value) {
                  setState(() {
                    _autoUpdateTime = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Settings', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: primaryGreen,
              onPrimary: Colors.black,
              surface: darkBlue,
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: primaryGreen,
              onPrimary: Colors.black,
              surface: darkBlue,
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Date and Time settings saved successfully!'),
        backgroundColor: primaryGreen,
      ),
    );
    print('Saved Date: $_formattedDate');
    print('Saved Time: $_formattedTime');
    print('Auto Update Time: $_autoUpdateTime');
  }
}
