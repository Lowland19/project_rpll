import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/lembaga_service.dart'; // Pastikan import service benar     // Pastikan import model benar

class DaftarPenerimaScreen extends StatelessWidget {
  const DaftarPenerimaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. PANGGIL SERVICE
    return ChangeNotifierProvider(
      create: (_) =>
          LembagaService()..fetchDataPenerima(), // Panggil fetch otomatis
      child: Scaffold(
        backgroundColor: const Color(0xFF3B0E0E),
        body: SafeArea(
          child: Stack(
            children: [
              // --- BACKGROUND HIASAN ---
              Positioned(
                bottom: -40,
                left: -50,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(40, 255, 0, 0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    // --- HEADER (BACK BUTTON) ---
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Daftar Penerima",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // --- LIST DATA (MENGGUNAKAN SERVICE) ---
                    Expanded(
                      child: Consumer<LembagaService>(
                        builder: (context, service, child) {
                          // A. LOADING
                          if (service.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          }

                          // B. ERROR
                          if (service.errorMessage != null) {
                            return Center(
                              child: Text(
                                service.errorMessage!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          // C. KOSONG
                          if (service.listLembaga.isEmpty) {
                            return const Center(
                              child: Text(
                                "Belum ada data penerima.",
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          }

                          // D. ADA DATA -> LIST VIEW
                          return ListView.builder(
                            itemCount: service.listLembaga.length,
                            itemBuilder: (context, index) {
                              final item = service.listLembaga[index];
                              return _penerimaTile(
                                nama: item.namaLembaga,
                                jumlah: item.jumlahPenerima,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET TILE ---
  Widget _penerimaTile({required String nama, required int jumlah}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF5A0E0E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAMA LEMBAGA
                Text(
                  nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // JUMLAH PENERIMA
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.white70, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      "Jumlah: $jumlah",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
