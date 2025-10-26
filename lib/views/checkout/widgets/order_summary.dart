import 'package:flutter/material.dart';

class OrderSummary extends StatelessWidget {
  final double itemPrice;
  final int quantity;
  final bool isCartTotal;

  const OrderSummary({
    super.key,
    required this.itemPrice,
    required this.quantity,
    this.isCartTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = isCartTotal ? itemPrice : itemPrice * quantity;
    final total = subtotal + 15; // COD fee

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Items:", style: TextStyle(fontSize: 14)),
          Text("₹${subtotal.toStringAsFixed(2)}"),
        ]),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Delivery:", style: TextStyle(fontSize: 14)),
          Text("₹0.00"),
        ]),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            "Cash/Pay on Delivery fee",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 13,
              decoration: TextDecoration.underline,
            ),
          ),
          Text("₹15.00"),
        ]),
        const Divider(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text(
            "Order Total:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            "₹${total.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]),
      ],
    );
  }
}
