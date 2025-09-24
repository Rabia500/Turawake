import 'package:flutter/material.dart';

class PrivacyAndTermsScreen extends StatelessWidget {
  const PrivacyAndTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0B1F3A); // Dark Background Start
    const Color accentColor = Color(0xFF7BC043); // TruAwake Green
    const Color textColor = Colors.white; // Light text for dark background

    TextStyle headingStyle(double size) => TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: size,
      color: accentColor,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy & Terms of Service',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: accentColor,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Effective Date: [27-Jan-2025]',
                  style: headingStyle(14)),
              const SizedBox(height: 16),
              Text('Privacy Policy', style: headingStyle(22)),
              const SizedBox(height: 8),
              const Text(
                'TruAwake is committed to protecting the privacy of its users. This privacy policy outlines how we collect, use, and protect your personal information while ensuring a safe and efficient experience with our driver drowsiness detection application.',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 16),
              Text('1. Information We Collect', style: headingStyle(18)),
              const SizedBox(height: 8),
              const Text(
                'We collect the following types of data to provide and improve our services:\n- Personal Information\n- Biometric Data\n- Device Data\n- Location Data\n- Usage Data',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 16),
              Text('2. How We Use Your Information', style: headingStyle(18)),
              const SizedBox(height: 8),
              const Text(
                'The collected data is used to:\n- Detect signs of driver fatigue in real time.\n- Issue alerts and warnings to prevent accidents.\n- Enhance the accuracy of the application through pattern learning.',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 32),

              // Terms of Service Section
              Text('Terms of Service', style: headingStyle(22)),
              const SizedBox(height: 8),
              Text('Effective Date: [27-Jan-2025]', style: headingStyle(14)),
              const SizedBox(height: 16),
              Text('1. Acceptance of Terms', style: headingStyle(18)),
              const SizedBox(height: 8),
              const Text(
                'By downloading and using TruAwake, you agree to comply with these terms of service. If you do not agree, you must discontinue using the application.',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 16),
              Text('2. Usage Rights and Restrictions', style: headingStyle(18)),
              const SizedBox(height: 8),
              const Text(
                'The app is provided for personal and commercial use to enhance driver safety. Users must not misuse the application, including reverse-engineering or modifying the app.',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 16),
              Text('3. Account Responsibility', style: headingStyle(18)),
              const SizedBox(height: 8),
              const Text(
                'Users are responsible for maintaining the confidentiality of their account credentials. Unauthorized use of the app should be reported immediately.',
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
