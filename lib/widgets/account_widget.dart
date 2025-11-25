import 'package:flutter/material.dart';
import 'package:project_rpll/providers/auth_provider.dart';
import 'package:project_rpll/screens/start_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountWidget extends StatefulWidget {
  const AccountWidget({super.key});
  
  @override
  State<AccountWidget> createState() => _AccountWidgetState();
}

Future<void> getUserData() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  if (user == null) {
    print('user belum login');
  }
  try{
    final data = await supabase.from('profiles').select('username').eq('id', user.id).single();
  }
}

class _AccountWidgetState extends State<AccountWidget> {
  final userLoggedIn = Supabase.instance.client.auth.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background utama
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
                mainAxisSize: MainAxisSize
                    .min, // agar Column tidak mengambil seluruh tinggi
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    'https://thumbs.dreamstime.com/b/creative-illustration-default-avatar-profile-placeholder-isolated-background-art-design-grey-photo-blank-template-mockup-144855718.jpg',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Test',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Test',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  const SizedBox(height: 16),

                  // === TOMBOL EDIT PROFILE ===
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfile()),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // === TOMBOL LOGOUT ===
                  ElevatedButton.icon(
                    onPressed: () {
                      AuthProvider().logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => StartScreen()),
                      );
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
      ),
    );
  }
}
