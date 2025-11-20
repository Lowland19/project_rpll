import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormMenuScreen extends StatefulWidget {
  const FormMenuScreen({super.key});

  @override
  State<FormMenuScreen> createState() => _FormMenuScreenState();
}

class _FormMenuScreenState extends State<FormMenuScreen> {
  final namaController = TextEditingController();
  final penerimaController = TextEditingController();
  String? jenisMakanan;
  String? hariTersedia;

  Future<void> tambahMenu() async {
    try {
      final nama = namaController.text;
      final penerima = penerimaController.text;

      await Supabase.instance.client
          .from('daftar_menu')
          .insert({
            'nama_makanan': nama,
            'penerima': penerima,
            'jenis_makanan': jenisMakanan,
            'hari_tersedia': hariTersedia,
          })
          .select()
          .single();

      // Jika berhasil
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menambah menu: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Menu')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Jenis Makanan'),
              initialValue: 'Basah',
              onChanged: (value) {
                setState(() {
                  jenisMakanan = value;
                });
              },
              items: const [
                DropdownMenuItem(value: 'Basah', child: Text('Basah')),
                DropdownMenuItem(value: 'Kering', child: Text('Kering')),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Hari Tersedia'),
              initialValue: 'Senin',
              onChanged: (value) {
                setState(() {
                  hariTersedia = value;
                });
              },
              items: const [
                DropdownMenuItem(value: 'Senin', child: Text('Senin')),
                DropdownMenuItem(value: 'Selasa', child: Text('Selasa')),
                DropdownMenuItem(value: 'Rabu', child: Text('Rabu')),
                DropdownMenuItem(value: 'Kamis', child: Text('Kamis')),
                DropdownMenuItem(value: 'Jumat', child: Text('Jumat')),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: penerimaController,
              decoration: const InputDecoration(labelText: 'Penerima'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: tambahMenu,
              child: const Text('Tambah Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
