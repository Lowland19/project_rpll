import 'package:flutter/material.dart';
import 'package:project_rpll/services/jadwal_service.dart';
import 'rute_perkiraan_waktu.dart';

class JadwalPengirimanScreen extends StatefulWidget {
  const JadwalPengirimanScreen({super.key});

  @override
  State<JadwalPengirimanScreen> createState() => _JadwalPengirimanScreenState();
}

class _JadwalPengirimanScreenState extends State<JadwalPengirimanScreen> {
  // 1. INSTANSIASI SERVICE
  final JadwalService _service = JadwalService();

  // State Variables
  List<Map<String, dynamic>> _allJadwalList = []; // Menyimpan SEMUA data
  List<Map<String, dynamic>> _filteredList =
      []; // Menyimpan data yang DITAMPILKAN
  bool _isLoading = true;
  String? _errorMsg;

  // Filter
  String selectedFilter = "Semua Sekolah";
  // List opsi filter (sebaiknya nanti diambil dinamis dari data, tapi ini hardcode dulu)
  final List<String> _filterOptions = [
    "Semua Sekolah",
    "SMA 3",
    "SMP 12",
    "TK",
    "SD",
  ];

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  // --- 2. PERBAIKAN FUNGSI LOAD DATA ---
  Future<void> _loadJadwal() async {
    try {
      // Panggil fungsi generateSchedule() dari instance _service
      final data = await _service.generateSchedule();

      if (mounted) {
        setState(() {
          // A. Simpan data ke variabel utama
          _allJadwalList = data;

          // B. Isi filtered list dengan semua data dulu
          _filteredList = data;

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // --- 3. FUNGSI FILTERING ---
  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == "Semua Sekolah") {
        _filteredList = _allJadwalList;
      } else {
        // Filter berdasarkan nama sekolah yang mengandung kata kunci
        _filteredList = _allJadwalList
            .where((item) => item['nama'].toString().contains(filter))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // HEADER & BACK BUTTON
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Jadwal Pengiriman",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // DROPDOWN FILTER (Sudah Berfungsi)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A0E0E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white54),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterOptions.contains(selectedFilter)
                          ? selectedFilter
                          : "Semua Sekolah",
                      dropdownColor: const Color(0xFF5A0E0E),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      iconEnabledColor: Colors.white,
                      items: _filterOptions.map((item) {
                        return DropdownMenuItem(value: item, child: Text(item));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) _applyFilter(value);
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // LIST JADWAL
              Expanded(child: _buildListJadwal()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListJadwal() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMsg != null) {
      return Center(
        child: Text(
          "Error: $_errorMsg",
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Gunakan _filteredList, bukan _allJadwalList
    if (_filteredList.isEmpty) {
      return const Center(
        child: Text(
          "Tidak ada jadwal yang sesuai.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredList.length,
      itemBuilder: (context, index) {
        final item = _filteredList[index];
        // Urutan tetap berdasarkan posisi di list yang sudah disort oleh service
        // Tapi jika difilter, nomor urut bisa jadi acak.
        // Solusi simpel: index + 1 dari tampilan saat ini.
        final int urutan = index + 1;

        return _jadwalItemCard(item, urutan);
      },
    );
  }

  Widget _jadwalItemCard(Map<String, dynamic> item, int urutan) {
    return Card(
      color: const Color(0xFF5A0E0E),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white24),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Nomor Urut
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          child: Text(
            "#$urutan",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        // Nama Lembaga
        title: Text(
          item['nama'] ?? 'Tanpa Nama',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Detail Info
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            _infoRow(
              Icons.restaurant,
              "Menu: ${item['menu']} (${item['jenis']})",
            ),
            _infoRow(Icons.groups, "Penerima: ${item['jumlah']} Siswa"),
            _infoRow(Icons.map, "Jarak: ${item['jarak_text']}"),
            // Tampilkan Skor untuk memastikan sorting benar (bisa dihapus nanti)
            // Text("Skor: ${item['skor']}", style: TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
        // Tombol Panah
        trailing: GestureDetector(
          onTap: () {
            // Navigasi ke RuteMapScreen
            // Kita kirim koordinat tujuan agar map bisa menggambar rute
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RutePerkiraanWaktuScreen(
                  jam: "Estimasi...", // Bisa dihitung nanti
                  sekolah: item['nama'],
                  // Tambahkan parameter ini di RutePerkiraanWaktuScreen Anda:
                  // latTujuan: item['lat_tujuan'],
                  // longTujuan: item['long_tujuan'],
                ),
              ),
            );
          },
          child: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
