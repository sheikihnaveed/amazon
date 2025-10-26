import 'package:flutter/material.dart';

class AddressSection extends StatelessWidget {
  const AddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivering to Sheikh Naveed",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            "House no 105A, Kaka Sarai, Karan Nagar, Srinagar, Jammu & Kashmir, 190010, India",
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            "Change delivery address",
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Add delivery instructions",
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
