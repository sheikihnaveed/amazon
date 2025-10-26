import 'package:flutter/material.dart';

class CheckoutHeader extends StatelessWidget {
  const CheckoutHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "By placing your order, you agree to Amazon's privacy notice and conditions of use.",
      style: TextStyle(fontSize: 12, color: Colors.black87),
    );
  }
}
