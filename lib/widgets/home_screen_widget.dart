import 'package:flutter/material.dart';
import 'package:project_rpll/screens/akun/admin_user_screen.dart';
import 'package:project_rpll/screens/pengaduan/laporan_screen.dart';
import 'package:project_rpll/screens/menu_mbg/menu_screen.dart';
import 'package:project_rpll/screens/pengaduan/pemeriksaan_screen.dart';
import 'package:project_rpll/services/profiles_service.dart';
import 'package:provider/provider.dart';
import 'package:project_rpll/screens/pengiriman/jadwal_pengiriman.dart';
import 'package:project_rpll/screens/pengaduan/laporan_pengembalian.dart';
import 'package:project_rpll/screens/pengiriman/daftar_penerima.dart';
import 'package:project_rpll/screens/pengiriman/rute_perkiraan_waktu.dart';
import 'package:project_rpll/widgets/notifikasi_screen.dart';

class HomeScreenWidget extends StatelessWidget {
  const HomeScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _HomeContent();
  }
}

class _HomeContent extends StatelessWidget {
  List<Map<String, dynamic>> _getMenuItems(BuildContext context) {
    return [
      {
        'title': "Daftar Pengaduan",
        'icon': Icons.book,
        'allowed_roles': ['admin', 'petugas_sppg'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LaporanScreen()),
        ),
      },
      {
        'title': "Jadwal Pengiriman",
        'icon': Icons.calendar_month,
        'allowed_roles': ['supir', 'admin'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JadwalPengirimanScreen()),
        ),
      },
      {
        'title': "Perkiraan Waktu",
        'icon': Icons.timer,
        'allowed_roles': ['penanggungjawab_mbg', 'admin'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                RutePerkiraanWaktuScreen(jam: "09.30", sekolah: "SMA 3"),
          ),
        ),
      },
      {
        'title': "Pengembalian",
        'icon': Icons.assignment_return,
        'allowed_roles': ['supir', 'admin'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LaporanPengembalian()),
        ),
      },
      {
        'title': "Kirim Pengaduan",
        'icon': Icons.send,
        'allowed_roles': ['penanggungjawab_mbg'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PemeriksaanScreen()),
        ),
      },
      {
        'title': "Daftar Menu",
        'icon': Icons.fastfood,
        'allowed_roles': ['admin', 'petugas_sppg'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MenuScreen()),
        ),
      },
      {
        'title': "Daftar Penerima",
        'icon': Icons.people,
        'allowed_roles': ['admin', 'petugas_sppg'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DaftarPenerimaScreen()),
        ),
      },
      {
        'title': "Kelola User",
        'icon': Icons.person,
        'allowed_roles': ['admin'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminUserScreen()),
        ),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // 2. KONSUMSI DATA DARI SERVICE
    return Scaffold(
      body: Consumer<ProfileService>(
        builder: (context, service, child) {
          // A. TAMPILAN LOADING
          if (service.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // B. AMBIL DATA DARI MODEL
          // (Data sudah disiapkan rapi oleh Model & Service)
          final profile = service.userProfile;

          final String displayName = profile?.username ?? 'User';

          // Ambil List Role dari Model (Model sudah mengurus parsing JSON-nya)
          final List<String> userRoles = profile?.roles ?? ['pendatang'];

          // C. FILTER MENU BERDASARKAN ROLE
          final menuList = _getMenuItems(context).where((menu) {
            List<String> allowed = menu['allowed_roles'];
            return userRoles.any((myRole) => allowed.contains(myRole));
          }).toList();

          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(color: Color(0xFF3B0E0E)),
              ),

              // Background Lingkaran
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

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    const Text(
                      "Selamat Datang,",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // TAMPILKAN NAMA (DARI SERVICE)
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // GRID MENU (YANG SUDAH DIFILTER)
                    Expanded(
                      child: GridView.builder(
                        itemCount: menuList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemBuilder: (context, index) {
                          final menu = menuList[index];
                          return _menuCard(
                            icon: menu['icon'],
                            title: menu['title'],
                            onTap: menu['action'],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      // Floating Action Button (Sama seperti sebelumnya)
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 20),
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF3B0E0E),
            shape: const CircleBorder(),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF5A0E0E),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
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
