import 'package:flutter/material.dart';

// Reusing color theme from MyProfileScreen
const Color primaryColor = Color(0xFF7BC043); // TruAwake Green
const Color backgroundStart = Color(0xFF0B1F3A); // Dark Blue
const Color backgroundEnd = Colors.black;
const Color textColor = Colors.white;
const Color lightTextColor = Colors.white70;

class LanguageRegionScreen extends StatefulWidget {
  const LanguageRegionScreen({super.key});

  @override
  _LanguageRegionScreenState createState() => _LanguageRegionScreenState();
}

class _LanguageRegionScreenState extends State<LanguageRegionScreen> {
  final List<String> _languages = [
    'English',
    'Urdu',
    'Hindi',
    'Spanish',
    'French',
    'German',
    'Chinese',
  ];

  final List<String> _regions = [
    'United States',
    'Pakistan',
    'India',
    'United Kingdom',
    'Australia',
    'Canada',
    'Germany',
  ];

  String? _selectedLanguage = 'English';
  String? _selectedRegion = 'United States';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Language & Region',
          style: textTheme.titleLarge?.copyWith(color: textColor),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundStart, backgroundEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Language:',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedLanguage,
                dropdownColor: Colors.grey[800],
                items: _languages.map((language) {
                  return DropdownMenuItem(
                    value: language,
                    child: Text(language,
                        style: textTheme.bodyMedium?.copyWith(color: textColor)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                },
                decoration: _inputDecoration('Language'),
              ),
              const SizedBox(height: 30),
              Text(
                'Select Region:',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedRegion,
                dropdownColor: Colors.grey[800],
                items: _regions.map((region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(region,
                        style: textTheme.bodyMedium?.copyWith(color: textColor)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRegion = value;
                  });
                },
                decoration: _inputDecoration('Region'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Language: $_selectedLanguage, Region: $_selectedRegion saved!',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'Save',
                  style: textTheme.titleMedium?.copyWith(color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textColor),
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    );
  }
}
