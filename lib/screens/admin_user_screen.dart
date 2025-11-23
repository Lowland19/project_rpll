import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({super.key});

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen> {
  List<Map<String, dynamic>> usersList = [];
  bool isLoading = true;

  final List<String> roleOptions = [
    'admin',
    'penanggungjawab_mbg',
    'pendatang',
    'supir',
    'petugas_sppg',
  ];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final supabase = Supabase.instance.client;

      final data = await supabase
          .from('profiles')
          .select('id, full_name, username, user_roles(roles(nama_role))');

      setState(() {
        usersList = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetch: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> changeRole(String userId, String newRole) async {
    print("DEBUG: ID User = $userId");
    print("DEBUG: Role Baru = $newRole");

    try {
      await Supabase.instance.client.rpc(
        'update_user_role',
        params: {'target_user_id': userId, 'new_role_name': newRole},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Berhasil ubah role menjadi $newRole")),
      );

      fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ========== WARNA BACKGROUND ===============
      backgroundColor: const Color(0xFF3B0E0E),

      // ========== APPBAR ===============
      appBar: AppBar(
        title: const Text(
          'Kelola User (Admin)',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5A0E0E),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ========== BODY LIST USER =================
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: usersList.length,
        itemBuilder: (context, index) {
          final user = usersList[index];

          final List rolesData = user['user_roles'] ?? [];
          String currentRole = 'Tidak ada role';

          if (rolesData.isNotEmpty && rolesData[0]['roles'] != null) {
            currentRole = rolesData[0]['roles']['nama_role'];
          }

          String? initialValue;
          if (currentRole.isNotEmpty &&
              roleOptions.contains(currentRole)) {
            initialValue = currentRole;
          }

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['full_name'] ?? 'Tanpa Nama',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text("@${user['username'] ?? '_'}"),
                  const SizedBox(height: 10),

                  // DROPDOWN ROLE
                  DropdownButton<String>(
                    value: initialValue,
                    hint: Text(currentRole),
                    isExpanded: true,
                    items: roleOptions.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text("Ubah Role?"),
                            content: Text(
                                "Ubah ${user['username']} menjadi $newValue?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(c);
                                  changeRole(user['id'], newValue);
                                },
                                child: const Text('Ya, ubah'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
