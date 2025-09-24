import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateVehicleScreen extends StatefulWidget {
  final String vehicleId;
  final Map<String, dynamic> vehicleData;

  const UpdateVehicleScreen({super.key, required this.vehicleId, required this.vehicleData});

  @override
  _UpdateVehicleScreenState createState() => _UpdateVehicleScreenState();
}

class _UpdateVehicleScreenState extends State<UpdateVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _vehicleNumber;
  late String _ownerName;
  late String _vehicleModel;
  late String _selectedVehicleType;
  late String _contactNumber;

  final List<String> _vehicleTypes = ['Car', 'Bike', 'Truck', 'Bus'];

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (widget.vehicleData['userId'] != user?.uid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You can't edit this vehicle.")),
        );
        Navigator.pop(context);
      });
    }

    _vehicleNumber = widget.vehicleData['vehicleNumber'];
    _ownerName = widget.vehicleData['ownerName'];
    _vehicleModel = widget.vehicleData['vehicleModel'];
    _selectedVehicleType = widget.vehicleData['vehicleType'];
    _contactNumber = widget.vehicleData['contactNumber'];
  }

  Future<void> _updateVehicleData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.vehicleId.isEmpty || widget.vehicleData['userId'] != user?.uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unauthorized to update this vehicle.")),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('vehicles').doc(widget.vehicleId).update({
          'vehicleNumber': _vehicleNumber,
          'ownerName': _ownerName,
          'vehicleModel': _vehicleModel,
          'vehicleType': _selectedVehicleType,
          'contactNumber': _contactNumber,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Vehicle updated successfully!")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Vehicle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFormField('Vehicle Number', _vehicleNumber, (value) => _vehicleNumber = value!),
              _buildTextFormField('Owner Name', _ownerName, (value) => _ownerName = value!),
              _buildTextFormField('Vehicle Model', _vehicleModel, (value) => _vehicleModel = value!),
              DropdownButtonFormField<String>(
                initialValue: _selectedVehicleType,
                items: _vehicleTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _selectedVehicleType = value!),
                decoration: InputDecoration(labelText: 'Vehicle Type'),
              ),
              _buildTextFormField('Contact Number', _contactNumber, (value) => _contactNumber = value!),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateVehicleData,
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, String initialValue, Function(String?) onSaved) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      onSaved: onSaved,
    );
  }
}
