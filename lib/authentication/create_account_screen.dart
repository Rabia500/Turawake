import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Truawake/authentication/verification_pending_screen.dart';
import 'package:flutter/gestures.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController = TextEditingController();

  bool _isTermsAccepted = false;
  bool _attemptedSubmit = false; // NEW: only show warning after submit
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isFingerprintEnabled = false;
  bool _isPasswordVisible = false;
  bool _isRetypePasswordVisible = false;

  Future<void> _authenticateWithFingerprint() async {
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();

      if (!isDeviceSupported || !canCheckBiometrics || availableBiometrics.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication not available or not enrolled'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to set up fingerprint login',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (isAuthenticated) {
        setState(() {
          _isFingerprintEnabled = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fingerprint authentication enabled!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fingerprint authentication failed or canceled'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fingerprint auth error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terms & Privacy'),
          content: const SingleChildScrollView(
            child: Text(
              'These are the Terms & Conditions and Privacy Policy of the TruAwake app. '
              'By creating an account, you agree to abide by our guidelines, protect your personal data, '
              'and acknowledge that the app is provided as-is. For full details, please contact our support team.',
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _onSignUpPressed() async {
    setState(() {
      _attemptedSubmit = true; // show red warning only after submit attempt
    });

    if (_formKey.currentState!.validate()) {
      if (!_isTermsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept the Terms & Privacy'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_passwordController.text != _retypePasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await userCredential.user!.sendEmailVerification();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('useFingerprint', _isFingerprintEnabled);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Please check your email to verify.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VerificationPendingScreen()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMsg = 'Something went wrong';
        if (e.code == 'email-already-in-use') {
          errorMsg = 'This email is already in use.';
        } else if (e.code == 'invalid-email') {
          errorMsg = 'Invalid email format.';
        } else if (e.code == 'weak-password') {
          errorMsg = 'Password is too weak.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E2A78), Color(0xFFA4C639)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Create Your Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildTextField(_fullNameController, 'Full Name', Icons.person),
                          const SizedBox(height: 20),
                          _buildTextField(_emailController, 'Email Address', Icons.email,
                              keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 20),
                          _buildTextField(
                            _passwordController,
                            'Password',
                            Icons.lock,
                            obscureText: !_isPasswordVisible,
                            onToggleVisibility: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            isPasswordField: true,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            _retypePasswordController,
                            'Retype Password',
                            Icons.lock_outline,
                            obscureText: !_isRetypePasswordVisible,
                            onToggleVisibility: () {
                              setState(() {
                                _isRetypePasswordVisible = !_isRetypePasswordVisible;
                              });
                            },
                            isPasswordField: true,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Checkbox(
                                value: _isTermsAccepted,
                                onChanged: (value) => setState(() => _isTermsAccepted = value ?? false),
                                activeColor: const Color(0xFFA4C639),
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'I agree to the ',
                                    style: const TextStyle(color: Colors.white),
                                    children: [
                                      TextSpan(
                                        text: 'Terms & Privacy',
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()..onTap = _showTermsDialog,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_attemptedSubmit && !_isTermsAccepted)
                            const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                'You must accept the Terms & Privacy',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          const SizedBox(height: 20),
                          Center(
                            child: Column(
                              children: [
                                _buildElevatedButton('Sign Up', _onSignUpPressed, const Color(0xFF1E2A78), Colors.white),
                                const SizedBox(height: 20),
                                _buildElevatedButton('Enable Fingerprint', _authenticateWithFingerprint, const Color(0xFF1E2A78), Colors.white),
                              ],
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool isPasswordField = false,
    VoidCallback? onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        if (label == 'Email Address' &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
          return 'Enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildElevatedButton(String text, VoidCallback onPressed, Color bgColor, Color textColor) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }
}
