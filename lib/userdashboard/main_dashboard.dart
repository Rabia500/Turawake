import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Truawake/userdashboard/camera_activation.dart';
import 'package:Truawake/userdashboard/history_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Truawake/theme/theme_provider.dart';
import 'package:Truawake/services/map_screen.dart';
import 'package:Truawake/services/weather_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settingsmenu_screen.dart';
import 'setalarm_screen.dart';
import 'activities_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ... (existing state variables and methods like initState, dispose, etc.)
  String selectedCity = "Faisalabad";
  String greetingMessage = "Hello, ";
  String temperature = "--";
  String weatherCondition = "--";
  String username = "Driver";
  int _selectedIndex = 0;

  final OpenWeatherService weatherService = OpenWeatherService();

  final List<Widget> _widgetOptions = <Widget>[
    Container(),
    MapScreen(),
    CameraScreen(isFrontCamera: true, resolution: 'High', isAudioEnabled: true),
    ActivitiesMenuScreen(),
    const SettingsScreen(),
  ];

  final List<String> safetyTips = [
    "Take a 15-min break every 2 hours of driving.",
    "Always wear your seatbelt, even on short trips.",
    "Keep your phone out of reach while driving.",
    "Make sure your mirrors are properly adjusted before you start.",
    "Check your tire pressure regularly for safe driving.",
    "Do not drive when feeling sleepy—use TruAwake to stay alert!",
  ];

  String currentSafetyTip = '';
  final String verifyLicenseUrl = 'https://dlims.punjab.gov.pk/verify';
  Timer? _safetyTipTimer;

  @override
  void initState() {
    super.initState();
    fetchWeather();
    fetchUser();
    updateGreeting();
    _updateSafetyTip();
    _showVerifyLicenseReminderIfNeeded();
  }

  @override
  void dispose() {
    _safetyTipTimer?.cancel();
    super.dispose();
  }

  void _updateSafetyTip() {
    _safetyTipTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      setState(() {
        currentSafetyTip = safetyTips[DateTime.now().second % safetyTips.length];
      });
    });
  }

  void fetchUser() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      username = user?.displayName ?? user?.email?.split('@').first ?? "Driver";
    });
  }

  void fetchWeather() async {
    try {
      final coordinates = await weatherService.getCoordinates(selectedCity);
      if (coordinates != null) {
        var data = await weatherService.fetchWeather(coordinates["lat"]!, coordinates["lon"]!);
        if (mounted) {
          setState(() {
            if (data != null) {
              temperature = "${data['temperature']}°C";
              weatherCondition = data['condition'];
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching weather: $e");
    }
  }

  void updateGreeting() {
    var hour = DateTime.now().hour;
    setState(() {
      if (hour < 12) {
        greetingMessage = "Good Morning";
      } else if (hour < 18) {
        greetingMessage = "Good Afternoon";
      } else {
        greetingMessage = "Good Evening";
      }
    });
  }

  Future<void> _showVerifyLicenseReminderIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShownMillis = prefs.getInt('lastVerifyLicenseReminder') ?? 0;
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    if (nowMillis - lastShownMillis > 86400000) {
      Future.delayed(const Duration(seconds: 1), () => _showVerifyLicenseDialog());
    }
  }

  Future<void> _showVerifyLicenseDialog() async {
    final prefs = await SharedPreferences.getInstance();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verify Your License'),
          content: const Text('Please verify your driver license to continue using TruAwake safely.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                prefs.setInt('lastVerifyLicenseReminder', DateTime.now().millisecondsSinceEpoch);
              },
              child: const Text('Remind Me Later'),
            ),
            TextButton(
              onPressed: () async {
                final Uri url = Uri.parse(verifyLicenseUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
                Navigator.of(context).pop();
                prefs.setInt('lastVerifyLicenseReminder', DateTime.now().millisecondsSinceEpoch);
              },
              child: const Text('Verify License'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedIndex != 0) {
      return Scaffold(
        body: _widgetOptions[_selectedIndex],
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    }
    return Scaffold(
      body: SafeArea(child: _buildDashboardContent()),
      bottomNavigationBar: _buildBottomNavigationBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }

  Widget _buildDashboardContent() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final Color primaryGreen = isDarkMode ? Colors.green.shade700 : Colors.green.shade600;
    final Color secondaryGreen = isDarkMode ? Colors.green.shade400 : Colors.greenAccent.shade700;
    final Color cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color fadedTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER - Clean and Modern
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$greetingMessage, $username",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.wb_sunny : Icons.dark_mode,
                        color: Colors.white,
                      ),
                      onPressed: () => themeProvider.toggleTheme(!isDarkMode),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Stay Alert, Stay Alive",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: secondaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          selectedCity,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          temperature,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          weatherCondition,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Dashboard",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildDashboardCard(
                      icon: Icons.access_alarm,
                      title: "Set Alarm",
                      screen: AlarmMenuScreen(),
                      isDarkMode: isDarkMode,
                    ),
                    _buildDashboardCard(
                      icon: Icons.bar_chart,
                      title: "Statistics",
                      screen: HistoryScreen(),
                      isDarkMode: isDarkMode,
                    ),
                    _buildDashboardCard(
                      icon: Icons.verified_user,
                      title: "Verify License",
                      onTap: _showVerifyLicenseDialog,
                      isDarkMode: isDarkMode,
                    ),
                    _buildDashboardCard(
                      icon: Icons.local_activity,
                      title: "Activities",
                      screen: ActivitiesMenuScreen(),
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SAFETY TIP - Redesigned
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: secondaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: secondaryGreen, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: secondaryGreen, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      currentSafetyTip.isEmpty ? "Loading safety tips..." : currentSafetyTip,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Refined Card Widget
  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    Widget? screen,
    VoidCallback? onTap,
    required bool isDarkMode,
  }) {
    final Color cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color iconColor = isDarkMode ? Colors.green.shade400 : Colors.green.shade600;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap ?? () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen!)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: iconColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Refined Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Camera"),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: "Activities"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}