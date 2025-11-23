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
      appBar: AppBar(title: Text('Kelola User (Admin)')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: usersList.length,
              itemBuilder: (context, index) {
                final user = usersList[index];

                final List rolesData = user['user_roles'] ?? [];
                String currentRole = 'Tidak ada role';

                if (rolesData.isNotEmpty && rolesData[0]['roles'] != null) {
                  currentRole = rolesData[0]['roles']['nama_role'];
                }

                String? initialValue;
                if (currentRole != null && roleOptions.contains(currentRole)) {
                  initialValue = currentRole;
                }
                return Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['full_name'] ?? 'Tanpa Nama',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text("@${user['username'] ?? '_'}"),
                        SizedBox(height: 8),
                        DropdownButton<String>(
                          value: initialValue,
                          hint: Text(currentRole),
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
                                  title: Text("Ubah Role?"),
                                  content: Text(
                                    "Ubah ${user['username']} menjadi $newValue?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(c),
                                      child: Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(c);
                                        changeRole(user['id'], newValue);
                                      },
                                      child: Text('Ya, ubah'),
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
