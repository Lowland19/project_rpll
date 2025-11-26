import 'package:flutter/material.dart';
import 'package:project_rpll/providers/auth_provider.dart';
import 'package:project_rpll/screens/edit_profil.dart';
import 'package:project_rpll/screens/start_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountWidget extends StatefulWidget {
  const AccountWidget({super.key});

  @override
  State<AccountWidget> createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  String username = 'Memuat...';
  String email = 'Memuat...';
  String avatarUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      setState(() {
        email = user.email ?? '-';
      });

      try {
        final data = await supabase
            .from('profiles')
            .select('username, avatar_url')
            .eq('id', user.id)
            .single();

        // Jika avatar di storage, convert ke public URL
        String finalUrl = '';
        if (data['avatar_url'] != null && data['avatar_url'].toString().isNotEmpty) {
          finalUrl = supabase.storage.from('avatars').getPublicUrl(data['avatar_url']);
        }

        if (mounted) {
          setState(() {
            username = data['username'] ?? 'Tanpa Nama';
            avatarUrl = finalUrl;
            isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error mengambil profil: $e');
        setState(() {
          username = 'Gagal memuat';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Container(decoration: const BoxDecoration(color: Color(0xFF3B0E0E))),
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

                  // === Avatar yang fix error ===
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : const AssetImage('assets/default_avatar.png') as ImageProvider,
                    onBackgroundImageError: (_, __) {},
                  ),

                  const SizedBox(height: 16),

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

                  Text(
                    email,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditProfile()),
                      ).then((_) => _fetchUserData()); // Refresh setelah edit
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: () {
                      AuthProvider().logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => StartScreen()),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
