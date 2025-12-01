import 'package:flutter/material.dart';
import 'package:project_rpll/models/laporan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LaporanService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- STATE LIST (Untuk Halaman Utama) ---
  List<Laporan> _listLaporan = [];

  // --- STATE DETAIL (Untuk Halaman Detail) ---
  Laporan? _detailLaporan;

  bool _isLoading = false; // Default false biar aman
  String? _errorMessage;

  // Getters
  List<Laporan> get listLaporan => _listLaporan;
  Laporan? get detailLaporan => _detailLaporan; // Getter baru
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- 1. FETCH SEMUA LAPORAN (LIST) ---
  Future<void> fetchLaporan() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('laporan')
          .select('*, lembaga(nama_lembaga)')
          .order('created_at', ascending: false);

      _listLaporan = (response as List)
          .map((item) => Laporan.fromMap(item))
          .toList();

      _errorMessage = null;
    } catch (e) {
      debugPrint("Error Fetch List: $e");
      _errorMessage = "Gagal memuat daftar laporan.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. FETCH DETAIL LAPORAN BY ID (BARU) ---
  Future<void> fetchDetailLaporan(int id) async {
    _isLoading = true;
    _detailLaporan = null; // Reset data lama biar gak kedip
    notifyListeners();

    try {
      final response = await _supabase
          .from('laporan')
          .select('*, lembaga(nama_lembaga)') // Join tabel lembaga
          .eq('id', id)
          .single(); // Ambil satu baris saja

      _detailLaporan = Laporan.fromMap(response);
      _errorMessage = null;
    } catch (e) {
      debugPrint("Error Fetch Detail: $e");
      _errorMessage = "Gagal memuat detail laporan.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
