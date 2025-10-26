import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthController {
  final AuthService _authService;

  AuthController(this._authService);

  Future<UserModel?> login(String email, String password) async {
    return await _authService.signInWithEmail(email, password);
  }

  Future<UserModel?> register(String email, String password) async {
    final user = await _authService.registerWithEmail(email, password);

    if (user != null) {
      await _authService.sendEmailVerification();
    }

    return user;
  }


  Future<UserModel?> loginWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  UserModel? get currentUser => _authService.currentUser;
}
