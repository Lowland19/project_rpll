import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PantauLokasiScreen extends StatefulWidget {
  final String namaSekolah;
  final int idMenu;
  final double latTujuan;
  final double longTujuan;

  const PantauLokasiScreen({
    super.key,
    required this.namaSekolah,
    required this.idMenu,
    required this.latTujuan,
    required this.longTujuan,
  });

  @override
  State<PantauLokasiScreen> createState() => _PantauLokasiScreenState();
}

class _PantauLokasiScreenState extends State<PantauLokasiScreen> {
  final _supabase = Supabase.instance.client;
  final MapController _mapController = MapController();

  // Stream untuk mendengarkan perubahan data di satu baris jadwal ini
  late final Stream<List<Map<String, dynamic>>> _streamLokasi;

  @override
  void initState() {
    super.initState();
    // Setup Stream Realtime
    _streamLokasi = _supabase
        .from('jadwal_pengiriman')
        .stream(primaryKey: ['id']) // Primary key tabel jadwal_pengiriman
        .eq('id_menu', widget.idMenu); // Filter hanya menu ini
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pantau: ${widget.namaSekolah}"),
        backgroundColor: const Color(0xFF3B0E0E),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _streamLokasi,
        builder: (context, snapshot) {
          // 1. Handle Loading/Error
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Menunggu sinyal supir..."));
          }

          // 2. Ambil Data Terbaru
          final data = snapshot.data!.first;
          final double? driverLat = data['driver_lat'];
          final double? driverLong = data['driver_long'];

          // Jika supir belum pernah kirim lokasi
          if (driverLat == null || driverLong == null) {
            return const Center(child: Text("Supir belum mulai jalan."));
          }

          final LatLng posisiSupir = LatLng(driverLat, driverLong);

          // 3. Tampilkan Peta
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // Center di tengah-tengah antara supir dan tujuan
              initialCenter: LatLng(
                (driverLat + widget.latTujuan) / 2,
                (driverLong + widget.longTujuan) / 2,
              ),
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.project.rpll',
              ),
              MarkerLayer(
                markers: [
                  // MARKER TUJUAN (SEKOLAH)
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

                  // MARKER SUPIR (BERGERAK SENDIRI)
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
                        Icons.directions_car,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              // INFO PANEL DI BAWAH
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      "Status: ${data['status']?.toUpperCase() ?? '-'}\nLokasi Supir Terkini",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
