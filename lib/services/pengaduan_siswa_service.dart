import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengaduanSiswaService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String,dynamic>>> fetchDaftarLembaga() async {
    try{
      final data = await _supabase.from('lembaga').select('id,nama_lembaga').order('nama_lembaga');
      return List<Map<String,dynamic>>.from(data);
    } catch (e) {
      debugPrint('Error dalam mengambil data lembaga: $e');
      return [];
    }
  }

  Future<String?> kirimLaporan({
    required File fotoBukti,
    required String deskripsi,
    required int idLembaga, // ID Sekolah yang dipilih dari Dropdown
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return "User belum login";

    try {
      final fileName = 'laporan_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage.from('gambar').upload(fileName, fotoBukti);
      final imageUrl = _supabase.storage.from('gambar').getPublicUrl(fileName);

      await _supabase.from('laporan').insert({
        'id_lembaga_pengirim': idLembaga, 
        'deskripsi': deskripsi,
        'gambar': imageUrl,
      });

      return null; // Sukses (null artinya tidak ada error)

    } catch (e) {
      debugPrint("Gagal Kirim Laporan: $e");
      return "Gagal mengirim laporan: $e";
    }
  }
}