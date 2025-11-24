import 'package:flutter/material.dart';
import 'package:project_rpll/providers/auth_provider.dart';
import 'package:project_rpll/screens/admin_user_screen.dart';
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
          // Background utama
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF3B0E0E),
            ),
          ),

          // Lingkaran dekoratif
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF5A0E0E),
              ),
            ),
          ),

          // Konten utama
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                Text(
                  "Selamat Datang,",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 32),

                // GRID MENU
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _menuCard(
                        icon: Icons.book,
                        title: "Pengaduan",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LaporanScreen()),
                          );
                        },
                      ),
                      _menuCard(
                        icon: Icons.calendar_month,
                        title: "Jadwal",
                        onTap: () {},
                      ),
                      _menuCard(
                        icon: Icons.search,
                        title: "Pemeriksaan",
                        onTap: () {},
                      ),
                      _menuCard(
                        icon: Icons.fastfood,
                        title: "Menu MBG",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MenuScreen()),
                          );
                        },
                      ),
                      _menuCard(
                        icon: Icons.person,
                        title: "Kelola User (Admin)",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminUserScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CARD custom agar warnanya sesuai tema
  Widget _menuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF5A0E0E), // warna gelap tema
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white, // ikon putih
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
