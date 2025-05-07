import 'package:flutter_hackathon/modele/user.dart';
import '../services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;
  User? _currentUser;

  AuthController(this._authService);

  User? get currentUser => _currentUser;
  String? get token => _currentUser?.token;

  Future<User> login(String email, String password) async {
    try {
      _currentUser = await _authService.login(email, password);
      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> register(String name, String email, String password) async {
    try {
      _currentUser = await _authService.register(name, email, password);
      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> checkAuth() async {
    if (_currentUser?.token != null) {
      _currentUser = await _authService.checkAuth(_currentUser!.token!);
    }
    return _currentUser;
  }

  Future<void> logout() async {
    if (_currentUser?.token != null) {
      await _authService.logout(_currentUser!.token!);
    }
    _currentUser = null;
  }
}