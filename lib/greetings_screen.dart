import 'package:flutter/material.dart';
import 'package:Truawake/authentication/login_screen.dart';
import 'package:Truawake/authentication/create_account_screen.dart';

class GreetingsScreen extends StatefulWidget {
  const GreetingsScreen({super.key});

  @override
  State<GreetingsScreen> createState() => _GreetingsScreenState();
}

class _GreetingsScreenState extends State<GreetingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  final Color _backgroundStart = const Color(0xFF0B1F3A); // Dark blue
  final Color _backgroundEnd = Colors.black; // Gradient end
  final Color _primaryGreen = const Color(0xFF7BC043); // Green from logo
  final Color _white = Colors.white;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_backgroundStart, _backgroundEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '',
                style: TextStyle(
                  fontSize: 18,
                  color: _white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 32),

              // Glowing logo
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _primaryGreen.withOpacity(_glowAnimation.value),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        'assets/logo.png',
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                        semanticLabel: 'TruAwake Logo',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),

              // Login button
              _buildAnimatedButton(
                label: 'Login',
                color: _primaryGreen,
                textColor: _backgroundStart,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Create Account button
              _buildAnimatedButton(
                label: 'Create an Account',
                color: _white,
                textColor: _backgroundStart,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
                  );
                },
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  _showHelpDialog(context);
                },
                child: Text(
                  'Need help?',
                  style: TextStyle(color: _white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(color),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        elevation: WidgetStateProperty.all(6),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return color.withOpacity(0.8); // Press effect
            }
            if (states.contains(WidgetState.hovered)) {
              return color.withOpacity(0.9); // Hover effect (for web/desktop)
            }
            return null;
          },
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 18, color: textColor),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _backgroundStart,
          title: Text(
            'Help & Instructions',
            style: TextStyle(color: _primaryGreen),
          ),
          content: Text(
            'If you are facing any issues:\n\n'
            '1. Ensure you have a stable internet connection.\n'
            '2. Use correct login details.\n'
            '3. Fill all fields when signing up.\n'
            '4. Use "Forgot Password" if needed.\n\n'
            'Contact support at support@truawake.com.',
            style: TextStyle(color: _white.withOpacity(0.85)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(color: _primaryGreen),
              ),
            ),
          ],
        );
      },
    );
  }
}
