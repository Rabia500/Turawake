import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Truawake/userdashboard/register_vehicle.dart';

// Theme constants
const Color primaryColor = Color(0xFF7BC043); // TruAwake Green
const Color backgroundStart = Color(0xFF0B1F3A); // Dark Blue
const Color backgroundEnd = Colors.black;
const Color textColor = Colors.white;
const Color lightTextColor = Colors.white70;

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _countries = ['+1 (US)', '+91 (India)', '+92 (Pakistan)', '+44 (UK)', '+61 (Australia)'];

  String? _selectedCountryCode = '+1 (US)';
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phoneNumber = '';
  String _address = '';
  String _drivingExperience = '';
  String _health = '';
  File? _profileImage;

  String? _uid;
  DocumentSnapshot? _existingProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _loadProfileData();
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _loadProfileData() async {
    if (_uid == null) return;

    final snapshot = await FirebaseFirestore.instance.collection('users').doc(_uid).get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;

      setState(() {
        _existingProfile = snapshot;
        _firstName = data['firstName'] ?? '';
        _lastName = data['lastName'] ?? '';
        _email = data['email'] ?? '';
        _phoneNumber = (data['phoneNumber'] ?? '').toString().split(' ').last;
        _selectedCountryCode = _countries.firstWhere(
          (code) => (data['phoneNumber'] ?? '').toString().startsWith(code),
          orElse: () => '+1 (US)',
        );
        _address = data['address'] ?? '';
        _drivingExperience = data['drivingExperience'] ?? '';
        _health = data['health'] ?? '';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfileData() async {
    try {
      String? imageUrl;

      if (_profileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_images').child('$_uid.jpg');
        await storageRef.putFile(_profileImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(_uid).set({
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
        'phoneNumber': '$_selectedCountryCode $_phoneNumber',
        'address': _address,
        'drivingExperience': _drivingExperience,
        'health': _health,
        'profileImageUrl': imageUrl ?? _existingProfile?.get('profileImageUrl') ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: textColor)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [backgroundStart, backgroundEnd],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[900],
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : (_existingProfile?.get('profileImageUrl') != null &&
                                        _existingProfile!['profileImageUrl'] != '')
                                    ? NetworkImage(_existingProfile!['profileImageUrl'])
                                        as ImageProvider
                                    : null,
                            child: (_profileImage == null &&
                                    (_existingProfile?.get('profileImageUrl') == null ||
                                        _existingProfile!['profileImageUrl'] == ''))
                                ? const Icon(Icons.person, size: 60, color: primaryColor)
                                : null,
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: _pickImage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField('First Name', (value) => _firstName = value ?? '', initialValue: _firstName),
                    _buildTextField('Last Name', (value) => _lastName = value ?? '', initialValue: _lastName),
                    _buildTextField('Email', (value) => _email = value ?? '', initialValue: _email, keyboardType: TextInputType.emailAddress),
                    _buildPhoneSection(),
                    _buildTextField('Address', (value) => _address = value ?? '', initialValue: _address),
                    _buildTextField('Driving Experience (in years)', (value) => _drivingExperience = value ?? '', initialValue: _drivingExperience, keyboardType: TextInputType.number),
                    _buildTextField('Health', (value) => _health = value ?? '', initialValue: _health),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          _saveProfileData().then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile saved to Firebase!')),
                            );
                            Future.delayed(const Duration(seconds: 1), () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  const VehicleScreen(),
                                ),
                              );
                            });
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved,
      {TextInputType keyboardType = TextInputType.text, String? initialValue}) {
    return Column(
      children: [
        TextFormField(
          style: const TextStyle(color: textColor),
          initialValue: initialValue,
          decoration: _inputDecoration(label),
          keyboardType: keyboardType,
          onSaved: onSaved,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: Colors.grey[900],
          decoration: _inputDecoration(label),
          items: items.map((code) {
            return DropdownMenuItem<String>(
              value: code,
              child: Text(code, style: const TextStyle(color: textColor)),
            );
          }).toList(),
          onChanged: onChanged,
          style: const TextStyle(color: textColor),
          validator: (val) => val == null || val.isEmpty ? 'Please select $label' : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPhoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDropdownField(
          label: 'Country Code',
          value: _selectedCountryCode,
          items: _countries,
          onChanged: (value) => setState(() => _selectedCountryCode = value),
        ),
        _buildTextField(
          'Phone Number',
          (value) => _phoneNumber = value ?? '',
          keyboardType: TextInputType.phone,
          initialValue: _phoneNumber,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: lightTextColor),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    );
  }
}
