import 'dart:async'; // For the timer functionality
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Truawake/theme/theme_provider.dart'; // Import ThemeProvider

class ActivitiesMenuScreen extends StatefulWidget {
  const ActivitiesMenuScreen({super.key});

  @override
  _ActivitiesMenuScreenState createState() => _ActivitiesMenuScreenState();
}

class _ActivitiesMenuScreenState extends State<ActivitiesMenuScreen> {
  bool _isVoiceAlertsEnabled = true;
  bool _isPuzzleChallengeActive = true; // Automatically enabled when the app starts
  Timer? _puzzleTimer; // Timer for puzzle challenge interval
  Timer? _questionTimer; // Timer for interactive question interval
  final int _puzzleInterval = 10; // Interval for puzzle challenge (in minutes)
  final int _questionInterval = 5; // Interval for interactive questions (in minutes)

  // List of example interactive questions
  final List<String> _interactiveQuestions = [
    "What is your current speed?",
    "What color is the car in front of you?",
    "What is the road sign on your left?",
  ];

  // List of example puzzle challenges
  final List<String> _puzzleChallenges = [
    "What is 5 + 3?",
    "What is 8 - 2?",
    "What is 6 * 4?",
  ];

  @override
  void initState() {
    super.initState();
    _startTimers(); // Start the timers for automatic questions and puzzles
  }

  @override
  void dispose() {
    _puzzleTimer?.cancel(); // Cancel timer when screen is disposed
    _questionTimer?.cancel(); // Cancel timer when screen is disposed
    super.dispose();
  }

  // Function to toggle voice alerts
  void _toggleVoiceAlerts(bool value) {
    setState(() {
      _isVoiceAlertsEnabled = value;
    });
  }

  // Function to display interactive questions
  void _askInteractiveQuestion() {
    int questionIndex = DateTime.now().second % _interactiveQuestions.length;
    _showAlertDialog("Interactive Question", _interactiveQuestions[questionIndex]);
  }

  // Function to display a puzzle challenge
  void _showPuzzleChallenge() {
    int puzzleIndex = DateTime.now().second % _puzzleChallenges.length;
    _showAlertDialog("Puzzle Challenge", _puzzleChallenges[puzzleIndex]);
  }

  // Function to show alert dialog
  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor, // Use theme's background color
          title: Text(
            title,
            style: TextStyle(color: Theme.of(context).primaryColor), // Use theme's primary color
          ),
          content: Text(
            content,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color), // Use theme's text color
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.secondary)), // Use theme's accent color
            ),
          ],
        );
      },
    );
  }

  // Function to start the timers for the puzzles and questions
  void _startTimers() {
    _puzzleTimer = Timer.periodic(Duration(minutes: _puzzleInterval), (timer) {
      _showPuzzleChallenge();
    });

    _questionTimer = Timer.periodic(Duration(minutes: _questionInterval), (timer) {
      _askInteractiveQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context); // Get current theme mode
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // Use theme's background color
      appBar: AppBar(
        title: const Text("Activities Menu"),
        backgroundColor: Theme.of(context).primaryColor, // Use theme's primary color
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor, // Use theme's app bar text color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildActivityTile(
              title: "Puzzle Challenges",
              subtitle: _isPuzzleChallengeActive
                  ? "Enabled (You will be given puzzles every 10 minutes)"
                  : "Disabled",
              icon: Icons.extension,
              onTap: () {
                setState(() {
                  _isPuzzleChallengeActive = !_isPuzzleChallengeActive;
                });
              },
            ),
            const Divider(color: Colors.white30),

            _buildActivityTile(
              title: "Interactive Questions",
              subtitle: "Engage with questions to stay alert",
              icon: Icons.help_outline,
              onTap: _askInteractiveQuestion,
            ),
            const Divider(color: Colors.white30),

            // Voice Alerts (Enable/Disable)
            SwitchListTile(
              title: Text("Voice Alerts", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              subtitle: Text("Receive voice alerts for drowsiness", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              value: _isVoiceAlertsEnabled,
              activeThumbColor: Theme.of(context).colorScheme.secondary, // Use theme's accent color
              onChanged: _toggleVoiceAlerts,
            ),
          ],
        ),
      ),
    );
  }

  // Function to build activity tile with consistent styling
  Widget _buildActivityTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18)),
      subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
      trailing: Icon(icon, color: Theme.of(context).colorScheme.secondary), // Use theme's accent color
      onTap: onTap,
    );
  }
}
