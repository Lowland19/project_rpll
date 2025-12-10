import 'package:flutter/material.dart';
import 'package:project_rpll/screens/pengaduan/daftar_scan.dart';
import 'package:project_rpll/screens/pengaduan/pengaduan_screen.dart';
import 'package:project_rpll/screens/pengaduan/scan_pisang.dart';
import 'package:provider/provider.dart';

// --- IMPORT SCREENS ---
import 'package:project_rpll/screens/akun/admin_user_screen.dart';
import 'package:project_rpll/screens/pengaduan/laporan_screen.dart';
import 'package:project_rpll/screens/menu_mbg/menu_screen.dart';
import 'package:project_rpll/screens/pengaduan/pemeriksaan_screen.dart';
import 'package:project_rpll/screens/pengiriman/pantau_lokasi_screen.dart';
import 'package:project_rpll/screens/pengiriman/jadwal_pengiriman.dart';
import 'package:project_rpll/screens/pengaduan/laporan_pengembalian.dart';
import 'package:project_rpll/screens/pengiriman/daftar_penerima.dart';
import 'package:project_rpll/widgets/notifikasi_screen.dart';

// --- IMPORT SERVICES ---
import 'package:project_rpll/services/peta_service.dart'; // Pastikan nama service benar
import 'package:project_rpll/services/profiles_service.dart';

class HomeScreenWidget extends StatelessWidget {
  const HomeScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeContent();
  }
}

// 1. CLASS WIDGET (Hanya jembatan)
class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

// 2. CLASS STATE (Semua logika & UI di sini)
class _HomeContentState extends State<_HomeContent> {
  // Instance Service
  final PetaService _petaService = PetaService();

  // State Variables
  String? _statusPengiriman;
  bool _isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    // Cek status pengiriman saat halaman pertama kali dibuka
    _cekStatusTerkini();
  }

  // --- FUNGSI CEK STATUS (Otomatis jalan di awal) ---
  Future<void> _cekStatusTerkini() async {
    try {
      final data = await _petaService.cariRuteSaya();

      if (mounted) {
        setState(() {
          _statusPengiriman = data?['status'];
          _isLoadingStatus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStatus = false);
      }
    }
  }

  // --- FUNGSI KLIK TOMBOL PANTAU ---
  Future<void> _handlePantauSaya(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final myJadwal = await _petaService.cariRuteSaya();

      if (context.mounted) Navigator.pop(context); // Tutup Loading

      if (myJadwal != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantauLokasiScreen(
              namaSekolah: myJadwal['nama'],
              idMenu: myJadwal['id_menu'] ?? 0,
              latTujuan: myJadwal['lat_tujuan'],
              longTujuan: myJadwal['long_tujuan'],
              latAsal: myJadwal['lat_dapur'] ?? 0.0,
              longAsal: myJadwal['long_dapur'] ?? 0.0,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- LIST MENU ---
  List<Map<String, dynamic>> _getMenuItems(BuildContext context) {
    // Logic: Jika status 'selesai', tombol jadi non-aktif
    bool isSelesai = _statusPengiriman == 'selesai';

    return [
      {
        'title': "Daftar Pengaduan",
        'icon': Icons.book,
        'allowed_roles': [ 'petugas_sppg'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LaporanScreen()),
        ),
      },

      {
        'title': "Jadwal Pengiriman",
        'icon': Icons.calendar_month,
        'allowed_roles': ['sopir'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JadwalPengirimanScreen()),
        ),
      },
      {
        'title': isSelesai ? "Selesai" : "Perkiraan Waktu",
        'icon': Icons.timer,
        'allowed_roles': ['penanggungjawab_mbg'],
        // Jika selesai, aksi dimatikan (null)
        'action': isSelesai ? null : () => _handlePantauSaya(context),
        'isDisabled': isSelesai,
      },
      {
        'title': "Pengembalian",
        'icon': Icons.assignment_return,
        'allowed_roles': ['sopir'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LaporanPengembalian()),
        ),
      },
      {
        'title': "Periksa makanan",
        'icon': Icons.search,
        'allowed_roles': ['siswa'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ScanPisangScreen()),
        ),
      },
      {
        'title': "Daftar Menu",
        'icon': Icons.fastfood,
        'allowed_roles': [ 'petugas_sppg'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MenuScreen()),
        ),
      },
      {
        'title': "Daftar Penerima",
        'icon': Icons.people,
        'allowed_roles': ['petugas_sppg'],
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
      {
        'title': "Kirim Pengaduan",
        'icon': Icons.send,
        'allowed_roles': ['penanggungjawab_mbg'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PengaduanScreen()),
        ),
      },
      {
        'title': "Daftar Hasil Scan",
        'icon': Icons.person,
        'allowed_roles': ['petugas_sppg'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DaftarScanScreen()),
        ),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProfileService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = service.userProfile;
          final String displayName = profile?.username ?? 'User';
          final List<String> userRoles = profile?.roles ?? ['pendatang'];

          // Filter Menu
          final menuList = _getMenuItems(context).where((menu) {
            List<String> allowed = menu['allowed_roles'];
            return userRoles.any((myRole) => allowed.contains(myRole));
          }).toList();

          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(color: Color(0xFF3B0E0E)),
              ),
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
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
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
                            isDisabled: menu['isDisabled'] ?? false,
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
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    final Color cardColor = isDisabled
        ? Colors.grey.shade700
        : const Color(0xFF5A0E0E);
    final Color iconColor = isDisabled ? Colors.white38 : Colors.white;
    final Color textColor = isDisabled ? Colors.white38 : Colors.white;

    return Card(
      color: cardColor,
      elevation: isDisabled ? 0 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor),
            ),

            // Loading kecil di tombol jika status sedang dicek
            if (_isLoadingStatus && title == "Perkiraan Waktu")
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
