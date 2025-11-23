import 'package:flutter/material.dart';
import 'package:project_rpll/screens/menu_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormMenuScreen extends StatefulWidget {
  const FormMenuScreen({super.key});

  @override
  State<FormMenuScreen> createState() => _FormMenuScreenState();
}

class _FormMenuScreenState extends State<FormMenuScreen> {
  final namaController = TextEditingController();
  final penerimaController = TextEditingController();
  String? jenisMakanan = 'Basah';
  String? hariTersedia = 'Senin';

  Future<void> tambahMenu() async {
    try {
      final nama = namaController.text;
      final penerima = penerimaController.text;

      await Supabase.instance.client.from('daftar_menu').insert({
        'nama_makanan': nama,
        'penerima': penerima,
        'jenis_makanan': jenisMakanan,
        'hari_tersedia': hariTersedia,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal menambah menu: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A0E0E),
        title: const Text("Tambah Menu", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFF5A0E0E),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                TextField(
                  controller: namaController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Nama",
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: const Color(0xFF5A0E0E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: 'Basah',
                  dropdownColor: const Color(0xFF5A0E0E),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Jenis Makanan",
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: const Color(0xFF5A0E0E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => jenisMakanan = value);
                  },
                  items: const [
                    DropdownMenuItem(
                        value: 'Basah',
                        child: Text('Basah', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(
                        value: 'Kering',
                        child: Text('Kering', style: TextStyle(color: Colors.white))),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: 'Senin',
                  dropdownColor: const Color(0xFF5A0E0E),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Hari Tersedia",
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: const Color(0xFF5A0E0E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => hariTersedia = value);
                  },
                  items: const [
                    DropdownMenuItem(
                        value: 'Senin',
                        child: Text('Senin', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(
                        value: 'Selasa',
                        child: Text('Selasa', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(
                        value: 'Rabu',
                        child: Text('Rabu', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(
                        value: 'Kamis',
                        child: Text('Kamis', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(
                        value: 'Jumat',
                        child: Text('Jumat', style: TextStyle(color: Colors.white))),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: penerimaController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Penerima",
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: const Color(0xFF5A0E0E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: tambahMenu,
                    child: const Text(
                      "Tambah Menu",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
