import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DaftarPenerimaScreen extends StatefulWidget {
  const DaftarPenerimaScreen({super.key});

  @override
  State<DaftarPenerimaScreen> createState() => _DaftarPenerimaScreenState();
}

class _DaftarPenerimaScreenState extends State<DaftarPenerimaScreen> {
  List<Map<String, dynamic>> _dafterPenerima = [];
  bool _isLoading = true;
  String? _errorMsg;

  Future<void> _fetchDataPenerima() async {
    final supabase = Supabase.instance.client;
    try {
      final data = await supabase
          .from('profiles')
          .select(
            ' lembaga, jumlah_penerima, alamat, avatar_url, user_roles!inner(roles!inner(nama_role))',
          )
          .eq('user_roles.roles.nama_role', 'penanggungjawab_mbg')
          .order('lembaga', ascending: true);
      if (mounted) {
        setState(() {
          _dafterPenerima = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error $e');
      if (mounted) {
        setState(() {
          _errorMsg = 'Gagal muat data: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDataPenerima();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Lingkaran
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                children: [
                  // Header Back
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

                  // --- PERBAIKAN LOGIKA TAMPILAN ---
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : _errorMsg != null
                        ? Center(
                            child: Text(
                              _errorMsg!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                        : _dafterPenerima.isEmpty
                        ? const Center(
                            child: Text(
                              "Belum ada data penerima.",
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _dafterPenerima.length,
                            itemBuilder: (context, index) {
                              final item = _dafterPenerima[index];
                              return penerimaTile(
                                // Gunakan ?? agar tidak error jika data null
                                nama:
                                    item["lembaga"] ??
                                    item["full_name"] ??
                                    "Nama Tidak Ada",
                                jumlah: item["jumlah_penerima"] ?? 0,
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
    );
  }

  Widget penerimaTile({required String nama, required int jumlah}) {
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
                Text(
                  nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Tampilkan Jumlah
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

                // Jarak dihapus sesuai permintaan sebelumnya
              ],
            ),
          ),
        ],
      ),
    );
  }
}
