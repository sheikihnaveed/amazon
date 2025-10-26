import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'name': product.name,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'description': product.description,
      'quantity': quantity,
    };
  }

  static CartItem fromMap(Map<String, dynamic> map) {
    final product = Product(
      id: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
    );

    return CartItem(
      product: product,
      quantity: (map['quantity'] is int)
          ? map['quantity']
          : int.tryParse(map['quantity'].toString()) ?? 1,
    );
  }
}

class CartProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Map<String, CartItem> _cartItems = {};
  Map<String, CartItem> get cartItems => _cartItems;

  bool isLoading = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _cartSubscription;

  double get totalPrice {
    double total = 0.0;
    for (var item in _cartItems.values) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  /// Load Firestore cart and listen in real time
  Future<void> loadCart() async {
    final user = _auth.currentUser;
    await _cartSubscription?.cancel();
    _cartSubscription = null;

    if (user == null) {
      _cartItems.clear();
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final cartRef = _db.collection('users').doc(user.uid).collection('cart');

      _cartSubscription = cartRef.snapshots().listen(
            (snapshot) {
          _cartItems.clear();
          for (final doc in snapshot.docs) {
            final data = doc.data();

            try {
              final item = CartItem.fromMap(data);
              // ✅ use Firestore document ID (unique) as key, not product.id
              _cartItems[doc.id] = item;
            } catch (e) {
              debugPrint('Cart parse error: $e');
            }
          }

          isLoading = false;
          notifyListeners();
        },
        onError: (err) {
          debugPrint('Cart snapshot error: $err');
          isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('loadCart error: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  /// Add to cart — uses custom unique ID pattern like "fashion_1730023443"
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('User not signed in');
      return;
    }

    final cartRef = _db.collection('users').doc(user.uid).collection('cart');

    try {
      // 🔍 Step 1: Fetch all cart documents
      final existingDocs = await cartRef.get();

      // 🔍 Step 2: Try to find existing product by matching `ref_id` or fallback to name
      String? existingDocId;

      for (var doc in existingDocs.docs) {
        final data = doc.data();

        final existingRefId = data['ref_id'] ?? '';
        final existingName = data['name'] ?? '';

        // ✅ Prefer ref_id match if exists, fallback to name
        if (existingRefId == product.id || existingName == product.name) {
          existingDocId = doc.id;
          break;
        }
      }

      // 🧩 Step 3: If found → update quantity
      if (existingDocId != null) {
        await cartRef.doc(existingDocId).update({
          'quantity': FieldValue.increment(quantity),
        });
        debugPrint('✅ Quantity updated for existing item: ${product.name}');
      } else {
        // 🆕 Step 4: Create new document with unique ref_id
        final uniqueRefId =
            "${product.id}_${DateTime.now().millisecondsSinceEpoch}";

        await cartRef.doc(uniqueRefId).set({
          'ref_id': uniqueRefId, // ✅ unique for every cart item
          'productId': product.id,
          'name': product.name,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'description': product.description,
          'quantity': quantity,
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint('🆕 Added new item to cart: ${product.name}');
      }
    } catch (e) {
      debugPrint('❌ addToCart error: $e');

      // 🔄 Fallback local update
      if (_cartItems.containsKey(product.id)) {
        _cartItems[product.id]!.quantity += quantity;
      } else {
        _cartItems[product.id] = CartItem(product: product, quantity: quantity);
      }
      notifyListeners();
    }
  }

  /// Remove product by productId
  Future<void> removeFromCart(String productId) async {
    final user = _auth.currentUser;
    if (user == null) {
      _cartItems.remove(productId);
      notifyListeners();
      return;
    }

    try {
      final cartRef = _db.collection('users').doc(user.uid).collection('cart');
      final existing = await cartRef
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        await cartRef.doc(existing.docs.first.id).delete();
      }
    } catch (e) {
      debugPrint('removeFromCart error: $e');
    }

    _cartItems.remove(productId);
    notifyListeners();
  }

  Future<void> increaseQuantity(String productId) async {
    final user = _auth.currentUser;
    if (!_cartItems.containsKey(productId)) return;

    final current = _cartItems[productId]!;
    final newQty = current.quantity + 1;
    current.quantity = newQty;
    notifyListeners();

    if (user == null) return;

    try {
      final cartRef = _db.collection('users').doc(user.uid).collection('cart');
      final existing = await cartRef
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        await cartRef.doc(existing.docs.first.id).update({'quantity': newQty});
      }
    } catch (e) {
      debugPrint('increaseQuantity error: $e');
    }
  }

  Future<void> decreaseQuantity(String productId) async {
    final user = _auth.currentUser;
    if (!_cartItems.containsKey(productId)) return;

    final current = _cartItems[productId]!;
    if (current.quantity <= 1) {
      await removeFromCart(productId);
      return;
    }

    final newQty = current.quantity - 1;
    current.quantity = newQty;
    notifyListeners();

    if (user == null) return;

    try {
      final cartRef = _db.collection('users').doc(user.uid).collection('cart');
      final existing = await cartRef
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        await cartRef.doc(existing.docs.first.id).update({'quantity': newQty});
      }
    } catch (e) {
      debugPrint('decreaseQuantity error: $e');
    }
  }

  Future<void> clearCart() async {
    final user = _auth.currentUser;
    _cartItems.clear();
    notifyListeners();

    if (user == null) return;

    try {
      final cartRef = _db.collection('users').doc(user.uid).collection('cart');
      final snap = await cartRef.get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('clearCart error: $e');
    }
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}
