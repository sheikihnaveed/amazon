import 'package:flutter/material.dart';

class SignOutButton extends StatelessWidget {
  final Future<void> Function() onSignOut;
  const SignOutButton({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await onSignOut();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: const Text('Sign Out'),
    );
  }
}
