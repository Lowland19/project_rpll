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

        // Ambil Menu Spesifik untuk sekolah in
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
        String detailMakanan = itemMenu['detail_makanan'] ?? 'Umum';
        double skor = 0;
        String detailMakananLower = detailMakanan.toLowerCase();

        // Skor Jenis Makanan
        if (detailMakananLower.contains('sayur bayam')) skor += 98;
        if (detailMakananLower.contains('sayur sop')) skor += 95;
        if (detailMakananLower.contains('tumis kangkung')) skor += 90;
        if (detailMakananLower.contains('bubur ayam')) skor += 95;
        if (detailMakananLower.contains('nasi putih')) skor += 85;
        if (detailMakananLower.contains('nasi goreng')) skor += 80;
        if (detailMakananLower.contains('kentang')) skor += 75;
        if (detailMakananLower.contains('roti')) skor += 40;
        if (detailMakananLower.contains('tahu')) skor += 85;
        if (detailMakananLower.contains('tempe')) skor += 70;
        if (detailMakananLower.contains('kacang merah')) skor += 65;
        if (detailMakananLower.contains('kedelai')) skor += 50;
        if (detailMakananLower.contains('ikan bandeng')) skor += 80;
        if (detailMakananLower.contains('ayam goreng')) skor += 75;
        if (detailMakananLower.contains('telur')) skor += 70;
        if (detailMakananLower.contains('daging sapi')) skor += 75;
        if (detailMakananLower.contains('pisang')) skor += 50;
        if (detailMakananLower.contains('pepaya')) skor += 45;
        if (detailMakananLower.contains('semangka')) skor += 40;
        if (detailMakananLower.contains('apel')) skor += 30;
        if (detailMakananLower.contains('susu uht')) skor += 10;
        if (detailMakananLower.contains('susu bubuk')) skor += 5;
        if (detailMakananLower.contains('keju')) skor += 25;
        if (detailMakananLower.contains('mentega')) skor += 15;
        if (detailMakananLower.contains('minyak sayur')) skor += 5;

        // Skor Jarak (Prioritas dekat)
        skor += (100 + (jarakMeter / 1000));

        // Skor Jumlah Siswa
        int jumlahSiswa = dataSekolah['jumlah_penerima'] ?? 0;
        skor += (jumlahSiswa / 10);

        hasilJadwal.add({
          'id_menu': itemMenu['id'],
          'nama': namaSekolah, // Nama Sekola
          'detail_makanan' : detailMakanan,
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
    final String todayDate = DateTime.now().toIso8601String().substring(0, 10);
    
    // ... (kode ambil lokasi dapur tetap sama) ...

    // 2. Query Data Jadwal
    final response = await _supabase
        .from('jadwal_pengiriman')
        .select('''
          *,
          daftar_menu (
            detail_makanan,
            jenis_makanan,
            lembaga (
              nama_lembaga,
              jumlah_penerima,
              latitude,
              longitude
            )
          )
        ''')
        .eq('tanggal_jadwal', todayDate).order('skor_prioritas', ascending: false);

    final List<dynamic> dataDB = response as List<dynamic>;

    // 3. Mapping Data
    return dataDB.map((item) {
      final menu = item['daftar_menu'];
      final sekolah = menu['lembaga'];

      return {
        'id_menu': item['id_menu'],
        'nama': sekolah['nama_lembaga'],
        
        // --- TAMBAHKAN BARIS INI ---
        'detail_makanan': menu['detail_makanan'] ?? 'Menu Umum',
        // ---------------------------
        
        'jenis': menu['jenis_makanan'],
        'jumlah': sekolah['jumlah_penerima'] ?? 0,
        'status': item['status'],
        'jarak_meter': item['jarak_meter'],
        'jarak_text': "${(item['jarak_meter'] / 1000).toStringAsFixed(1)} km",
        'skor': item['skor_prioritas'],
        'lat_tujuan': (sekolah['latitude'] as num?)?.toDouble() ?? 0.0,
        'long_tujuan': (sekolah['longitude'] as num?)?.toDouble() ?? 0.0,
        // ... (data dapur tetap sama)
      };
    }).toList();
  } catch (e) {
    debugPrint("Gagal mengambil jadwal dari DB: $e");
    return [];
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
          'driver_lat': null, // Hapus data Latitude
          'driver_long': null,
          // 'waktu_sampai': DateTime.now().toIso8601String(), // jika ada kolom ini
        })
        .eq('id_menu', idMenu);
  }

  Future<void> updateLokasiRealtime(int idMenu, double lat, double long) async {
    await _supabase
        .from('jadwal_pengiriman')
        .update({'driver_lat': lat, 'driver_long': long})
        .eq('id_menu', idMenu);
  }

  // --- FUNGSI BARU: SINKRONISASI (Cek & Tambah Menu Baru) ---
  Future<List<Map<String, dynamic>>> syncJadwalHarian() async {
    try {
      final String hariIni = _getNamaHari();
      final String todayDate = DateTime.now().toIso8601String().substring(
        0,
        10,
      );

      // 1. Ambil SEMUA MENU yang tersedia hari ini
      final responseMenu = await _supabase
          .from('daftar_menu')
          .select('*, lembaga:id_penerima(*)')
          .ilike('hari_tersedia', '%$hariIni%');
      final List<dynamic> allMenus = responseMenu as List<dynamic>;

      if (allMenus.isEmpty) return [];

      // 2. Ambil ID MENU yang SUDAH ADA di tabel jadwal_pengiriman hari ini
      final responseJadwal = await _supabase
          .from('jadwal_pengiriman')
          .select('id_menu')
          .eq('tanggal_jadwal', todayDate);

      // Buat Set agar pencarian cepat
      final Set<int> existingMenuIds = (responseJadwal as List)
          .map((e) => e['id_menu'] as int)
          .toSet();

      // 3. Filter: Cari Menu yang ID-nya BELUM ada di jadwal
      final List<dynamic> newMenus = allMenus.where((menu) {
        return !existingMenuIds.contains(menu['id']);
      }).toList();

      if (newMenus.isEmpty) {
        // Jika tidak ada menu baru, langsung kembalikan data gabungan dari DB
        return getJadwalHarian();
      }

      // 4. Proses Kalkulasi OSRM hanya untuk MENU BARU
      final dataDapur = await _supabase
          .from('lembaga')
          .select('latitude, longitude')
          .eq('jenis_lembaga', 'Dapur SPPG')
          .maybeSingle();

      if (dataDapur == null) throw "Dapur tidak ditemukan";

      LatLng lokasiDapur = LatLng(
        (dataDapur['latitude'] as num).toDouble(),
        (dataDapur['longitude'] as num).toDouble(),
      );

      List<Map<String, dynamic>> newJadwalItems = [];

      for (var itemMenu in newMenus) {
        final dataSekolah = itemMenu['lembaga'];
        if (dataSekolah == null || dataSekolah['latitude'] == null) continue;

        double latTujuan = (dataSekolah['latitude'] as num).toDouble();
        double longTujuan = (dataSekolah['longitude'] as num).toDouble();

        // Hitung Jarak OSRM
        double jarakMeter = await _getRoadDistance(
          lokasiDapur.latitude,
          lokasiDapur.longitude,
          latTujuan,
          longTujuan,
        );

        if (jarakMeter > 99999000) {
          final Distance distance = const Distance();
          jarakMeter = distance.as(
            LengthUnit.Meter,
            lokasiDapur,
            LatLng(latTujuan, longTujuan),
          );
        }

        // Hitung Skor
        String detailMakanan = itemMenu['detail_makanan'] ?? 'Umum';
        double skor = 0;
        String detailMakananLower = detailMakanan.toLowerCase();

        // Skor Jenis Makanan
        if (detailMakananLower.contains('sayur bayam')) skor += 98;
        if (detailMakananLower.contains('sayur sop')) skor += 95;
        if (detailMakananLower.contains('tumis kangkung')) skor += 90;
        if (detailMakananLower.contains('bubur ayam')) skor += 95;
        if (detailMakananLower.contains('nasi putih')) skor += 85;
        if (detailMakananLower.contains('nasi goreng')) skor += 80;
        if (detailMakananLower.contains('kentang')) skor += 75;
        if (detailMakananLower.contains('roti')) skor += 40;
        if (detailMakananLower.contains('tahu')) skor += 85;
        if (detailMakananLower.contains('tempe')) skor += 70;
        if (detailMakananLower.contains('kacang merah')) skor += 65;
        if (detailMakananLower.contains('kedelai')) skor += 50;
        if (detailMakananLower.contains('ikan bandeng')) skor += 80;
        if (detailMakananLower.contains('ayam goreng')) skor += 75;
        if (detailMakananLower.contains('telur')) skor += 70;
        if (detailMakananLower.contains('daging sapi')) skor += 75;
        if (detailMakananLower.contains('pisang')) skor += 50;
        if (detailMakananLower.contains('pepaya')) skor += 45;
        if (detailMakananLower.contains('semangka')) skor += 40;
        if (detailMakananLower.contains('apel')) skor += 30;
        if (detailMakananLower.contains('susu uht')) skor += 10;
        if (detailMakananLower.contains('susu bubuk')) skor += 5;
        if (detailMakananLower.contains('keju')) skor += 25;
        if (detailMakananLower.contains('mentega')) skor += 15;
        if (detailMakananLower.contains('minyak sayur')) skor += 5;

        skor += 0;
        skor += (100 + (jarakMeter / 1000));
        skor += ((dataSekolah['jumlah_penerima'] ?? 0) / 10);

        newJadwalItems.add({
          'id_menu': itemMenu['id'],
          'skor_prioritas': skor,
          'jarak_meter': jarakMeter,
          'status': 'pending',
          'tanggal_jadwal': todayDate,
        });
      }

      // 5. Insert HANYA data baru ke Database
      if (newJadwalItems.isNotEmpty) {
        await _supabase.from('jadwal_pengiriman').insert(newJadwalItems);
        debugPrint("Menambahkan ${newJadwalItems.length} menu baru ke jadwal.");
      }

      // 6. Ambil ulang semua data terbaru dari DB untuk ditampilkan
      return getJadwalHarian();
    } catch (e) {
      debugPrint("Sync Error: $e");
      rethrow;
    }
  }

  Future<void> simpanNotifikasi({
    required String judul,
    required String pesan,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('notifikasi').insert({
      'judul': judul,
      'pesan': pesan,
      'user_id': user.id, // Disimpan untuk user yang sedang login
      'is_read': false,
    });
  }

  // 2. AMBIL DAFTAR NOTIFIKASI
  Stream<List<Map<String, dynamic>>> getNotifikasiSaya() {
    final user = _supabase.auth.currentUser;
    if (user == null) return const Stream.empty();

    return _supabase
        .from('notifikasi')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false); // Yang baru di atas
  }

  Future<int> cekJumlahTugasHariIni() async {
    try {
      final String todayDate = DateTime.now().toIso8601String().substring(
        0,
        10,
      );

      // Hitung jadwal hari ini yang statusnya masih pending
      final response = await _supabase
          .from('jadwal_pengiriman')
          .select('id') // Kita cuma butuh hitung ID-nya saja
          .eq('tanggal_jadwal', todayDate)
          .eq('status', 'pending'); // Hanya yang belum selesai

      final List data = response as List;
      return data.length; // Mengembalikan jumlah tugas (misal: 5)
    } catch (e) {
      return 0;
    }
  }
}
