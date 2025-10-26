import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrdersList extends StatelessWidget {
  final Stream<QuerySnapshot>? ordersStream;
  const OrdersList({super.key, this.ordersStream});

  @override
  Widget build(BuildContext context) {
    if (ordersStream == null) {
      return const Text('No orders yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text('Your Orders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: ordersStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Text('No orders yet.');
            }
            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final items = data['items'] as List;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: items.isNotEmpty
                        ? Image.network(items.first['imageUrl'],
                        width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.shopping_bag_outlined),
                    title: Text(
                      '₹${data['totalPrice']} • ${data['status']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${items.length} item(s) • ${data['date'].toDate()}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
