import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

class UpdateProfileView extends StatefulWidget {
  const UpdateProfileView({super.key});

  @override
  State<UpdateProfileView> createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends State<UpdateProfileView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController pincodeCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();

  @override
  @override
  void initState() {
    super.initState();

    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    // Wait until after the first frame before loading data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (profileProvider.profileData == null) {
        await profileProvider.loadProfile();
      } else {
        _fillExistingData(profileProvider.profileData!);
      }

      // Listen once profile data is loaded
      if (mounted && profileProvider.profileData != null) {
        _fillExistingData(profileProvider.profileData!);
      }
    });
  }


  void _fillExistingData(Map<String, dynamic> data) {
    nameCtrl.text = data['name'] ?? '';
    phoneCtrl.text = data['phone'] ?? '';
    addressCtrl.text = data['address'] ?? '';
    cityCtrl.text = data['city'] ?? '';
    pincodeCtrl.text = data['pincode'] ?? '';
    emailCtrl.text = data['email'] ?? '';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    pincodeCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8E5E5),
        title: const Text("Your Addresses"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: profile.isLoading && profile.profileData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email (non-editable)
              _buildDisabledField("Email", emailCtrl),

              _buildField("Full name", nameCtrl, "Enter full name"),
              _buildField("Mobile number", phoneCtrl, "Enter mobile number"),
              _buildField("Flat, House no., Building, Company, Apartment",
                  addressCtrl, "Enter address"),
              _buildField("Town/City", cityCtrl, "Enter city"),
              _buildField("Pincode", pincodeCtrl, "Enter 6-digit pincode"),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await profile.updateProfile({
                        'name': nameCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'address': addressCtrl.text.trim(),
                        'city': cityCtrl.text.trim(),
                        'pincode': pincodeCtrl.text.trim(),
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFED813),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: profile.isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                    "Save Address",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  Regular editable input fields
  Widget _buildField(
      String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: (val) => val!.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  //  Non-editable (disabled) email field
  Widget _buildDisabledField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          fillColor: Colors.grey.shade200,
          filled: true,
        ),
      ),
    );
  }
}
