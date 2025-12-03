import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScanService {
  final supabase = Supabase.instance.client;

  Future<String> uploadImage(File file) async {
    final fileName = "pisang-${DateTime.now().millisecondsSinceEpoch}.jpg";

    final response = await supabase.storage
        .from('scan_pisang') // NAMA BUCKET BENAR HARUS SAMA
        .upload(fileName, file);

    final publicUrl = supabase.storage
        .from('scan_pisang')
        .getPublicUrl(fileName);

    return publicUrl;
  }


  Future<void> saveScanResult({
    required String imageUrl,
    required String hasil,
  }) async {
    await supabase.from("scan_pisang").insert({
      "image_url": imageUrl,
      "hasil": hasil,
      "created_at": DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllScans() async {
    return await supabase
        .from("scan_pisang")
        .select()
        .order("created_at", ascending: false);
  }
}

final scanService = ScanService();
