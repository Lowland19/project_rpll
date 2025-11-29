import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'rute_perkiraan_waktu.dart';

class JadwalPengirimanScreen extends StatefulWidget {
  const JadwalPengirimanScreen({super.key});

  @override
  State<JadwalPengirimanScreen> createState() => _JadwalPengirimanScreenState();
}

class _JadwalPengirimanScreenState extends State<JadwalPengirimanScreen> {
  String selectedFilter = "Semua Sekolah";
  List<Map<String, dynamic>> _jadwalList = [];
  bool _isLoading = true;
  String? _errorMsg;
  LatLng? _myLocation;

  String _getHariIni() {
    List<String> hari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    // weekday di Dart mulai dari 1 (Senin) sampai 7 (Minggu)
    return hari[DateTime.now().weekday - 1];
  }

  Future<void> _generateJadwalOtomatis() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      // 1. AMBIL LOKASI SAYA (PENGIRIM)
      final myProfile = await supabase
          .from('profiles')
          .select('latitude, longitude')
          .eq('id', user.id)
          .single();

      if (myProfile['latitude'] == null) {
        throw "Lokasi Anda belum diatur.";
      }
      _myLocation = LatLng(myProfile['latitude'], myProfile['longitude']);

      // --- PERUBAHAN DI SINI ---
      // 2. AMBIL MENU HARI INI (Cari jenis makanannya)
      String hariIni = _getHariIni(); // Misal: "Rabu"
      String jenisMakananHariIni = 'kering'; // Default
      String namaMenuHariIni = 'Tidak ada menu';

      final dataMenu = await supabase
          .from('daftar_menu')
          .select('nama_makanan, jenis_makanan')
          .ilike(
            'hari_tersedia',
            '%$hariIni%',
          ) // Cari yang mengandung nama hari ini
          .maybeSingle(); // Pakai maybeSingle biar gak error kalau kosong

      if (dataMenu != null) {
        jenisMakananHariIni = dataMenu['jenis_makanan'] ?? '_';
        namaMenuHariIni = dataMenu['nama_makanan'];
      }

      print(
        "📅 Menu Hari Ini ($hariIni): $namaMenuHariIni ($jenisMakananHariIni)",
      );

      // 3. AMBIL DATA PENERIMA
      final dataPenerima = await supabase
          .from('profiles')
          .select(
            'username, lembaga, jumlah_penerima, latitude, longitude, user_roles!inner(roles!inner(nama_role))',
          )
          .eq('user_roles.roles.nama_role', 'penanggungjawab_mbg')
          .not('latitude', 'is', null);

      // 4. HITUNG SKOR
      final Distance distance = const Distance();
      List<Map<String, dynamic>> tempList = [];

      for (var item in dataPenerima) {
        double lat = item['latitude'];
        double long = item['longitude'];
        double jarakMeter = distance.as(
          LengthUnit.Meter,
          _myLocation!,
          LatLng(lat, long),
        );
        String jarakKm = (jarakMeter / 1000).toStringAsFixed(1);
        int jumlah = item['jumlah_penerima'] ?? 0;

        // --- RUMUS SKOR ---
        double skor = 0;

        // FAKTOR 1: JENIS MAKANAN (Global untuk hari ini)
        // Jika hari ini makanannya BASAH, semua pengiriman jadi prioritas tinggi
        if (jenisMakananHariIni.toLowerCase() == 'basah') {
          skor += 500;
        }

        // FAKTOR 2: JARAK (Semakin dekat semakin prioritas)
        double skorJarak = 100 - (jarakMeter / 1000);
        skor += skorJarak;

        // FAKTOR 3: JUMLAH PENERIMA
        skor += (jumlah / 10);

        tempList.add({
          'nama': item['lembaga'] ?? item['full_name'],
          'menu': namaMenuHariIni, // Info tambahan
          'jenis': jenisMakananHariIni,
          'jumlah': jumlah,
          'jarak_text': "$jarakKm km",
          'skor': skor,
        });
      }

      // 5. SORTING
      tempList.sort((a, b) => b['skor'].compareTo(a['skor']));

      if (mounted) {
        setState(() {
          _jadwalList = tempList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = "Gagal: $e";
          _isLoading = false;
        });
      }
    }
  }

  final List<Map<String, String>> jadwalList = [
    {"jam": "09.30", "sekolah": "SMA 3"},
    {"jam": "09.50", "sekolah": "SMP 12"},
    {"jam": "10.30", "sekolah": "TK"},
    {"jam": "10.55", "sekolah": "SD"},
    {"jam": "11.30", "sekolah": "PAUD"},
  ];
  @override
  void initState() {
    super.initState();
    _generateJadwalOtomatis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading)
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    if (_errorMsg != null)
      return Center(
        child: Text(_errorMsg!, style: const TextStyle(color: Colors.white)),
      );
    if (_jadwalList.isEmpty)
      return const Center(
        child: Text(
          "Tidak ada data pengiriman.",
          style: TextStyle(color: Colors.white),
        ),
      );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _jadwalList.length,
      itemBuilder: (context, index) {
        final item = _jadwalList[index];
        final int urutan = index + 1; // Urutan pengiriman

        return Card(
          color: const Color(0xFF5A0E0E),
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white24),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              child: Text(
                "#$urutan",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              item['nama'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                _infoRow(Icons.restaurant, "Makanan: ${item['jenis']}"),
                _infoRow(Icons.groups, "Penerima: ${item['jumlah']} Siswa"),
                _infoRow(Icons.map, "Jarak: ${item['jarak_text']}"),

                // Debug Skor (Opsional, boleh dihapus)
                // Text("Skor Prioritas: ${item['skor'].toStringAsFixed(1)}", style: TextStyle(color: Colors.green, fontSize: 10)),
              ],
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _jadwalItem({required String jam, required String sekolah}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RutePerkiraanWaktuScreen(jam: jam, sekolah: sekolah),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // jam kiri
            Container(
              width: 70,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF5A0E0E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                jam,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            const SizedBox(width: 20),

            // nama sekolah
            Expanded(
              child: Text(
                sekolah,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
