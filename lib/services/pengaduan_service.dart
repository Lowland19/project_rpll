import 'package:flutter/material.dart';
import 'package:project_rpll/models/pengembalian.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengaduanService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Pengembalian> _list = [];
  bool _isLoading = true;
  String? _error;

  List<Pengembalian> get list => _list;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPengembalian() async {
    _isLoading = true;
    notifyListeners();

    try {
      // QUERY RELASIONAL
      // Kita ambil data pengembalian DAN data lembaga sekaligus
      final response = await _supabase
          .from('pengembalian')
          .select('*, lembaga(nama_lembaga, alamat, jumlah_penerima)')
          .order('created_at', ascending: false);

      _list = (response as List).map((e) => Pengembalian.fromMap(e)).toList();
      _error = null;
    } catch (e) {
      _error = "Gagal ambil data: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
