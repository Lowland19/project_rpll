import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_rpll/services/jadwal_service.dart';

class PetaService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final JadwalService _jadwalService = JadwalService();

  /// Fungsi untuk mencari data rute spesifik milik user yang login
  Future<Map<String, dynamic>?> cariRuteSaya() async {
    try {
      // 1. Ambil ID User yang sedang login
      final String? userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw "User belum login.";

      // 2. Cari Sekolah yang 'id_pengguna_terkait'-nya adalah User ini
      final dataSekolah = await _supabase
          .from('lembaga')
          .select('nama_lembaga')
          .eq('id_pengguna_terkait', userId)
          .maybeSingle();

      if (dataSekolah == null) {
        throw "Akun Anda tidak terdaftar sebagai penanggungjawab di sekolah manapun.";
      }

      final String namaSekolahSaya = dataSekolah['nama_lembaga'];

      // 3. Ambil Jadwal Pengiriman Hari Ini (Panggil dari JadwalService yang sudah ada)
      final List<Map<String, dynamic>> semuaJadwal = await _jadwalService
          .getJadwalHarian();

      if (semuaJadwal.isEmpty) {
        throw "Belum ada jadwal pengiriman yang dibuat admin hari ini.";
      }

      // 4. Filter: Cari jadwal yang namanya SAMA dengan sekolah user
      // Kita gunakan firstWhere. Jika tidak ketemu, dia akan throw error StateError
      final jadwalSaya = semuaJadwal.firstWhere(
        (item) =>
            item['nama'].toString().toLowerCase() ==
            namaSekolahSaya.toLowerCase(),
        orElse: () =>
            {}, // Return map kosong jika tidak ketemu (untuk dicek di bawah)
      );

      if (jadwalSaya.isEmpty) {
        throw "Tidak ada jadwal pengiriman ke $namaSekolahSaya hari ini.";
      }

      return jadwalSaya;
    } catch (e) {
      // Lempar error agar bisa ditangkap UI
      rethrow;
    }
  }
}
