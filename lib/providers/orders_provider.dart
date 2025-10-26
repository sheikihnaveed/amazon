import 'package:flutter/material.dart';
import '../services/orders_service.dart';

class OrdersProvider extends ChangeNotifier {
  final OrdersService _service = OrdersService();

  bool isLoading = false;
  List<Map<String, dynamic>> orders = [];

  Future<void> loadOrders() async {
    isLoading = true;
    notifyListeners();

    try {
      orders = await _service.fetchOrders();
    } catch (e) {
      debugPrint("Error loading orders: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
