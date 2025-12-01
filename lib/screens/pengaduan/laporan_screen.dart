import 'package:flutter/material.dart';
import 'package:project_rpll/services/pengaduan_service.dart';
import 'package:provider/provider.dart';
import 'package:project_rpll/screens/pengaduan/detil_laporan.dart';

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. PANGGIL SERVICE
    return ChangeNotifierProvider(
      create: (_) => LaporanService()..fetchLaporan(),
      child: Scaffold(
        backgroundColor: const Color(0xFF3B0E0E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF5A0E0E),
          title: const Text(
            'Menu Pengaduan',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Stack(
          children: [
            // Hiasan Background
            Positioned(
              top: -40,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: Color(0xFF5A0E0E),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // 2. GUNAKAN CONSUMER
            Consumer<LaporanService>(
              builder: (context, service, child) {
                // A. Loading
                if (service.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                // B. Error
                if (service.errorMessage != null) {
                  return Center(
                    child: Text(
                      service.errorMessage!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                // C. Kosong
                if (service.listLaporan.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada laporan.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                // D. Ada Data -> ListView
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: service.listLaporan.length,
                  itemBuilder: (context, index) {
                    final item =
                        service.listLaporan[index]; // item adalah LaporanModel

                    return Card(
                      color: const Color(0xFF5A0E0E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        // Gunakan data dari Model
                        title: Text(
                          item.namaLembaga, // Tampilkan Nama Lembaga (bukan penerima manfaat)
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Penerima: ${item.penerimaManfaat}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: (item.gambarUrl.isNotEmpty)
                                ? Image.network(
                                    item.gambarUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(
                                      Icons.broken_image,
                                      color: Colors.white,
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey,
                                    child: const Icon(Icons.image),
                                  ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DetilLaporan(),
                              // Kirim ID Laporan ke halaman detail
                              settings: RouteSettings(arguments: item.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
