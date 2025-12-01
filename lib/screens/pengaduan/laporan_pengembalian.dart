import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart'; // Hapus ini karena tidak dipakai lagi
import 'package:project_rpll/services/pengembalian_service.dart';

class LaporanPengembalian extends StatelessWidget {
  const LaporanPengembalian({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PengembalianService()..fetchPengembalian(),
      child: Scaffold(
        backgroundColor: const Color(0xFF3B0E0E),
        body: SafeArea(
          child: Stack(
            children: [
              // BULATAN BACKGROUND
              Positioned(
                bottom: -60,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Laporan Pengembalian",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // DROPDOWN FILTER (UI Saja)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<String>(
                        borderRadius: BorderRadius.circular(10),
                        value: "Semua sekolah",
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: "Semua sekolah",
                            child: Text("Semua sekolah"),
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                    ),

                    const SizedBox(height: 25),

                    // LIST DATA
                    Expanded(
                      child: Consumer<PengembalianService>(
                        builder: (context, service, child) {
                          if (service.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          }
                          if (service.error != null) {
                            return Center(
                              child: Text(
                                "Error: ${service.error}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          if (service.list.isEmpty) {
                            return const Center(
                              child: Text(
                                "Belum ada data pengembalian.",
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: service.list.length,
                            itemBuilder: (context, index) {
                              final item = service.list[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1. Baris Nama Lembaga (Header)
                                    Row(
                                      children: [
                                        // Ikon Lokasi Merah sebagai penanda
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.location_on,
                                            size: 24,
                                            color: Color(0xFF8B0000),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Nama Lembaga
                                        Expanded(
                                          child: Text(
                                            item.namaLembaga,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),
                                    const Divider(
                                      height: 1,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 12),

                                    // 2. Baris Alamat
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.map,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item.alamatLembaga,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // 3. Baris Jumlah Pengembalian (Highlight)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.assignment_return,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Jumlah Kembali: ",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "${item.jumlahPenerima} Box",
                                          style: const TextStyle(
                                            color: Color(0xFF8B0000),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
}
