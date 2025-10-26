import 'package:flutter/material.dart';

class ProfileForm extends StatefulWidget {
  final String name;
  final String address;
  final Function(String, String) onSave;

  const ProfileForm({
    super.key,
    required this.name,
    required this.address,
    required this.onSave,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _addressController = TextEditingController(text: widget.address);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _addressController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Address',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_nameController.text, _addressController.text);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFED813),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Save Changes',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
