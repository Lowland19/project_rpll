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

  // --- LOGIKA CEK DATA ATAU GENERATE BARU ---
  Future<void> _checkAndLoadJadwal() async {
    setState(() => _isLoading = true);

    try {
      // LANGKAH 1: Cek dulu di Database
      List<Map<String, dynamic>> data = await _service.syncJadwalHarian();

      if (data.isNotEmpty) {
        // KASUS A: Data SUDAH ADA di DB
        debugPrint("Menggunakan data dari Database (Cache)");

        if (mounted) {
          setState(() {
            _allJadwalList = data;
            _filteredList = data;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Memuat jadwal tersimpan hari ini.")),
          );
        }
      } else {
        // KASUS B: Data BELUM ADA (Kosong) -> Generate Baru
        debugPrint("Data DB kosong. Melakukan Generate Baru...");

        // 1. Hitung via OSRM & Algoritma
        final newData = await _service.generateSchedule();

        // 2. Simpan hasilnya ke DB (supaya nanti pas dibuka lagi gak perlu hitung ulang)
        await _service.simpanJadwalKeDB(newData);

        if (mounted) {
          setState(() {
            _allJadwalList = newData;
            _filteredList = newData;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Jadwal baru berhasil dibuat & disimpan!"),
            ),
          );
        }
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

  @override
  void initState() {
    super.initState();
    _checkAndLoadJadwal(); // Panggil fungsi baru ini
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
    // 1. Cek Status Pengiriman
    bool isSelesai = item['status'] == 'selesai';

    return Card(
      color: const Color(0xFF5A0E0E),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white24),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        // --- BAGIAN INI YANG DIUBAH ---
        leading: CircleAvatar(
          // Jika selesai warna HIJAU, jika belum warna ORANGE
          backgroundColor: isSelesai ? Colors.green : Colors.orange,
          foregroundColor: Colors.white,
          // Jika selesai tampilkan ICON CEKLIS, jika belum tampilkan NOMOR URUT
          child: isSelesai
              ? const Icon(Icons.check, color: Colors.white, size: 24)
              : Text(
                  "#$urutan",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
        // ------------------------------

        // Nama Lembaga
        title: Text(
          item['nama'] ?? 'Tanpa Nama',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            // Opsional: Coret nama jika sudah selesai
            decoration: isSelesai ? TextDecoration.lineThrough : null,
            decorationColor: Colors.white54,
          ),
        ),

        // Detail Info
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            _infoRow(
              Icons.restaurant,
              "Menu: ${item['detail_makanan']})",
            ),
            _infoRow(Icons.groups, "Penerima: ${item['jumlah']} Siswa"),
            _infoRow(Icons.map, "Jarak: ${item['jarak_text']}"),

            // Opsional: Tampilkan teks status text juga
            if (isSelesai)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  "STATUS: SELESAI",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),

        // Tombol Panah
        trailing: GestureDetector(
          onTap: () {
            if (isSelesai) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Pengiriman ini sudah selesai!"),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              );
              return;
            }
            // Validasi koordinat
            if (item['lat_tujuan'] == null ||
                item['long_tujuan'] == null ||
                item['lat_dapur'] == null ||
                item['long_dapur'] == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data lokasi tidak lengkap")),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RutePerkiraanWaktuScreen(
                  jam: "Estimasi...",
                  sekolah: item['nama'],
                  // Tambahkan Default Value 0 agar aman dari null
                  idMenu: item['id_menu'] ?? 0,
                  latAsal: item['lat_dapur'],
                  longAsal: item['long_dapur'],
                  latTujuan: item['lat_tujuan'],
                  longTujuan: item['long_tujuan'],
                ),
              ),
            ).then((_) {
              // Reload data ketika kembali dari peta (biar statusnya update di list)
              _checkAndLoadJadwal();
            });
          },
          child: Icon(
            Icons.arrow_forward_ios,
            // Jika selesai, warnanya kita buat hijau juga biar senada
            color: isSelesai ? Colors.green : Colors.white54,
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
      // 1. Agar ikon tetap di atas (tidak turun ke tengah saat teks jadi 2 baris)
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        // Sedikit padding top pada icon agar sejajar dengan teks baris pertama
         Padding(
          padding: EdgeInsets.only(top: 2.0), 
          child: Icon(icon, size: 14, color: Colors.white70),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            // 2. HAPUS bagian 'overflow: TextOverflow.ellipsis'
            // Text akan otomatis wrap ke bawah karena ada di dalam Expanded
          ),
        ),
      ],
    ),
  );
}}