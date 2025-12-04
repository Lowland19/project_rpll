import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScanService {
  final supabase = Supabase.instance.client;

  Future<String> uploadImage(File file) async {
    final fileName = "pisang-${DateTime.now().millisecondsSinceEpoch}.jpg";

    final storage = supabase.storage.from('scan_pisang');

    try {
      await storage.upload(
        fileName,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      return storage.getPublicUrl(fileName);
    } catch (e) {
      throw Exception("Gagal upload gambar: $e");
    }
  }

  Future<void> saveScanResult({
    required String imageUrl,
    required String hasil,
    required double confidence,
  }) async {
    try {
      await supabase.from("scan_pisang").insert({
        "image_url": imageUrl,
        "hasil": hasil,
        "confidence": confidence,
        "created_at": DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception("Gagal menyimpan ke database: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAllScans() async {
    try {
      final response = await supabase
          .from("scan_pisang")
          .select()
          .order("created_at", ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception("Gagal mengambil data scan: $e");
    }
  }
}

final scanService = ScanService();
