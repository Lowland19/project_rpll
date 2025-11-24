import 'package:flutter/material.dart';
import 'package:project_rpll/screens/detil_laporan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final _future = Supabase.instance.client.from('laporan').select();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A0E0E),
        title: const Text(
          'Menu Pelaporan',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -40,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFF5A0E0E),
                shape: BoxShape.circle,
              ),
            ),
          ),
          FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final laporan = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: laporan.length,
                itemBuilder: (context, index) {
                  final l = laporan[index];

                  return Card(
                    color: const Color(0xFF5A0E0E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      title: Text(
                        l['penerima_manfaat'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        "Kelayakan: ${l['persen_kelayakan']}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: SizedBox(
                        width: 80,
                        height: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            l['gambar'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DetilLaporan(),
                            settings: RouteSettings(arguments: l['id']),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
