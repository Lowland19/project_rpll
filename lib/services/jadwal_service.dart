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

        double latTujuan = (dataSekolah['latitude'] as num).toDouble();
        double longTujuan = (dataSekolah['longitude'] as num).toDouble();
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
          'nama': namaSekolah, // Nama Sekolah
          'menu': namaMakanan, // Menu KHUSUS sekolah ini (Bukan 'test10' semua)
          'jenis': jenisMakanan,
          'jumlah': jumlahSiswa,
          'jarak_text': "${(jarakMeter / 1000).toStringAsFixed(1)} km",
          'skor': skor,
          'lat_tujuan': latTujuan,
          'long_tujuan': longTujuan,
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
}
