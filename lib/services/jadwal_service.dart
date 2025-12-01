import 'dart:convert';
import 'package:flutter/material.dart'; // Untuk debugPrint
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JadwalService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- FUNGSI UTAMA: GENERATE JADWAL DARI DAPUR KE SEKOLAH ---
  Future<List<Map<String, dynamic>>> generateSchedule() async {
    try {
      // 1. AMBIL LOKASI DAPUR
      final dataDapur = await _supabase
          .from('lembaga')
          .select('nama_lembaga, latitude, longitude')
          .eq('jenis_lembaga', 'Dapur SPPG')
          .maybeSingle();

      if (dataDapur == null) throw "Dapur SPPG tidak ditemukan.";

      LatLng lokasiDapur = LatLng(
        (dataDapur['latitude'] as num).toDouble(),
        (dataDapur['longitude'] as num).toDouble(),
      );

      // 2. TENTUKAN HARI INI
      String hariIni = _getNamaHari(); // Misal: "Senin"

      // ---------------------------------------------------------
      // PERBAIKAN UTAMA ADA DI SINI:
      // Kita ambil Data MENU, lalu kita minta Supabase menyertakan data LEMBAGA-nya.
      // ---------------------------------------------------------
      final response = await _supabase
          .from('daftar_menu')
          // 'lembaga:id_penerima(*)' artinya: Join tabel lembaga via foreign key id_penerima
          .select('*, lembaga:id_penerima(*)')
          .ilike('hari_tersedia', '%$hariIni%');

      final List<dynamic> dataMenuHariIni = response as List<dynamic>;

      if (dataMenuHariIni.isEmpty) {
        // Jangan throw error, return kosong saja agar UI tidak crash
        return [];
      }

      // 3. LOOPING BERDASARKAN MENU (Bukan Sekolah)
      List<Map<String, dynamic>> hasilJadwal = [];

      for (var itemMenu in dataMenuHariIni) {
        // Ambil data lembaga dari relasi
        final dataSekolah = itemMenu['lembaga'];

        // Skip jika menu ini tidak punya data sekolah (relasi null) atau koordinat null
        if (dataSekolah == null || dataSekolah['latitude'] == null) continue;

        double latTujuan = (dataSekolah['latitude'] as num?)?.toDouble() ?? 0.0;
        double longTujuan =
            (dataSekolah['longitude'] as num?)?.toDouble() ?? 0.0;
        String namaSekolah = dataSekolah['nama_lembaga'] ?? 'Tanpa Nama';

        // Ambil Menu Spesifik untuk sekolah ini
        String namaMakanan = itemMenu['nama_makanan'] ?? '-';
        String jenisMakanan = itemMenu['jenis_makanan'] ?? 'Umum';

        // 4. HITUNG JARAK (Dapur -> Sekolah Ini)
        double jarakMeter = await _getRoadDistance(
          lokasiDapur.latitude,
          lokasiDapur.longitude,
          latTujuan,
          longTujuan,
        );

        // Fallback jika OSRM gagal/limit
        if (jarakMeter > 99999000) {
          final Distance distance = const Distance();
          jarakMeter = distance.as(
            LengthUnit.Meter,
            lokasiDapur,
            LatLng(latTujuan, longTujuan),
          );
        }

        // 5. HITUNG SKOR (Logika Anda)
        double skor = 0;
        String jenisLower = jenisMakanan.toLowerCase();

        // Skor Jenis Makanan
        if (jenisLower.contains('sayur'))
          skor += 500;
        else if (jenisLower.contains('buah'))
          skor += 400;
        else if (jenisLower.contains('protein hewani'))
          skor += 300;
        else if (jenisLower.contains('susu'))
          skor += 200;
        else if (jenisLower.contains('protein nabati'))
          skor += 100;
        else if (jenisLower.contains('sumber karbohidrat'))
          skor += 50;
        else if (jenisLower.contains('sumber lemak'))
          skor += 25;
        else
          skor += 0;

        // Skor Jarak (Prioritas dekat)
        skor += (100 - (jarakMeter / 1000));

        // Skor Jumlah Siswa
        int jumlahSiswa = dataSekolah['jumlah_penerima'] ?? 0;
        skor += (jumlahSiswa / 10);

        hasilJadwal.add({
          'id_menu': itemMenu['id'],
          'nama': namaSekolah, // Nama Sekolah
          'menu': namaMakanan, // Menu KHUSUS sekolah ini (Bukan 'test10' semua)
          'jenis': jenisMakanan,
          'jumlah': jumlahSiswa,
          'jarak_meter': jarakMeter,
          'jarak_text': "${(jarakMeter / 1000).toStringAsFixed(1)} km",
          'skor': skor,

          'lat_tujuan': latTujuan,
          'long_tujuan': longTujuan,

          // TAMBAHKAN INI (Koordinat Asal):
          'lat_dapur': lokasiDapur.latitude,
          'long_dapur': lokasiDapur.longitude,
        });
      }

      // 6. SORTING
      hasilJadwal.sort((a, b) => b['skor'].compareTo(a['skor']));

      return hasilJadwal;
    } catch (e) {
      print("Error generateSchedule: $e");
      rethrow;
    }
  }

  // --- HELPER: NAMA HARI ---
  String _getNamaHari() {
    List<String> hari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return hari[DateTime.now().weekday - 1];
  }

  // --- HELPER: OSRM (Jarak Jalan Raya) ---
  Future<double> _getRoadDistance(
    double startLat,
    double startLong,
    double endLat,
    double endLong,
  ) async {
    try {
      final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/$startLong,$startLat;$endLong,$endLat?overview=false',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['routes'].isNotEmpty) {
          return (json['routes'][0]['distance'] as num).toDouble();
        }
      }
      return 99999999;
    } catch (e) {
      return 99999999;
    }
  }

  Future<List<Map<String, dynamic>>> getJadwalHarian() async {
    try {
      final String todayDate = DateTime.now().toIso8601String().substring(
        0,
        10,
      );

      // 1. Ambil Lokasi Dapur dulu (untuk koordinat asal rute)
      //    (Karena tabel jadwal cuma simpan data tujuan, kita butuh data asal juga)
      final dataDapur = await _supabase
          .from('lembaga')
          .select('latitude, longitude')
          .eq('jenis_lembaga', 'Dapur SPPG')
          .maybeSingle();

      double latDapur = 0;
      double longDapur = 0;
      if (dataDapur != null) {
        latDapur = (dataDapur['latitude'] as num).toDouble();
        longDapur = (dataDapur['longitude'] as num).toDouble();
      }

      // 2. Query Data Jadwal (Join Bertingkat)
      // jadwal_pengiriman -> daftar_menu -> lembaga
      final response = await _supabase
          .from('jadwal_pengiriman')
          .select('''
            *,
            daftar_menu (
              nama_makanan,
              jenis_makanan,
              lembaga (
                nama_lembaga,
                jumlah_penerima,
                latitude,
                longitude
              )
            )
          ''')
          .eq('tanggal_jadwal', todayDate)
          .order(
            'skor_prioritas',
            ascending: false,
          ); // Urutkan berdasarkan skor yg sudah disimpan

      final List<dynamic> dataDB = response as List<dynamic>;

      // 3. Mapping Data (Agar formatnya SAMA PERSIS dengan hasil generateSchedule)
      // Kita harus 'meratakan' (flatten) struktur JSON yang bersarang
      return dataDB.map((item) {
        final menu = item['daftar_menu'];
        final sekolah = menu['lembaga'];

        return {
          // Data Utama
          'id_menu': item['id_menu'], // ID untuk update status nanti
          'nama': sekolah['nama_lembaga'],
          'menu': menu['nama_makanan'],
          'jenis': menu['jenis_makanan'],
          'jumlah': sekolah['jumlah_penerima'] ?? 0,
          'status': item['status'], // pending/selesai
          // Data Jarak & Skor (Ambil langsung dari DB, gak usah hitung lagi)
          'jarak_meter': item['jarak_meter'],
          'jarak_text': "${(item['jarak_meter'] / 1000).toStringAsFixed(1)} km",
          'skor': item['skor_prioritas'],

          // Koordinat Tujuan (Sekolah)
          'lat_tujuan': (sekolah['latitude'] as num?)?.toDouble() ?? 00,
          'long_tujuan': (sekolah['longitude'] as num?)?.toDouble() ?? 00,

          // Koordinat Asal (Dapur)
          'lat_dapur': latDapur,
          'long_dapur': longDapur,
        };
      }).toList();
    } catch (e) {
      debugPrint("Gagal mengambil jadwal dari DB: $e");
      return []; // Return kosong jika error/belum ada data
    }
  }

  // --- FUNGSI BARU: SIMPAN JADWAL KE DB ---
  Future<void> simpanJadwalKeDB(
    List<Map<String, dynamic>> hasilGenerate,
  ) async {
    try {
      final String todayDate = DateTime.now().toIso8601String().substring(
        0,
        10,
      ); // Format YYYY-MM-DD

      // 1. Cek dulu apakah jadwal hari ini sudah ada?
      final cekData = await _supabase
          .from('jadwal_pengiriman')
          .select('id')
          .eq('tanggal_jadwal', todayDate)
          .limit(1);

      if ((cekData as List).isNotEmpty) {
        // Jika sudah ada, kita bisa pilih: Hapus dulu lalu replace, atau Skip.
        // Di sini kita pilih hapus yang lama (Reset) agar update terbaru masuk
        await _supabase
            .from('jadwal_pengiriman')
            .delete()
            .eq('tanggal_jadwal', todayDate);
      }

      // 2. Siapkan data untuk Bulk Insert
      // Kita mapping dari hasil generate ke kolom database
      List<Map<String, dynamic>> dataInsert = hasilGenerate.map((item) {
        return {
          'id_menu': item['id_menu'],
          'skor_prioritas': item['skor'],
          'jarak_meter': item['jarak_meter'],
          'status': 'pending',
          'tanggal_jadwal': todayDate,
        };
      }).toList();

      // 3. Eksekusi Insert
      if (dataInsert.isNotEmpty) {
        await _supabase.from('jadwal_pengiriman').insert(dataInsert);
        debugPrint(
          "Berhasil menyimpan ${dataInsert.length} jadwal ke database.",
        );
      }
    } catch (e) {
      debugPrint("Gagal menyimpan jadwal: $e");
      rethrow;
    }
  }

  Future<void> tandaiSelesai(int idMenu) async {
    await _supabase
        .from('jadwal_pengiriman')
        .update({
          'status': 'selesai',
          // 'waktu_sampai': DateTime.now().toIso8601String(), // jika ada kolom ini
        })
        .eq('id_menu', idMenu);
  }
}
