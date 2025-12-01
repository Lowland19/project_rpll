import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

// Pastikan import service notifikasi (jika file terpisah)
// import 'package:project_rpll/services/notifikasi_service.dart';

class PantauLokasiScreen extends StatefulWidget {
  final String namaSekolah;
  final int idMenu;
  final double latTujuan;
  final double longTujuan;
  final double latAsal;
  final double longAsal;

  const PantauLokasiScreen({
    super.key,
    required this.namaSekolah,
    required this.idMenu,
    required this.latTujuan,
    required this.longTujuan,
    required this.latAsal,
    required this.longAsal,
  });

  @override
  State<PantauLokasiScreen> createState() => _PantauLokasiScreenState();
}

class _PantauLokasiScreenState extends State<PantauLokasiScreen> {
  final _supabase = Supabase.instance.client;
  final MapController _mapController = MapController();

  // 1. PERBAIKAN: Definisikan Plugin Notifikasi
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _sudahNotifikasi = false;
  List<LatLng> routePoints = [];
  bool isRouteLoading = true;
  late final Stream<List<Map<String, dynamic>>> _streamLokasi;

  @override
  void initState() {
    super.initState();

    // 1. PINDAHKAN KE SINI (Agar langsung terisi sebelum build jalan)
    // Stream Supabase tidak perlu 'await', jadi aman ditaruh di sini.
    _streamLokasi = _supabase
        .from('jadwal_pengiriman')
        .stream(primaryKey: ['id'])
        .eq('id_menu', widget.idMenu);

    // 2. Baru jalankan fungsi setup lainnya (Notifikasi & Rute)
    _setupScreen();
  }

  // Buat fungsi baru untuk memastikan urutan jalan
  Future<void> _setupScreen() async {
    // Tunggu notifikasi siap dulu
    await _initNotifications();

    // Ambil Rute
    _getRoute();

    // 3. HAPUS inisialisasi _streamLokasi dari sini.
    // GANTI DENGAN LISTENER SAJA:

    _streamLokasi.listen((dataList) {
      if (dataList.isNotEmpty) {
        final data = dataList.first;
        final status = data['status'];

        if (status == 'selesai' && !_sudahNotifikasi) {
          _sudahNotifikasi = true;

          if (mounted) {
            _showArrivalDialog();
            _showSystemNotification();
            _simpanNotifikasiKeDB();
          }
        }
      }
    });
  }

  // --- FUNGSI SIMPAN NOTIFIKASI KE DB ---
  Future<void> _simpanNotifikasiKeDB() async {
    try {
      final user = _supabase.auth.currentUser;
      // Pastikan tabel 'notifikasi' sudah ada di Supabase
      if (user != null) {
        await _supabase.from('notifikasi').insert({
          'judul': "Pesanan Tiba",
          'pesan': "Supir telah sampai di lokasi ${widget.namaSekolah}.",
          'user_id': user.id,
          'is_read': false,
        });
      }
    } catch (e) {
      debugPrint("Gagal simpan notif: $e");
    }
  }

  // --- FUNGSI INIT NOTIFIKASI ---
  Future<void> _initNotifications() async {
    // Pastikan file 'ic_launcher.png' ada di folder android/app/src/main/res/mipmap...
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  Future<void> _showSystemNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channel_pengiriman',
          'Notifikasi Pengiriman',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      0,
      'Pesanan Tiba!',
      'Supir telah sampai di lokasi ${widget.namaSekolah}',
      details,
    );
  }

  void _showArrivalDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("Supir Sampai"),
          ],
        ),
        content: const Text("Supir terdeteksi telah memasuki area sekolah."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _getRoute() async {
    final String url =
        'http://router.project-osrm.org/route/v1/driving/${widget.longAsal},${widget.latAsal};${widget.longTujuan},${widget.latTujuan}?geometries=geojson&overview=full';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'].isNotEmpty) {
          final coordinates =
              data['routes'][0]['geometry']['coordinates'] as List;

          if (mounted) {
            setState(() {
              routePoints = coordinates.map((coord) {
                return LatLng(coord[1].toDouble(), coord[0].toDouble());
              }).toList();
              isRouteLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Gagal ambil rute: $e");
      if (mounted) setState(() => isRouteLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pantau: ${widget.namaSekolah}"),
        backgroundColor: const Color(0xFF3B0E0E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () => _mapController.move(
              LatLng(widget.latTujuan, widget.longTujuan),
              14,
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _streamLokasi,
        builder: (context, snapshot) {
          LatLng? posisiSupir;
          String statusPengiriman = "Menunggu...";

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final data = snapshot.data!.first;
            statusPengiriman = data['status']?.toUpperCase() ?? '-';

            if (data['driver_lat'] != null && data['driver_long'] != null) {
              posisiSupir = LatLng(
                (data['driver_lat'] as num).toDouble(),
                (data['driver_long'] as num).toDouble(),
              );
            }
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    (widget.latAsal + widget.latTujuan) / 2,
                    (widget.longAsal + widget.longTujuan) / 2,
                  ),
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.project.rpll',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 4.0,
                        color: Colors.blue.withOpacity(0.7),
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(widget.latAsal, widget.longAsal),
                        width: 32,
                        height: 32,
                        child: const Icon(
                          Icons.store,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                      Marker(
                        point: LatLng(widget.latTujuan, widget.longTujuan),
                        width: 32,
                        height: 32,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                      if (posisiSupir != null)
                        Marker(
                          point: posisiSupir,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2),
                              boxShadow: const [BoxShadow(blurRadius: 5)],
                            ),
                            child: const Icon(
                              Icons.directions_car_filled,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (isRouteLoading)
                const Positioned(
                  top: 10,
                  right: 10,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Status: $statusPengiriman",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: statusPengiriman == 'SELESAI'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          posisiSupir == null
                              ? "Supir belum jalan / GPS mati"
                              : "Supir sedang bergerak menuju lokasi.",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
