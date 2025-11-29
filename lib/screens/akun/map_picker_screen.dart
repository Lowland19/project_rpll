import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLong;
  const MapPickerScreen({super.key, this.initialLat, this.initialLong});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _pickedLocation;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLong != null) {
      _pickedLocation = LatLng(widget.initialLat!, widget.initialLong!);
    }
  }

  Future<void> _searchLocation() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _isSearching = true;
    });
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'com.project_rpll.app'},
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        if (data.isNotEmpty) {
          final result = data[0];
          double lat = double.parse(result['lat']);
          double lon = double.parse(result['lon']);
          String displayName = result['display_name'];
          setState(() {
            _pickedLocation = LatLng(lat, lon);
          });
          _mapController.move(LatLng(lat, lon), 15.0);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Ketemu: $displayName")));
        } else {
          throw "Lokasi tidak ditemukan";
        }
      } else {
        throw "Gagal terhubung ke server";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih lokasi'),
        backgroundColor: const Color(0xFF5A0E0E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context, _pickedLocation);
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _pickedLocation ?? const LatLng(-6.175392, 106.827153),
          initialZoom: 15.0,
          onTap: (tapPosition, point) {
            setState(() {
              _pickedLocation = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.project_rpll.app',
          ),
          MarkerLayer(
            markers: [
              if (_pickedLocation != null)
                Marker(
                  point: _pickedLocation!,
                  width: 80,
                  height: 80,
                  child: const Icon(Icons.location_on),
                ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: "Cari lokasi (Misal: Monas)",
                          border: InputBorder.none,
                        ),
                        onSubmitted: (val) =>
                            _searchLocation(), // Cari saat tekan Enter
                      ),
                    ),
                    IconButton(
                      icon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF5A0E0E),
                            ),
                      onPressed: _isSearching ? null : _searchLocation,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context, _pickedLocation);
        },
        label: const Text("Gunakan Lokasi Ini"),
        icon: const Icon(Icons.check),
        backgroundColor: const Color(0xFF5A0E0E),
        foregroundColor: Colors.white,
      ),
    );
  }
}
