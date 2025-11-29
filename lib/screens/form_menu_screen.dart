import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditMenuScreen extends StatefulWidget {
  final Map<String, dynamic> menu;

  const EditMenuScreen({super.key, required this.menu});

  @override
  State<EditMenuScreen> createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  late TextEditingController namaController;

  String? jenisMakanan;
  String? hariTersedia;
  String? penerima;

  File? selectedImage;
  String? existingImageUrl;

  final List<String> penerimaList = [
    'PAUD Darul Falah',
    'Kober Qurrotu\'ain Al Istiqomah',
    'PAUD KENANGA 12',
    'PAUD Melati 10',
    'PAUD Mawar Putih',
    'RA DARUL IKHLAS',
    'RA Darul Hufadz',
    'RA Nurul Huda',
    'Kober Nurul Huda Al Khudlory',
    'TK DAAIMUL HIDAYAH AL-QURANI',
    'TK HARAPAN MULYA',
    'TK PAMEKAR BUDI',
    'SDN Pasirkaliki Mandiri 1',
    'SDN Pasir Kaliki Mandiri 2',
    'SMPN 12',
    'SMAN 3',
    'SLB B PRIMA BHAKTI'
  ];

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.menu['nama_makanan']);
    existingImageUrl = widget.menu['foto_url'];

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

    penerima =
    penerimaList.contains(widget.menu['penerima']) ? widget.menu['penerima'] : null;
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() => selectedImage = File(file.path));
    }
  }

  Future<String?> uploadImage() async {
    if (selectedImage == null) return existingImageUrl;

    final fileName = "menu_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final storage = Supabase.instance.client.storage.from("menu_foto");

    await storage.upload(fileName, selectedImage!);

    return storage.getPublicUrl(fileName);
  }

  Future<void> updateMenu() async {
    try {
      final imageUrl = await uploadImage();

      await Supabase.instance.client.from('daftar_menu').update({
        'nama_makanan': namaController.text,
        'jenis_makanan': jenisMakanan,
        'penerima': penerima,
        'hari_tersedia': hariTersedia,
        'foto_url': imageUrl,
      }).eq('id', widget.menu['id']);

      Navigator.pop(context, true);
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
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!)
                      : (existingImageUrl != null
                      ? NetworkImage(existingImageUrl!) as ImageProvider
                      : null),
                  child: selectedImage == null && existingImageUrl == null
                      ? const Icon(Icons.camera_alt, size: 32, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => jenisMakanan = value),
              items: const [
                DropdownMenuItem(value: 'Sumber karbohidrat', child: Text('Sumber karbohidrat')),
                DropdownMenuItem(value: 'Protein hewani', child: Text('Protein hewani')),
                DropdownMenuItem(value: 'Protein nabati', child: Text('Protein nabati')),
                DropdownMenuItem(value: 'Sayur', child: Text('Sayur')),
                DropdownMenuItem(value: 'Buah', child: Text('Buah')),
                DropdownMenuItem(value: 'Sumber lemak', child: Text('Sumber lemak')),
                DropdownMenuItem(value: 'Susu', child: Text('Susu')),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => hariTersedia = value),
              items: const [
                DropdownMenuItem(value: 'Senin', child: Text('Senin')),
                DropdownMenuItem(value: 'Selasa', child: Text('Selasa')),
                DropdownMenuItem(value: 'Rabu', child: Text('Rabu')),
                DropdownMenuItem(value: 'Kamis', child: Text('Kamis')),
                DropdownMenuItem(value: 'Jumat', child: Text('Jumat')),
              ],
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: penerima,
              dropdownColor: const Color(0xFF5A0E0E),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Penerima",
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: const Color(0xFF5A0E0E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => penerima = value),
              items: penerimaList
                  .map((nama) =>
                  DropdownMenuItem(value: nama, child: Text(nama, style: const TextStyle(color: Colors.white))))
                  .toList(),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: updateMenu,
              child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
