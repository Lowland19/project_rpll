import 'package:flutter/material.dart';
import 'package:project_rpll/screens/form_menu_screen.dart';
import 'package:project_rpll/screens/edit_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Map<String, dynamic>> daftarMenu = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    try {
      setState(() => isLoading = true);

      final response = await Supabase.instance.client
          .from('daftar_menu')
          .select('*')
          .order('id', ascending: true);

      setState(() {
        daftarMenu = response
            .map<Map<String, dynamic>>(
                (item) => Map<String, dynamic>.from(item))
            .toList();

        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetch: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteMenu(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Menu"),
        content: const Text("Apakah Anda yakin ingin menghapus menu ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client
          .from('daftar_menu')
          .delete()
          .eq('id', id);

      fetchMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A0E0E),
        title: const Text("Menu MBG", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FormMenuScreen()),
              ).then((value) {
                if (value == true) fetchMenu();
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : daftarMenu.isEmpty
          ? const Center(
        child: Text(
          "Tidak ada data",
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: daftarMenu.length,
        itemBuilder: (context, index) {
          final menu = daftarMenu[index];
          final fotoUrl = menu['foto_url'] ?? '';

          return Card(
            color: const Color(0xFF5A0E0E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(
                menu['nama_makanan'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Jenis Makanan: ${menu['jenis_makanan']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "Penerima: ${menu['penerima']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "Hari Tersedia: ${menu['hari_tersedia']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.white),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditMenuScreen(menu: menu),
                              ),
                            );
                            if (result == true) fetchMenu();
                          },
                        ),
                        IconButton(
                          icon:
                          const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteMenu(menu['id']),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: fotoUrl.isNotEmpty
                      ? Image.network(
                    fotoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image,
                        size: 40, color: Colors.white),
                  )
                      : Container(
                    color: Colors.black26,
                    child: const Icon(Icons.image_not_supported,
                        size: 40, color: Colors.white70),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
