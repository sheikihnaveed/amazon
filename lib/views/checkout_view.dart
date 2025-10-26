import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';
import 'checkout/widgets/address_section.dart';
import 'checkout/widgets/checkout_header.dart';
import 'checkout/widgets/checkout_product_card.dart';
import 'checkout/widgets/order_summary.dart';
import 'checkout/widgets/success_view.dart';

class CheckoutView extends StatefulWidget {
  final List<Product> products;
  final Map<String, int> quantities;

  const CheckoutView({
    super.key,
    required this.products,
    required this.quantities,
  });

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  late Map<String, int> _quantities;

  @override
  void initState() {
    super.initState();
    _quantities = Map.from(widget.quantities);
  }

  double get subtotal {
    double total = 0.0;
    for (var product in widget.products) {
      total += product.price * _quantities[product.id]!;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    double orderTotal = subtotal + 15; // COD fee ₹15

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8E5E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Place Your Order - Amazon.in Checkout",
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CheckoutHeader(),
            const SizedBox(height: 12),

            // 🟡 Place Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  final cartProvider = Provider.of<CartProvider>(context, listen: false);

                  // Create an order document
                  final orderData = {
                    "userId": user.uid,
                    "items": widget.products.map((product) {
                      final qty = _quantities[product.id] ?? 1;
                      return {
                        "name": product.name,
                        "price": product.price,
                        "quantity": qty,
                        "imageUrl": product.imageUrl,
                      };
                    }).toList(),
                    "totalPrice": orderTotal,
                    "date": Timestamp.now(),
                    "status": "Placed",
                  };

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('orders')
                      .add(orderData);

                  // 🧹 Clear the cart after successful order
                  cartProvider.clearCart();

                  // Navigate to success page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderSuccessView()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFED813),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Place your order",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 10),

            OrderSummary(itemPrice: subtotal, quantity: 1, isCartTotal: true),

            const SizedBox(height: 20),

            const Text(
              "Paying with Pay on Delivery / Cash on Delivery",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 20),
            const AddressSection(),
            const SizedBox(height: 20),

            const Text(
              "Arriving 11 Nov 2025",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const Text(
              "FREE Standard Delivery",
              style: TextStyle(fontSize: 13, color: Colors.green),
            ),
            const SizedBox(height: 10),

            // 🛒 List all items in checkout
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final product = widget.products[index];
                final qty = _quantities[product.id] ?? 1;

                return CheckoutProductCard(
                  product: product,
                  quantity: qty,
                  onQuantityChanged: (newQty) {
                    setState(() {
                      _quantities[product.id] = newQty;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 30),
            OrderSummary(itemPrice: subtotal, quantity: 1, isCartTotal: true),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
