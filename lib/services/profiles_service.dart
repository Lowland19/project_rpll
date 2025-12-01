import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_rpll/models/profiles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- STATE (Data yang akan dipakai UI) ---
  Profiles? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  // --- STATE KHUSUS EDIT ---
  bool _isSaving = false;
  File? _tempImageFile; // Foto sementara saat diedit
  double? _tempLat; // Koordinat sementara saat diedit
  double? _tempLong; // Koordinat sementara saat diedit

  // --- GETTERS (Cara UI mengakses data) ---
  Profiles? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  File? get tempImageFile => _tempImageFile;
  double? get tempLat => _tempLat;
  double? get tempLong => _tempLong;

  bool hasRole(List<String> allowedRoles) {
    if (_userProfile == null) return false;
    return _userProfile!.roles.any((role) => allowedRoles.contains(role));
  }

  // --- FUNGSI UTAMA: AMBIL DATA ---
  Future<void> fetchUserProfile() async {
    _setLoading(true);

    final user = _supabase.auth.currentUser;
    if (user == null) {
      _setError("User belum login");
      return;
    }

    try {
      // Query ke Database
      final data = await _supabase
          .from('profiles')
          .select(
            'id, username, avatar_url, alamat, lembaga, jumlah_penerima, latitude, longitude, user_roles(roles(nama_role))',
          )
          .eq('id', user.id)
          .single();

      _tempLat = _userProfile?.latitude;
      _tempLong = _userProfile?.longitude;

      // Konversi JSON -> Model
      _userProfile = Profiles.fromMap(data, user.email ?? '-');
      _resetEditState();
      _errorMessage = null; // Reset error jika berhasil
    } catch (e) {
      print("Error Fetch Profile: $e");
      _setError("Gagal memuat profil");
    } finally {
      _setLoading(false);
    }
  }

  void _resetEditState() {
    _tempImageFile = null;
    _tempLat = _userProfile?.latitude;
    _tempLong = _userProfile?.longitude;
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _tempImageFile = File(image.path);
      notifyListeners(); // Update UI EditProfile biar gambarnya berubah
    }
  }

  void updateTempCoordinates(double lat, double long) {
    _tempLat = lat;
    _tempLong = long;
    notifyListeners();
  }

  void clearData() {
    _userProfile = null; // Hapus data user
    _tempImageFile = null;
    _tempLat = null;
    _tempLong = null;
    _isLoading = true; // Set loading agar user berikutnya melihat loading dulu
    _errorMessage = null;

    notifyListeners(); // Kabari UI untuk update (jadi kosong/loading)
  }

  // Helper untuk update UI
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // Kabari UI bahwa loading berubah
  }

  void _setError(String msg) {
    _errorMessage = msg;
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> saveProfile({
    required String name,
    required String password,
    required String email,
    required String alamat,
    required String lembaga,
    required String jumlahPenerimaStr,
  }) async {
    _isSaving = true;
    notifyListeners();

    final user = _supabase.auth.currentUser;
    if (user == null) return "User tidak login";

    try {
      // A. Validasi
      if (name.length < 3) throw "Nama terlalu pendek";

      // B. Update Auth (Email/Pass)
      UserAttributes attributes = UserAttributes();
      bool needUpdateAuth = false;

      if (password.isNotEmpty && password.length >= 6) {
        attributes.password = password;
        needUpdateAuth = true;
      }
      if (email.isNotEmpty && email != user.email) {
        attributes.email = email;
        needUpdateAuth = true;
      }
      if (needUpdateAuth) await _supabase.auth.updateUser(attributes);

      // C. Upload Avatar (Jika ada file baru di _tempImageFile)
      String? newAvatarUrl;
      if (_tempImageFile != null) {
        final fileName =
            'avatar_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _supabase.storage
            .from('profile_picture')
            .upload(fileName, _tempImageFile!);
        newAvatarUrl = _supabase.storage
            .from('profile_picture')
            .getPublicUrl(fileName);
      }

      // D. Update Database
      final updates = {
        'username': name,
        'alamat': alamat,
        'lembaga': lembaga,
        'jumlah_penerima': int.tryParse(jumlahPenerimaStr) ?? 0,
        'latitude': _tempLat, // Ambil dari temp state
        'longitude': _tempLong, // Ambil dari temp state
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (newAvatarUrl != null) updates['avatar_url'] = newAvatarUrl;

      await _supabase.from('profiles').update(updates).eq('id', user.id);

      // E. REFRESH DATA (PENTING!)
      // Agar tampilan di AccountWidget ikut berubah otomatis
      await fetchUserProfile();

      return null; // Sukses
    } catch (e) {
      return e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // --- 1. FUNGSI AMBIL DATA LEMBAGA ---
  Future<Map<String, dynamic>?> fetchLembagaData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      // Cari lembaga yang 'id_pengguna_terkait'-nya sama dengan user login
      final response = await _supabase
          .from('lembaga')
          .select()
          .eq('id_pengguna_terkait', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint("Gagal ambil data lembaga: $e");
      return null;
    }
  }

  // --- 2. FUNGSI UPDATE DATA LEMBAGA (Saat tombol Simpan ditekan) ---
  Future<void> updateLembagaData({
    required String namaLembaga,
    required String alamat,
    required int jumlahPenerima,
    double? lat,
    double? long,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Update tabel lembaga berdasarkan user login
    await _supabase
        .from('lembaga')
        .update({
          'nama_lembaga': namaLembaga,
          'alamat': alamat,
          'jumlah_penerima': jumlahPenerima,
          'latitude': lat,
          'longitude': long,
        })
        .eq('id_pengguna_terkait', userId);
  }
}
