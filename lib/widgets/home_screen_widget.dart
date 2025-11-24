import 'package:flutter/material.dart';
import 'package:project_rpll/providers/auth_provider.dart';
import 'package:project_rpll/screens/admin_user_screen.dart';
import 'package:project_rpll/screens/laporan_screen.dart';
import 'package:project_rpll/screens/menu_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  String displayName = '';
  String userRole = '';

  @override
  Future<void> getProfileData() async {
    final supabase = Supabase.instance.client;
    final userLoggedIn = supabase.auth.currentUser;
    if (userLoggedIn != null) {
      print("🔍 [DEBUG] User ID Login: ${userLoggedIn.id}");
      try {
        final data = await supabase
            .from('profiles')
            .select('username,user_roles(roles(nama_role))')
            .eq('id', userLoggedIn.id)
            .single();
        setState(() {
          displayName = data['username'] ?? 'Dashboard Petugas';
        });
        print("✅ [DEBUG] Data Ditemukan: $data");
        if (mounted) {
          setState(() {
            displayName = data['username'] ?? 'User';

            final List rolesData = data['user_roles'] ?? [];
            if (rolesData.isNotEmpty && rolesData[0]['roles'] != null) {
              userRole = rolesData[0]['roles']['nama_role'];
            } else {
              userRole = 'pendatang';
            }
            print("🔍 DEBUG ROLE: '$userRole'");
          });
        }
      } catch (e) {
        print('Gagal ambil profil : $e');
        setState(() {
          displayName =
              userLoggedIn.userMetadata?['username'] ?? 'Dashboard Petugas';
        });
      }
    }
  }

  List<Map<String, dynamic>> get menuItems {
    return [
      {
        'title': "Pengaduan",
        'icon': Icons.book,
        // Semua role boleh lihat
        'allowed_roles': ['admin', 'penanggungjawab_mbg', 'petugas_sppg'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LaporanScreen()),
        ),
      },
      {
        'title': "Jadwal",
        'icon': Icons.calendar_month,
        // Supir & Pendatang tidak butuh lihat jadwal
        'allowed_roles': ['sopir', 'admin', 'penanggungjawab_mbg'],
        'action': () {},
      },
      {
        'title': "Pemeriksaan",
        'icon': Icons.search,
        'allowed_roles': ['penanggungjawab_mbg'],
        'action': () {},
      },
      {
        'title': "Menu MBG",
        'icon': Icons.fastfood,
        // Hanya Admin & PJ MBG
        'allowed_roles': ['admin', 'penanggungjawab_mbg'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MenuScreen()),
        ),
      },
      {
        'title': "Kelola User (Admin)",
        'icon': Icons.person,
        // KHUSUS ADMIN
        'allowed_roles': ['admin'],
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminUserScreen()),
        ),
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background utama
          Container(decoration: const BoxDecoration(color: Color(0xFF3B0E0E))),

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
                  displayName,
                  style: const TextStyle(fontSize: 24, color: Colors.white70),
                ),

                const SizedBox(height: 32),

                // GRID MENU
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: menuItems
                        .where((menu) {
                          List<String> allowed = menu['allowed_roles'];
                          return allowed.contains(userRole);
                        })
                        .map((menu) {
                          return _menuCard(
                            icon: menu['icon'],
                            title: menu['title'],
                            onTap: menu['action'],
                          );
                        })
                        .toList(),
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
