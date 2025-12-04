import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project_rpll/screens/home_screen.dart';
import 'package:project_rpll/screens/pengaduan/kamera_pengaduan_screen.dart';
import 'package:project_rpll/services/pengaduan_siswa_service.dart';

class PengaduanScreen extends StatefulWidget {
  const PengaduanScreen({super.key, this.imagePath});
  final String? imagePath;

  @override
  State<PengaduanScreen> createState() => _PengaduanScreenState();
}

class _PengaduanScreenState extends State<PengaduanScreen> {
  final formController = GlobalKey<FormState>();
  late TextEditingController pengaduanController;
  final PengaduanSiswaService _pengaduanSiswaService = PengaduanSiswaService();
  List<Map<String, dynamic>> _listLembaga = [];
  int? _selectedLembagaId;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    pengaduanController = TextEditingController(); // Inisialisasi di sini
    _loadDataLembaga();
  }

  @override
  void dispose() {
    pengaduanController.dispose();
    super.dispose();
  }

  Future<void> _loadDataLembaga() async {
    final data = await _pengaduanSiswaService.fetchDaftarLembaga();

    if (mounted) {
      setState(() {
        _listLembaga = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleKirimPengaduan() async {
    // Validasi Gambar (Wajib ada)
    if (widget.imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap sertakan bukti gambar!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mulai Loading Submit
    setState(() {
      _isSubmitting = true;
    });

    // Panggil Service
    final result = await _pengaduanSiswaService.kirimLaporan(
      fotoBukti: File(widget.imagePath!), // Konversi path string ke File
      deskripsi: pengaduanController.text,
      idLembaga: _selectedLembagaId!,
    );

    // Selesai Loading
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      // Cek Hasil
      if (result == null) {
        // Sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dikirim!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      } else {
        // Gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menu Pengaduan (Siswa)',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF5A0E0E),
      ),
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(color: Color(0xFF3B0E0E))),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: widget.imagePath != null
                        ? null
                        : () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => KameraPengaduanScreen(),
                                ),
                              );
                            });
                            debugPrint('Berhasil disimpan');
                          },
                    label: Text(
                      widget.imagePath != null
                          ? "Sudah terisi"
                          : 'Kirim bukti gambar',
                    ),
                    icon: Icon(Icons.camera),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: pengaduanController,
                    maxLines: 5,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Deskripsi masalah',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : DropdownButtonFormField<int>(
                          value: _selectedLembagaId,
                          dropdownColor: const Color(0xFF5A0E0E),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Pilih Lembaga/Sekolah',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.white54,
                              ),
                            ),
                          ),
                          items: _listLembaga.map((item) {
                            return DropdownMenuItem<int>(
                              value: item['id'],
                              child: Text(
                                item['nama_lembaga'] ?? 'Tanpa Nama',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLembagaId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Harap pilih lembaga' : null,
                        ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _isSubmitting ? null : _handleKirimPengaduan();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    label: const Text('Kirim pengaduan'),
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
