import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:project_rpll/screens/form_menu_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<List<dynamic>> _DaftarMenu;

  @override
  void initState() {
    super.initState();
    _DaftarMenu = getDaftarMenu();
  }

  Future<List<dynamic>> getDaftarMenu() async {
    final response = await Supabase.instance.client
        .from('daftar_menu')
        .select();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu MBG"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FormMenuScreen()),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _DaftarMenu,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text("Tidak ada data"));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final daftarMenu = snapshot.data!;
          return ListView.builder(
            itemCount: daftarMenu.length,
            itemBuilder: (context, index) {
              final menu = daftarMenu[index];
              return Card(
                child: ListTile(
                  title: Text(menu['nama_makanan']),
                  subtitle: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(menu['jenis_makanan']),
                        Text(menu['penerima']),
                        Text(menu['hari_tersedia']),
                      ],
                    ),
                  ),
                  trailing: Container(
                    width: 200,
                    height: 200,
                    child: Placeholder(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
