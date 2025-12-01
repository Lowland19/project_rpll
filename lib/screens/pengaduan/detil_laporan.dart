import 'package:flutter/material.dart';
import 'package:project_rpll/services/pengaduan_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Jangan lupa: flutter pub add intl

class DetilLaporan extends StatelessWidget {
  const DetilLaporan({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil ID dari argument navigasi
    final id = ModalRoute.of(context)!.settings.arguments as int;

    // 2. Inisialisasi Service & Panggil Fetch Detail
    return ChangeNotifierProvider(
      create: (_) => LaporanService()..fetchDetailLaporan(id),
      child: Scaffold(
        backgroundColor: const Color(0xFF3B0E0E), // Warna Tema
        appBar: AppBar(
          backgroundColor: const Color(0xFF5A0E0E),
          title: const Text(
            'Detail Laporan',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            // --- BACKGROUND HIASAN (Lingkaran) ---
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: Color(0xFF5A0E0E),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // --- KONTEN DATA (Consumer) ---
            Consumer<LaporanService>(
              builder: (context, service, child) {
                // A. LOADING
                if (service.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                // B. ERROR
                if (service.errorMessage != null) {
                  return Center(
                    child: Text(
                      "Error: ${service.errorMessage}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                // C. DATA KOSONG / NULL
                final data = service.detailLaporan;
                if (data == null) {
                  return const Center(
                    child: Text(
                      "Data tidak ditemukan",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                // D. TAMPILAN DATA (UI UTAMA)
                // Format tanggal agar rapi
                String formattedDate = DateFormat(
                  'dd MMMM yyyy, HH:mm',
                ).format(data.tanggalPelaporan);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- KOTAK INFORMASI TEKS ---
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5A0E0E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white12,
                          ), // Tambahan border tipis biar rapi
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nama Lembaga (Judul)
                            Text(
                              data.namaLembaga, // Dari Relasi Service
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),
                            const Divider(
                              color: Colors.white24,
                            ), // Garis pemisah
                            const SizedBox(height: 8),

                            const SizedBox(height: 12),

                            const SizedBox(height: 12),

                            // Tanggal
                            _buildInfoRow("Tanggal", formattedDate),

                            const SizedBox(height: 20),

                            // Deskripsi
                            const Text(
                              "Deskripsi:",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data.deskripsi,
                              style: const TextStyle(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- GAMBAR BUKTI ---
                      if (data.gambarUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            data.gambarUrl,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: 250,
                                color: Colors.black12,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (ctx, err, stack) => Container(
                              height: 200,
                              color: Colors.white10,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk baris teks
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ", style: const TextStyle(color: Colors.white70)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
