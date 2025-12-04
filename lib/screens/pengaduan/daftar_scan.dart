import 'package:flutter/material.dart';
import 'package:project_rpll/services/scan_service.dart';
import 'hasil_scan.dart';

class DaftarScanScreen extends StatefulWidget {
  const DaftarScanScreen({super.key});

  @override
  State<DaftarScanScreen> createState() => _DaftarScanScreenState();
}

class _DaftarScanScreenState extends State<DaftarScanScreen> {
  List data = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final result = await scanService.getAllScans();
    setState(() => data = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Hasil Scan")),
      body: data.isEmpty
          ? const Center(child: Text("Belum ada data scan"))
          : ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, i) {
          final item = data[i];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image_url'],
                width: 55,
                height: 55,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(item['hasil']),
            subtitle: Text(
              "Confidence: ${item['confidence'].toStringAsFixed(2)}%",
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HasilScanScreen(
                    imagePath: item['image_url'], // pakai network
                    hasilModel: item['hasil'],
                    confidence: item['confidence'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
