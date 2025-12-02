import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_rpll/services/pisang_service.dart';
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

  final PisangService _classifier = PisangService();
  bool _isAnalyzing = true;
  String _hasilAnalisis = "Sedang menganalisis...";

  // VARIBEL BARU: Untuk menyimpan ID Lembaga (Integer)
  int? _idLembagaPengirim;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
    _getLembagaData(); // <--- PANGGIL FUNGSI INI DI AWAL
  }

  // --- 1. FUNGSI BARU: AMBIL ID LEMBAGA DARI USER LOGIN ---
  Future<void> _getLembagaData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      try {
        // Query ke tabel 'lembaga' cari yang punya id_pengguna_terkait sama dengan user login
        final data = await Supabase.instance.client
            .from('lembaga')
            .select('id, nama_lembaga') // Ambil ID dan Namanya
            .eq(
              'id_pengguna_terkait',
              user.id,
            ) // Sesuaikan dengan kolom di DB kamu
            .single();

        if (mounted) {
          setState(() {
            _idLembagaPengirim =
                data['id']; // Simpan ID integer untuk dikirim ke DB
            _penerimaController.text =
                data['nama_lembaga']; // Tampilkan Namanya di UI
          });
        }
      } catch (e) {
        debugPrint("Gagal mengambil data lembaga: $e");
        // Handle jika user login tapi belum punya data di tabel lembaga
      }
    }
  }

  Future<void> _analyzeImage() async {
    await _classifier.loadModel();
    File image = File(widget.imagePath);
    String result = await _classifier.predict(image);

    if (mounted) {
      setState(() {
        _hasilAnalisis = result;
        _isAnalyzing = false;
        _deskripsiController.text = "Terdeteksi: $result";
      });
    }
  }

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
      return imageUrl;
    } catch (e) {
      print("Gagal upload: $e");
      return null;
    }
  }

  Future<void> _submitLaporan() async {
    // Cek apakah ID Lembaga sudah didapatkan
    if (_idLembagaPengirim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data Lembaga pengirim tidak ditemukan!')),
      );
      return;
    }

    if (_deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap isi deskripsi!')));
      return;
    }

    final supabase = Supabase.instance.client;

    try {
      String? imageUrl = await uploadImage(widget.imagePath);
      if (imageUrl == null) throw "Gagal mengupload gambar ke server.";

      // --- 2. MODIFIKASI INSERT DATABASE ---
      await supabase.from('laporan').insert({
        'gambar': imageUrl,
        'deskripsi': _deskripsiController.text,
        // Masukkan ID Lembaga (Integer) yang didapat otomatis tadi
        'id_lembaga_pengirim': _idLembagaPengirim,
        // Tanggal pelaporan otomatis (opsional, jika di DB belum default now())
        'tanggal_pelaporan': DateTime.now().toIso8601String(),
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
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    _penerimaController.dispose();
    _classifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Pemeriksaan')),
      body: SingleChildScrollView(
        // Tambahkan SingleChildScrollView agar tidak overflow
        child: Column(
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _deskripsiController,
                    maxLines: 3, // Biar lebih lega buat deskripsi
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Masalah',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Field Nama Lembaga (Read Only / Tidak bisa diedit manual)
                  TextFormField(
                    controller: _penerimaController,
                    readOnly: true, // <--- KUNCI AGAR TIDAK DIEDIT MANUAL
                    decoration: InputDecoration(
                      labelText: 'Lembaga Pengirim (Otomatis)',
                      filled: true,
                      fillColor: Colors
                          .grey[200], // Beri warna abu agar terlihat disabled
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAnalyzing ? null : _submitLaporan,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isAnalyzing
                          ? const Text("Menganalisis Gambar...")
                          : const Text("Kirim Laporan"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
