import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? profileData;
  bool isLoading = false;

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();
      profileData = doc.data();
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _firestore.collection('users').doc(uid).update(updatedData);
      await loadProfile(); // refresh data
    } catch (e) {
      debugPrint("Error updating profile: $e");
    }
  }
}
