import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  // LOGIN
  Future<void> login({required String email, required String password}) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      _user = response.user;
      notifyListeners();
    } else {
      throw Exception("Login gagal");
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    _user = null;
    notifyListeners();
  }

  // REGISTER + SIMPAN KE TABEL PROFILES
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
      if (user == null) return "Registrasi gagal";

      // Simpan ke tabel profiles
      await Supabase.instance.client.from("profiles").insert({
        "id": user.id,
        "email": email,
        "username": username,
        "alamat": alamat,
      });

      return null; // sukses
    } catch (e) {
      return e.toString();
    }
  }

  // GET USER PROFILE
  Future<Map<String, dynamic>?> getUserData() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return null;

    final response = await Supabase.instance.client
        .from("profiles")
        .select()
        .eq("id", currentUser.id)
        .maybeSingle();

    return response;
  }

  // RESET PASSWORD (EMAIL LINK)
  Future<void> forgotPassword(String email) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception("Gagal mengirim email reset password: $e");
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      final res = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (res.user != null) {
        _user = res.user;          // UPDATE USER DI PROVIDER
        notifyListeners();         // BERITAHU UI ADA PERUBAHAN
      } else {
        throw Exception("Gagal mengganti password.");
      }
    } catch (e) {
      throw Exception("Gagal mengganti password: $e");
    }
  }

}
