import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
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
  ImageProvider? _profileImageProvider;

  bool _isSaving = false;

  final Color _backgroundStart = const Color(0xFF0B1F3A);
  final Color _backgroundEnd = Colors.black;
  final Color _primaryGreen = const Color(0xFF7BC043);
  final Color _white = Colors.white;
  final Color _lightText = Colors.white70;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _firstName = data['firstName'] ?? '';
          _lastName = data['lastName'] ?? '';
          _email = data['email'] ?? '';
          _selectedCountryCode = data['countryCode'] ?? _selectedCountryCode;
          _phoneNumber = data['phoneNumber'] ?? '';
          _address = data['address'] ?? '';
          _drivingExperience = data['drivingExperience'] ?? '';
          _health = data['health'] ?? '';

          final imageUrl = data['profileImageUrl'];
          if (imageUrl != null && imageUrl.isNotEmpty) {
            _profileImageProvider = NetworkImage(imageUrl);
          }
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
        _profileImageProvider = null; // clear network image if new one picked
      });
    }
  }

  Future<void> _saveProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User not logged in.', style: TextStyle(color: Colors.redAccent)),
          backgroundColor: Colors.black87,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String? imageUrl;

    try {
      // Upload image to Firebase Storage if selected
      if (_profileImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('$userId.jpg');

        await ref.putFile(_profileImage!);
        imageUrl = await ref.getDownloadURL();
      }

      final profileData = {
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
        'countryCode': _selectedCountryCode,
        'phoneNumber': _phoneNumber,
        'address': _address,
        'drivingExperience': _drivingExperience,
        'health': _health,
      };

      if (imageUrl != null) {
        profileData['profileImageUrl'] = imageUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(profileData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!', style: TextStyle(color: Colors.white)),
          backgroundColor: _primaryGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e', style: const TextStyle(color: Colors.redAccent)),
          backgroundColor: Colors.black87,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: _primaryGreen,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_backgroundStart, _backgroundEnd],
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
                          : _profileImageProvider,
                      child: _profileImage == null && _profileImageProvider == null
                          ? Icon(Icons.person, size: 60, color: _primaryGreen)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(30),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: _white,
                          child: Icon(Icons.camera_alt, color: _primaryGreen, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField('First Name', (value) => _firstName = value, initialValue: _firstName),
              const SizedBox(height: 16),
              _buildTextField('Last Name', (value) => _lastName = value, initialValue: _lastName),
              const SizedBox(height: 16),
              _buildTextField('Email', (value) => _email = value, isEmail: true, initialValue: _email),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCountryCode,
                isDense: true,
                dropdownColor: Colors.grey[900],
                items: _countries.map((code) {
                  return DropdownMenuItem(
                    value: code,
                    child: Text(
                      code,
                      style: TextStyle(color: _white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCountryCode = value;
                  });
                },
                decoration: _inputDecoration('Country Code'),
              ),
              const SizedBox(height: 12),
              _buildTextField('Phone Number', (value) => _phoneNumber = value, isPhone: true, initialValue: _phoneNumber),
              const SizedBox(height: 16),
              _buildTextField('Address', (value) => _address = value, initialValue: _address),
              const SizedBox(height: 16),
              _buildTextField('Driving Experience (in years)', (value) => _drivingExperience = value, isNumber: true, initialValue: _drivingExperience),
              const SizedBox(height: 16),
              _buildTextField('Health', (value) => _health = value, initialValue: _health),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          await _saveProfile();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 5,
                  shadowColor: Colors.black,
                ),
                child: _isSaving
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                      )
                    : const Text('Save', style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onSaved,
      {String? initialValue, bool isEmail = false, bool isNumber = false, bool isPhone = false}) {
    return TextFormField(
      initialValue: initialValue,
      style: TextStyle(color: _white),
      decoration: _inputDecoration(label),
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isNumber
              ? TextInputType.number
              : isPhone
                  ? TextInputType.phone
                  : TextInputType.text,
      onSaved: (value) => onSaved(value ?? ''),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        if (isNumber && (int.tryParse(value) == null || int.parse(value) < 0)) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _lightText),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _primaryGreen.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _primaryGreen, width: 2),
      ),
      errorStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }
}
