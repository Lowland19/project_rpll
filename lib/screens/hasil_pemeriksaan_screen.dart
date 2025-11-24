import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HasilPemeriksaanScreen extends StatefulWidget {
  const HasilPemeriksaanScreen({super.key, required this.imagePath});
  final String imagePath;

  @override
  State<HasilPemeriksaanScreen> createState() => _HasilPemeriksaanScreenState();
}

class _HasilPemeriksaanScreenState extends State<HasilPemeriksaanScreen> {
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _penerimaController = TextEditingController();
  bool _isLoading = false;

  Future<String?> uploadImage(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = 'menu_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Supabase.instance.client.storage
          .from('gambar')
          .upload(fileName, file);
      final imageUrl = Supabase.instance.client.storage
          .from('gambar')
          .getPublicUrl(fileName);
      print("Upload berhasil! Link: $imageUrl");
      return imageUrl;
    } catch (e) {
      print("Gagal upload: $e");
      return null;
    }
  }

  Future<void> _submitLaporan() async {
    if (_deskripsiController.text.isEmpty || _penerimaController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap isi semua kolom!')));
      return;
    }
    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      String? imageUrl = await uploadImage(widget.imagePath);
      if (imageUrl == null) {
        throw "Gagal mengupload gambar ke server.";
      }
      await supabase.from('laporan').insert({
        'gambar': imageUrl,
        'deskripsi': _deskripsiController.text,
        'penerima_manfaat': _penerimaController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaduan berhasil disimpan')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        print('$e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal:'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    _penerimaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isUploading = false;
    return Scaffold(
      appBar: AppBar(title: Text('Hasil Pemeriksaan')),
      body: Column(
        children: [
          Expanded(child: Image.file(File(widget.imagePath))),
          SizedBox(height: 16),
          TextFormField(
            controller: _deskripsiController,
            decoration: InputDecoration(
              labelText: 'Deskripsi keanehan pada MBG',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _penerimaController,
            decoration: InputDecoration(
              labelText: 'Lembaga penerima MBG',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _submitLaporan,
              child: Text("Upload Pengaduan"),
            ),
          ),
        ],
      ),
    );
  }
}
