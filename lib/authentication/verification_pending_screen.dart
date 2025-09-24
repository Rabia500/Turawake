import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Truawake/userdashboard/myprofile_screen.dart';

class VerificationPendingScreen extends StatefulWidget {
  const VerificationPendingScreen({super.key});

  @override
  _VerificationPendingScreenState createState() => _VerificationPendingScreenState();
}

class _VerificationPendingScreenState extends State<VerificationPendingScreen> {
  bool _isResending = false;
  bool _isChecking = false;

  static const Color primaryColor = Color(0xFF7BC043); // TruAwake Green
  static const Color darkStart = Color(0xFF0B1F3A);    // Dark Blue
  static const Color darkEnd = Colors.black;
  static const Color textColor = Colors.white;

  Future<void> _checkEmailVerified() async {
    setState(() => _isChecking = true);

    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    user = FirebaseAuth.instance.currentUser;

    print('Checking email verification status for: ${user?.email}');
    if (user != null && user.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verified! Logging you in.'), backgroundColor: Colors.green),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyProfileScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email not verified yet. Please check your inbox.'), backgroundColor: Colors.red),
      );
    }

    setState(() => _isChecking = false);
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Resending verification email to: ${user.email}');
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email resent!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is currently signed in.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('Resend error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend: $e'), backgroundColor: Colors.red),
      );
    }

    setState(() => _isResending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email', style: TextStyle(color: Colors.white)),
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
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'We have sent a verification link to your email. Please verify your email to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _isChecking ? null : _checkEmailVerified,
                icon: const Icon(Icons.check_circle, color: Colors.black),
                label: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Text('I have verified my email', style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _isResending ? null : _resendVerificationEmail,
                child: _isResending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Resend verification email', style: TextStyle(color: textColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
