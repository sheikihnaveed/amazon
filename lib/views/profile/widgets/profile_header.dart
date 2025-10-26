import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String email;
  const ProfileHeader({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(email, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}
