// lib/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthController _controller = AuthController(AuthService());
  UserModel? user;

  bool isLoading = false;
  bool isInitializing = true;

  AuthProvider() {
    _initAuthListener();
  }

  /// 🔹 Keeps user signed in between app restarts
  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        user = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          displayName: firebaseUser.displayName,
        );

        final doc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
        final snapshot = await doc.get();

        if (!snapshot.exists) {
          await doc.set({
            'uid': user!.uid,
            'email': user!.email,
            'displayName': user!.displayName ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'isVerified': firebaseUser.emailVerified,
            'provider': firebaseUser.providerData.isNotEmpty
                ? firebaseUser.providerData.first.providerId
                : 'email',
          });
        }
      } else {
        user = null;
      }

      isInitializing = false;
      notifyListeners();
    });
  }

  // 🟢 Register with Email/Password
  Future<void> register(String email, String password, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = result.user;
      if (newUser != null) {
        await FirebaseFirestore.instance.collection('users').doc(newUser.uid).set({
          'uid': newUser.uid,
          'email': newUser.email,
          'displayName': '',
          'createdAt': FieldValue.serverTimestamp(),
          'isVerified': false,
          'provider': 'email',
        });

        await newUser.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent. Please check your inbox.'),
          ),
        );

        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnack(context, _getFirebaseAuthErrorMessage(e.code));
    } catch (_) {
      _showErrorSnack(context, 'Registration failed. Please try again.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🟡 Login with Email/Password
  Future<void> login(
      String email,
      String password, {
        required BuildContext context,
      }) async {
    isLoading = true;
    notifyListeners();

    try {
      user = await _controller.login(email, password);
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null && !firebaseUser.emailVerified) {
        await FirebaseAuth.instance.signOut();
        user = null;

        _showErrorSnack(context, 'Please verify your email before login.');
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(firebaseUser!.uid).update({
        'isVerified': true,
      });

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showErrorSnack(context, _getFirebaseAuthErrorMessage(e.code));
    } catch (_) {
      _showErrorSnack(context, 'Login failed. Please try again.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔵 Google Sign-In (with Firestore sync)
  Future<void> loginWithGoogle(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      user = await _controller.loginWithGoogle();
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);
        final snapshot = await userDoc.get();

        if (!snapshot.exists) {
          await userDoc.set({
            'uid': firebaseUser.uid,
            'email': firebaseUser.email,
            'displayName': firebaseUser.displayName ?? '',
            'photoUrl': firebaseUser.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'isVerified': true,
            'provider': 'google',
          });
        }

        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnack(context, _getFirebaseAuthErrorMessage(e.code));
    } catch (_) {
      _showErrorSnack(context, 'Google sign-in failed. Please try again.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔴 Logout
  Future<void> logout() async {
    await _controller.logout();
    user = null;
    notifyListeners();
  }

  /// 🧠 Reusable Firebase error handler
  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  /// 🧃 Helper for snackbars
  void _showErrorSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
