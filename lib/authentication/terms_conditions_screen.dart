import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const Color primaryColor = Color(0xFF7BC043); // TruAwake Green
  static const Color darkStart = Color(0xFF0B1F3A);    // Dark Blue
  static const Color darkEnd = Colors.black;
  static const Color textColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [darkStart, darkEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to TruAwake!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'By using this app, you agree to the following terms and conditions. Please read them carefully before using the app.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
              ),
              const SizedBox(height: 24),

              // Section 1
              Text(
                '1. Usage Policy',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'The TruAwake app is designed to assist drivers in staying alert. It is not a replacement for safe driving practices. Always prioritize road safety and never rely solely on the app.',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 16),

              // Section 2
              Text(
                '2. Data Privacy',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'We respect your privacy. Personal data such as location and alerts are stored securely and are not shared with third parties without your consent.',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 16),

              // Section 3
              Text(
                '3. Limitations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'While TruAwake aims to improve driver alertness, it cannot guarantee prevention of accidents or drowsiness. Use the app as a supportive tool only.',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 16),

              // Section 4
              Text(
                '4. Updates & Changes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'We may update these terms periodically. Continued use of the app indicates your acceptance of the updated terms.',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 16),

              // Section 5
              Text(
                '5. Contact Us',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'If you have any questions or concerns about these terms, please contact us at support@truawake.com.',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Accept & Go Back', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
