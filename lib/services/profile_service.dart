import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>?> getProfile() async {
    if (currentUser == null) return null;
    final doc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('profile')
        .doc('info')
        .get();
    if (!doc.exists) {
      // Auto-create default profile if missing
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('profile')
          .doc('info')
          .set({
        'name': currentUser!.displayName ?? 'New User',
        'email': currentUser!.email,
        'address': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return {
        'name': currentUser!.displayName ?? 'New User',
        'email': currentUser!.email,
        'address': '',
      };
    }
    return doc.data();

  }

  Future<void> updateProfile(String name, String address) async {
    if (currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('profile')
        .doc('info')
        .set({
      'name': name,
      'email': currentUser!.email,
      'address': address,
    }, SetOptions(merge: true));
  }

  Future<void> signOut() async => _auth.signOut();
}
