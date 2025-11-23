import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<void> login({required String email, required String password}) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      _user = response.user;
      notifyListeners();
    } else {
      throw Exception('Login failed');
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<String?> registerUser({
    required String email,
    required String password,
    required String username,
    required String full_name,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username, 'full_name': full_name},
      );
      if (response.user != null) {
        return null;
      } else {
        return 'Registration failed';
      }
    } catch (e) {
      return e.toString();
    }
  }
}
