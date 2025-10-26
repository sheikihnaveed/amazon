import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'package:amazon/views/checkout/checkout_view.dart';

import 'checkout_view.dart';


class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8E5E5),
        title: const Text(
          "Cart",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        elevation: 0,
      ),
      body: cart.cartItems.isEmpty
          ? const Center(
        child: Text(
          "Your cart is empty",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      )
          : Column(
        children: [
          // 🧾 Subtotal (Sticky Top)
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black12, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Subtotal ₹${cart.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFED813),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (cart.cartItems.isEmpty) return;

                      final products = cart.cartItems.values.map((e) => e.product).toList();
                      final quantities = {
                        for (var e in cart.cartItems.values) e.product.id: e.quantity
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutView(
                            products: products,
                            quantities: quantities,
                          ),
                        ),
                      );
                    },


                    child: Text(
                      "Proceed to Buy (${cart.cartItems.length} item${cart.cartItems.length > 1 ? 's' : ''})",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ),
                ),
              ],
            ),
          ),

          // 🛒 Product List Scrollable
          Expanded(
            child: ListView.builder(
              itemCount: cart.cartItems.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final entry = cart.cartItems.entries.toList()[index];
                final cartDocId = entry.key; // ✅ Firestore document ID
                final item = entry.value;
                final product = item.product;

                return Card(
                  elevation: 0,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🖼️ Product Info Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.imageUrl,
                                height: 100,
                                width: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹${product.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "In stock",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Row(
                                    children: [
                                      Text("Sold by ", style: TextStyle(fontSize: 13)),
                                      Text(
                                        "D. R. GROUP",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    "10 days Replacement",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ➕ Quantity Controls and Buttons
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // 🔢 Quantity control
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.yellow.shade700,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.black87,
                                      ),
                                      onPressed: () {
                                        cart.decreaseQuantity(cartDocId);
                                      },
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        "${item.quantity}",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.black87,
                                      ),
                                      onPressed: () {
                                        cart.increaseQuantity(cartDocId);
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              // 🗑️ Delete Button
                              OutlinedButton(
                                onPressed: () => cart.removeFromCart(cartDocId),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  side: const BorderSide(color: Colors.grey, width: 1),
                                ),
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // 💾 Save for Later Button
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  side: const BorderSide(color: Colors.grey, width: 1),
                                ),
                                child: const Text(
                                  "Save for later",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),


          // 💰 Sticky Footer
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, -1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Items:",
                        style: TextStyle(
                            fontSize: 14, color: Colors.black87)),
                    Text(
                      "₹${cart.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Delivery:",
                        style: TextStyle(
                            fontSize: 14, color: Colors.black87)),
                    Text("₹0.00",
                        style:
                        TextStyle(fontSize: 14, color: Colors.black)),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Order Total:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "₹${cart.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
