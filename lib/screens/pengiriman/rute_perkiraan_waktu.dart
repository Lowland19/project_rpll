import 'dart:convert';
import 'dart:async'; // Untuk StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:project_rpll/services/jadwal_service.dart'; // Pastikan path ini benar

class RutePerkiraanWaktuScreen extends StatefulWidget {
  final String sekolah;
  final String jam;
  // Parameter Koordinat
  final double latAsal;
  final double longAsal;
  final double latTujuan;
  final double longTujuan;
  final int idMenu;

  const RutePerkiraanWaktuScreen({
    super.key,
    required this.sekolah,
    required this.jam,
    required this.latAsal,
    required this.longAsal,
    required this.latTujuan,
    required this.longTujuan,
    required this.idMenu,
  });

  @override
  State<RutePerkiraanWaktuScreen> createState() =>
      _RutePerkiraanWaktuScreenState();
}

class _RutePerkiraanWaktuScreenState extends State<RutePerkiraanWaktuScreen> {
  final MapController _mapController = MapController();

  // List titik koordinat untuk menggambar garis jalan
  List<LatLng> routePoints = [];
  bool isLoading = true;

  // Variabel Tracking
  LatLng? _posisiSupir;
  StreamSubscription<Position>? _positionStream;
  bool _hasArrived = false;

  // Service
  final _jadwalService = JadwalService();

  @override
  void initState() {
    super.initState();
    _getRoute();
    _startTracking();
  }

  @override
  void dispose() {
    // PENTING: Matikan stream saat keluar halaman agar tidak boros baterai
    _positionStream?.cancel();
    _mapController.dispose(); // Dispose map controller juga
    super.dispose();
  }

  // --- FUNGSI TRACKING & GEOFENCING ---
  void _startTracking() {
    // Pengaturan GPS (Akurasi tinggi, update tiap gerak 10 meter)
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((Position position) async {
          if (!mounted) return;

          // 1. Update Lokasi Marker Mobil (Visual)
          setState(() {
            _posisiSupir = LatLng(position.latitude, position.longitude);
          });

          // 2. Cek apakah sudah sampai sebelumnya? Jika sudah, skip logika ini.
          if (_hasArrived) return;

          // 3. Hitung Jarak Supir ke Sekolah (dalam Meter)
          double jarakMeter = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            widget.latTujuan,
            widget.longTujuan,
          );

          // 4. Cek Threshold (Jika kurang dari 150 meter dianggap sampai)
          if (jarakMeter <= 50) {
            // Kunci flag dulu biar gak kepanggil berkali-kali
            _hasArrived = true;

            try {
              // 5. Panggil Service Update Database
              await _jadwalService.tandaiSelesai(widget.idMenu);

              if (mounted) {
                // 6. Beri Notifikasi Suara/Visual ke Supir
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Tiba di Tujuan"),
                    content: const Text(
                      "Anda telah memasuki area sekolah. Status pengiriman otomatis diperbarui menjadi SELESAI.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx); // Tutup Dialog
                          Navigator.pop(context); // Kembali ke list jadwal
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              }
            } catch (e) {
              debugPrint("Gagal update otomatis: $e");
              // Jika gagal, buka kunci lagi biar dicoba di update lokasi berikutnya
              _hasArrived = false;
            }
          }
        });
  }

  // --- FUNGSI AMBIL GARIS RUTE DARI OSRM ---
  Future<void> _getRoute() async {
    final String url =
        'http://router.project-osrm.org/route/v1/driving/${widget.longAsal},${widget.latAsal};${widget.longTujuan},${widget.latTujuan}?geometries=geojson&overview=full';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parsing GeoJSON menjadi List<LatLng>
        if (data['routes'].isNotEmpty) {
          final coordinates =
              data['routes'][0]['geometry']['coordinates'] as List;

          if (mounted) {
            setState(() {
              routePoints = coordinates.map((coord) {
                // OSRM mengembalikan [long, lat], kita butuh [lat, long]
                return LatLng(coord[1].toDouble(), coord[0].toDouble());
              }).toList();
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching route: $e");
      if (mounted) setState(() => isLoading = false);
    }
  } // <--- HAPUS TITIK KOMA DI SINI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rute ke ${widget.sekolah}"),
        backgroundColor: const Color(0xFF3B0E0E),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 1. PETA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // Pusatkan peta di antara dua titik
              initialCenter: LatLng(
                (widget.latAsal + widget.latTujuan) / 2,
                (widget.longAsal + widget.longTujuan) / 2,
              ),
              initialZoom: 13.0,
              // Tambahkan Max Zoom agar peta tidak pecah
              maxZoom: 18.0,
            ),
            children: [
              // Layer Peta (CartoDB Voyager - Lebih bersih)
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName:
                    'com.project.rpll', // Wajib untuk OSM policy
                maxNativeZoom: 19,
                maxZoom: 20,
              ),

              // Layer Garis Rute (Polyline)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),

              // Layer Marker (Pin)
              MarkerLayer(
                markers: [
                  // Marker Dapur (Asal) - Hijau
                  Marker(
                    point: LatLng(widget.latAsal, widget.longAsal),
                    width: 20,
                    height: 20,
                    child: const Icon(
                      Icons.store,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),

                  // Marker Sekolah (Tujuan) - Merah
                  Marker(
                    point: LatLng(widget.latTujuan, widget.longTujuan),
                    width: 20,
                    height: 20,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),

                  // Marker Supir (Real-time) - Biru
                  if (_posisiSupir != null)
                    Marker(
                      point: _posisiSupir!,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                          boxShadow: const [
                            BoxShadow(blurRadius: 5, color: Colors.black26),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_car_filled,
                          color: Colors.blue,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 2. Loading Indicator
          if (isLoading) const Center(child: CircularProgressIndicator()),

          // 3. Info Panel
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              color: const Color(0xFF5A0E0E),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Tujuan: ${widget.sekolah}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Estimasi Sampai: ${widget.jam}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
