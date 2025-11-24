import 'package:flutter/material.dart';
import 'package:project_rpll/screens/form_menu_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<List<dynamic>> _DaftarMenu;

  @override
  void initState() {
    super.initState();
    _DaftarMenu = getDaftarMenu();
  }

  Future<List<dynamic>> getDaftarMenu() async {
    final response = await Supabase.instance.client
        .from('daftar_menu')
        .select();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),

      appBar: AppBar(
        backgroundColor: const Color(0xFF5A0E0E),
        title: const Text("Menu MBG", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FormMenuScreen()),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
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
            future: _DaftarMenu,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "Tidak ada data",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final daftarMenu = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: daftarMenu.length,
                itemBuilder: (context, index) {
                  final menu = daftarMenu[index];

                  return Card(
                    color: const Color(0xFF5A0E0E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(
                        menu['nama_makanan'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Jenis Makanan: ${menu['jenis_makanan']}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "Penerima: ${menu['penerima']}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "Hari Tersedia: ${menu['hari_tersedia']}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      trailing: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image, size: 40),
                      ),
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
