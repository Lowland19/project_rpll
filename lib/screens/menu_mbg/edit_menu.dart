import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditMenuScreen extends StatefulWidget {
  final Map<String, dynamic> menu;

  const EditMenuScreen({super.key, required this.menu});

  @override
  State<EditMenuScreen> createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  late TextEditingController namaController;
  late TextEditingController penerimaController;

  String? jenisMakanan;
  String? hariTersedia;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.menu['nama_makanan']);
    penerimaController =
        TextEditingController(text: widget.menu['penerima']);

    List<String> jenisList = [
      'Sumber karbohidrat',
      'Protein hewani',
      'Protein nabati',
      'Sayur',
      'Buah',
      'Sumber lemak',
      'Susu',
    ];

    List<String> hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

    jenisMakanan =
    jenisList.contains(widget.menu['jenis_makanan']) ? widget.menu['jenis_makanan'] : null;
    hariTersedia =
    hariList.contains(widget.menu['hari_tersedia']) ? widget.menu['hari_tersedia'] : null;
  }

  Future<void> updateMenu() async {
    try {
      await Supabase.instance.client.from('daftar_menu').update({
        'nama_makanan': namaController.text,
        'jenis_makanan': jenisMakanan ?? widget.menu['jenis_makanan'],
        'penerima': penerimaController.text,
        'hari_tersedia': hariTersedia ?? widget.menu['hari_tersedia'],
      }).eq('id', widget.menu['id']);

      Navigator.pop(context, true); // trigger refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal update menu: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A0E0E),
        title: const Text("Edit Menu", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
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
              value: jenisMakanan,
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
              onChanged: (value) => setState(() => jenisMakanan = value),
              items: const [
                DropdownMenuItem(
                    value: 'Sumber karbohidrat',
                    child: Text('Sumber karbohidrat',
                        style: TextStyle(color: Colors.white))),
                DropdownMenuItem(
                    value: 'Protein hewani',
                    child: Text('Protein hewani',
                        style: TextStyle(color: Colors.white))),
                DropdownMenuItem(
                    value: 'Protein nabati',
                    child: Text('Protein nabati',
                        style: TextStyle(color: Colors.white))),
                DropdownMenuItem(
                    value: 'Sayur',
                    child:
                    Text('Sayur', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(
                    value: 'Buah',
                    child:
                    Text('Buah', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(
                    value: 'Sumber lemak',
                    child: Text('Sumber lemak',
                        style: TextStyle(color: Colors.white))),
                DropdownMenuItem(
                    value: 'Susu',
                    child:
                    Text('Susu', style: TextStyle(color: Colors.white))),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: hariTersedia,
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
              onChanged: (value) => setState(() => hariTersedia = value),
              items: const [
                DropdownMenuItem(
                    value: 'Senin',
                    child:
                    Text('Senin', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(
                    value: 'Selasa',
                    child:
                    Text('Selasa', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(
                    value: 'Rabu',
                    child:
                    Text('Rabu', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(
                    value: 'Kamis',
                    child:
                    Text('Kamis', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(
                    value: 'Jumat',
                    child:
                    Text('Jumat', style: TextStyle(color: Colors.white))),
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
                onPressed: updateMenu,
                child: const Text(
                  "Simpan Perubahan",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
