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

  // 🔥 Register + Simpan ke tabel `users`
  Future<String?> registerUser({
    required String email,
    required String password,
    required String username,
    required String alamat,
  }) async {
    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;

      if (user == null) {
        return 'Registrasi gagal';
      }

      // Simpan data ke tabel Supabase
      await Supabase.instance.client.from('users').insert({
        'id': user.id, // wajib cocok dengan auth.uid()
        'email': email,
        'username': username,
        'alamat': alamat,
        'role': 'pengguna', // opsional
      });

      return null; // success
    } catch (e) {
      return e.toString();
    }
  }

  // Ambil data user login
  Future<Map<String, dynamic>?> getUserData() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return null;

    final response = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', currentUser.id)
        .maybeSingle();

    return response;
  }

  Future<void> forgotPassword(String email) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.example.project_rpll://login-callback',
      );
    } catch (e) {
      throw Exception("Gagal mengirim reset password: $e");
    }
  }
}
