import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_rpll/providers/auth_provider.dart';
import 'package:project_rpll/screens/akun/edit_profil.dart';
import 'package:project_rpll/screens/start_screen.dart';
import 'package:project_rpll/services/profiles_service.dart';

class AccountWidget extends StatelessWidget {
  const AccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. KITA TIDAK MEMBUAT SERVICE BARU DI SINI
    // Karena kita sudah membuatnya di main.dart (Global Provider).
    // Kita cukup langsung menggunakannya.

    // Panggil fetch sekali saat halaman dibuka (biar data terbaru)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileService>().fetchUserProfile();
    });

    return Scaffold(
      body: Consumer<ProfileService>(
        builder: (context, service, child) {
          // A. TAMPILAN LOADING
          if (service.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // B. AMBIL DATA DARI SERVICE
          final profile = service.userProfile;
          final String username = profile?.username ?? 'Tanpa Nama';
          final String email = profile?.email ?? '-';
          final String avatarUrl = profile?.avatarUrl ?? '';

          return Stack(
            children: [
              Container(color: const Color(0xFF3B0E0E)),

              // Background Lingkaran
              Positioned(
                top: -50,
                left: -40,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF5A0E0E),
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- FOTO PROFIL ---
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white,
                        backgroundImage: (avatarUrl.isNotEmpty)
                            ? NetworkImage(avatarUrl)
                            : const NetworkImage(
                                "https://i.ibb.co/r2vC7F4/default-avatar.png",
                              ),
                        onBackgroundImageError: (_, __) {},
                      ),

                      const SizedBox(height: 16),

                      // --- USERNAME ---
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // --- EMAIL ---
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- TOMBOL EDIT PROFILE ---
                      ElevatedButton.icon(
                        onPressed: () {
                          // Pindah ke halaman Edit (Tanpa .then, karena Service otomatis update)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfile(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // --- TOMBOL LOGOUT ---
                      ElevatedButton.icon(
                        onPressed: () async {
                          context.read<ProfileService>().clearData();
                          await context.read<AuthProvider>().logout();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StartScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
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
