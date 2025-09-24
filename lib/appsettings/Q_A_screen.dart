import 'package:flutter/material.dart';

class QnAScreen extends StatelessWidget {
  const QnAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF0B1F3A); // Gradient start
    const Color primaryGreen = Color(0xFF7BC043); // Lime Green
    const Color textWhite = Colors.white;
    const Color greyText = Colors.white70;

    final List<Map<String, String>> faqs = [
      {
        'question': 'What is TruAwake, and what problem does it aim to solve?',
        'answer':
            'TruAwake is a driver drowsiness detection application designed to alert drivers when they exhibit signs of fatigue. It aims to reduce road traffic accidents (RTAs) caused by drowsy driving, particularly on highways and motorways where fatigue-related accidents are common.'
      },
      {
        'question': 'How does TruAwake detect drowsiness in drivers?',
        'answer':
            'TruAwake uses a smartphone camera to monitor key facial expressions such as eye closure, yawning, and head tilts. The system processes these inputs using AI-driven image processing and lightweight machine learning models to provide real-time alerts.'
      },
      {
        'question': 'What are the primary challenges with current driver drowsiness detection systems?',
        'answer':
            'Current systems often rely on expensive, intrusive hardware such as in-vehicle cameras or wearable devices. They are also sensitive to environmental conditions (e.g., lighting) and may raise privacy concerns, making them less accessible and scalable.'
      },
      {
        'question': 'What are the modules included in the TruAwake application?',
        'answer':
            'The modules include: Login, Mobile Sensor Integration, Data Analysis, Adaptive Pattern Learning, Speed & Driving Dynamics Analysis, Biometric Data Collection & Analysis, Alert System, Driver Pattern Learning, Location-Based Analysis, Environmental Awareness, Predictive Drowsiness Detection, Post-Drive Reporting.'
      },
      {
        'question': 'What advantages does TruAwake offer over traditional systems?',
        'answer':
            'TruAwake offers early drowsiness detection using a smartphone camera, cost-effectiveness, non-intrusive detection methods, compatibility across various vehicles, and feedback to encourage safer driving habits.'
      },
      {
        'question': 'What limitations does TruAwake face?',
        'answer':
            'Limitations include reduced accuracy in poor lighting conditions or when the driver wears glasses, and occasional false detections, such as when the driver adjusts their seat.'
      },
      {
        'question': 'How does the application align with Sustainable Development Goals (SDGs)?',
        'answer':
            'TruAwake promotes Good Health and Well-being through safer roads, advances Industry, Innovation, and Infrastructure by enhancing vehicle safety, supports Sustainable Cities and Communities with improved road safety, and encourages Decent Work and Economic Growth by preventing fatigue-related incidents.'
      },
      {
        'question': 'What industries can benefit from TruAwake?',
        'answer':
            'Industries that can benefit from TruAwake include Automotive (reducing accident risks), Fleet Management (monitoring driver alertness), Insurance (promoting safer driving habits), and High-risk sectors like construction and mining (ensuring alertness of operators).'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Q&A',
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                style: const TextStyle(color: textWhite),
                decoration: InputDecoration(
                  hintText: 'Search Questions...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white10,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryGreen),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white30),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryGreen.withOpacity(0.6)),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white10,
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        unselectedWidgetColor: primaryGreen,
                        colorScheme: ColorScheme.dark(
                          primary: primaryGreen,
                          onPrimary: textWhite,
                        ),
                      ),
                      child: ExpansionTile(
                        iconColor: primaryGreen,
                        collapsedIconColor: primaryGreen,
                        title: Text(
                          faqs[index]['question']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textWhite,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              faqs[index]['answer']!,
                              style: const TextStyle(color: greyText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
