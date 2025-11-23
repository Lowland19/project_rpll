import 'package:flutter/material.dart';
import 'package:project_rpll/providers/auth_provider.dart';
import 'package:project_rpll/screens/laporan_screen.dart';
import 'package:project_rpll/screens/menu_screen.dart';
import 'package:provider/provider.dart';

class HomeScreenWidget extends StatelessWidget {
  const HomeScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final userName = user?.userMetadata?['name'] ?? 'DASHBOARD PETUGAS';

    return Scaffold(
      body: Stack(
        children: [
          // Background warna
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF3B0E0E),
            ),
          ),

          // Lingkaran desain atas
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF5A0E0E),
              ),
            ),
          ),

          // Konten utama
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ================== LOGO =====================
                  Center(
                    child: Image.asset(
                      'lib/assets/images/logo.jpg',
                      height: 120,
                    ),
                  ),


                  const SizedBox(height: 10),

                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // ================== GRID MENU =====================
                  Expanded(
                    child: GridView(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      children: [
                        // --- MENU 1 ---
                        Card(
                          elevation: 4,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MenuScreen()),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.fastfood, size: 40),
                                SizedBox(height: 16),
                                Text('DAFTAR MENU'),
                              ],
                            ),
                          ),
                        ),

                        Card(
                          elevation: 4,
                          child: InkWell(
                            onTap: () {},
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.calendar_month, size: 40),
                                SizedBox(height: 16),
                                Text('DAFTAR PENERIMA'),
                              ],
                            ),
                          ),
                        ),

                        Card(
                          elevation: 4,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LaporanScreen()),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.book, size: 40),
                                SizedBox(height: 16),
                                Text('DAFTAR PENGADUAN'),
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
