import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FingerprintLoginScreen extends StatefulWidget {
  const FingerprintLoginScreen({super.key});

  @override
  State<FingerprintLoginScreen> createState() => _FingerprintLoginScreenState();
}

class _FingerprintLoginScreenState extends State<FingerprintLoginScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isFingerprintEnabled = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _loadFingerprintPreference();
  }

  Future<void> _loadFingerprintPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFingerprintEnabled = prefs.getBool('useFingerprint') ?? false;
    });
  }

  Future<void> _updateFingerprintPreference(bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useFingerprint', enable);
    setState(() {
      _isFingerprintEnabled = enable;
    });
  }

  Future<void> _authenticateWithFingerprint() async {
    setState(() {
      _isAuthenticating = true;
    });

    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      final biometrics = await _localAuth.getAvailableBiometrics();

      if (!canAuthenticate || !isSupported || biometrics.isEmpty) {
        _showMessage('Fingerprint not supported on this device.');
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate using your fingerprint',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _showMessage('Authentication successful!', isSuccess: true);
        _navigateToHome();
      } else {
        _showMessage('Authentication failed. Try again.');
      }
    } catch (e) {
      _showMessage('Error during authentication: $e');
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  void _navigateToEmailLogin() {
    Navigator.of(context).pushReplacementNamed('/emailLogin');
  }

  Future<void> _onToggleFingerprint(bool value) async {
    final canUseBiometrics = await _localAuth.canCheckBiometrics;

    if (!canUseBiometrics && value) {
      _showMessage('Biometric authentication is not available on this device.');
      return;
    }

    await _updateFingerprintPreference(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fingerprint Login'),
        backgroundColor: const Color(0xFF1E2A78),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SwitchListTile(
                title: const Text('Enable Fingerprint Login'),
                value: _isFingerprintEnabled,
                onChanged: _onToggleFingerprint,
                activeThumbColor: const Color(0xFF7BC043),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isFingerprintEnabled && !_isAuthenticating
                    ? _authenticateWithFingerprint
                    : null,
                icon: const Icon(Icons.fingerprint),
                label: _isAuthenticating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text('Login with Fingerprint'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7BC043),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 24),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: _navigateToEmailLogin,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E2A78),
                  side: const BorderSide(color: Color(0xFF1E2A78)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: const Text('Login with Email/Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
