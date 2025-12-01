import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JadwalService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> generateSchedule() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw "User belum login";

    // 1. AMBIL LOKASI SAYA (PENGIRIM)
    final myProfile = await _supabase
        .from('profiles')
        .select('latitude, longitude')
        .eq('id', user.id)
        .single();

    if (myProfile['latitude'] == null) {
      throw "Lokasi Anda belum diatur. Harap set lokasi di Edit Profil.";
    }
    LatLng myLocation = LatLng(myProfile['latitude'], myProfile['longitude']);

    // 2. AMBIL MENU HARI INI
    String hariIni = _getNamaHari();
    String jenisMakanan = 'kering';
    String namaMenu = 'Tidak ada menu';

    final dataMenu = await _supabase
        .from('daftar_menu')
        .select('nama_makanan, jenis_makanan')
        .ilike('hari_tersedia', '%$hariIni%')
        .maybeSingle();

    if (dataMenu != null) {
      jenisMakanan = dataMenu['jenis_makanan'] ?? 'kering';
      namaMenu = dataMenu['nama_makanan'];
    }

    // 3. AMBIL DATA PENERIMA
    final dataPenerima = await _supabase
        .from('profiles')
        .select(
          'username, lembaga, jumlah_penerima, latitude, longitude, user_roles!inner(roles!inner(nama_role))',
        )
        .eq('user_roles.roles.nama_role', 'penanggungjawab_mbg')
        .not('latitude', 'is', null);

    // 4. PROSES HITUNG SKOR & JARAK
    List<Map<String, dynamic>> hasilJadwal = [];

    for (var item in dataPenerima) {
      double lat = item['latitude'];
      double long = item['longitude'];

      // A. Hitung Jarak Jalan Raya (OSRM)
      double jarakMeter = await _getRoadDistance(
        myLocation.latitude,
        myLocation.longitude,
        lat,
        long,
      );

      // Jika OSRM gagal (return 99999), fallback ke Garis Lurus
      if (jarakMeter > 99999000) {
        final Distance distance = const Distance();
        jarakMeter = distance.as(
          LengthUnit.Meter,
          myLocation,
          LatLng(lat, long),
        );
      }

      String jarakKm = (jarakMeter / 1000).toStringAsFixed(1);
      int jumlah = item['jumlah_penerima'] ?? 0;

      // B. Hitung Skor Prioritas
      double skor = 0;

      // Faktor 1: Jenis Makanan
      if (jenisMakanan.toLowerCase() == 'sayur') skor += 600;
      if (jenisMakanan.toLowerCase() == 'buah') skor += 500;
      if (jenisMakanan.toLowerCase() == 'protein hewani') skor += 400;
      if (jenisMakanan.toLowerCase() == 'susu') skor += 300;
      if (jenisMakanan.toLowerCase() == 'protein nabati') skor += 200;
      if (jenisMakanan.toLowerCase() == 'sumber kabohidrat') skor += 100;
      if (jenisMakanan.toLowerCase() == 'sumber lemak') skor += 0;

      // Faktor 2: Jarak (Semakin dekat skor makin tinggi)
      // 100 - jarak(km). Jika jarak 5km = 95 poin.
      skor += (100 - (jarakMeter / 1000));

      // Faktor 3: Jumlah Penerima
      skor += (jumlah / 10);

      hasilJadwal.add({
        'nama': item['lembaga'] ?? item['full_name'],
        'menu': namaMenu,
        'jenis': jenisMakanan,
        'jumlah': jumlah,
        'jarak_text': "$jarakKm km",
        'skor': skor,
      });
    }

    // 5. SORTING (Skor Tertinggi di Atas)
    hasilJadwal.sort((a, b) => b['skor'].compareTo(a['skor']));

    return hasilJadwal;
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
