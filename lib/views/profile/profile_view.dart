import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import 'orders_view.dart';
import 'update_profile_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8E5E5),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        elevation: 0,
      ),
      body: profile.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Account Settings",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // 🟡 "Your Orders" button
            _buildSettingItem(
              context,
              title: "Your Orders",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrdersView(),
                ),
              ),
            ),

            // 🟢 "Update Profile" button
            const SizedBox(height: 10),
            _buildSettingItem(
              context,
              title: "Update Profile",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UpdateProfileView(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSettingItem(
      BuildContext context, {
        required String title,
        required VoidCallback onTap,
      }) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
