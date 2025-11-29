import 'package:flutter/material.dart';
import 'package:project_rpll/models/lembaga.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LembagaService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // State Variables
  List<Lembaga> _listLembaga = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  List<Lembaga> get listLembaga => _listLembaga;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- FUNGSI FETCH DATA ---
  Future<void> fetchDataPenerima() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Query semua data lembaga
      final response = await _supabase
          .from('lembaga')
          .select()
          .eq('jenis_lembaga', 'Penerima Manfaat')
          .order('nama_lembaga', ascending: true); // Urutkan A-Z

      // Konversi ke List Model
      _listLembaga = (response as List)
          .map((item) => Lembaga.fromMap(item))
          .toList();

      _errorMessage = null;
    } catch (e) {
      debugPrint("Error Fetch Lembaga: $e");
      _errorMessage = "Gagal memuat data lembaga.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
