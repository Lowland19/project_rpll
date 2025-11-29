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
  late TextEditingController penerimaController;
  late String? jenisMakanan;
  late String? hariTersedia;
  File? selectedImage;
  String? fotoUrl;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.menu['nama_makanan']);
    penerimaController = TextEditingController(text: widget.menu['penerima']);
    jenisMakanan = widget.menu['jenis_makanan'];
    hariTersedia = widget.menu['hari_tersedia'];
    fotoUrl = widget.menu['foto_url'];
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() => selectedImage = File(file.path));
    }
  }

  Future<String?> uploadImage() async {
    if (selectedImage == null) return fotoUrl; // pakai foto lama kalau tidak diganti

    final fileName = "menu_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final storage = Supabase.instance.client.storage.from("menu_foto");

    await storage.upload(fileName, selectedImage!);
    return storage.getPublicUrl(fileName);
  }

  Future<void> updateMenu() async {
    try {
      final imageUrl = await uploadImage();

      await Supabase.instance.client
          .from('daftar_menu')
          .update({
        'nama_makanan': namaController.text,
        'penerima': penerimaController.text,
        'jenis_makanan': jenisMakanan,
        'hari_tersedia': hariTersedia,
        'foto_url': imageUrl,
      })
          .eq('id', widget.menu['id']);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal Update: $e")),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: selectedImage != null
                    ? FileImage(selectedImage!)
                    : (fotoUrl != null ? NetworkImage(fotoUrl!) : null)
                as ImageProvider?,
                child: (selectedImage == null && fotoUrl == null)
                    ? const Icon(Icons.camera_alt, size: 32, color: Colors.white)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: namaController,
            style: const TextStyle(color: Colors.white),
            decoration: inputStyle("Nama"),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField(
            value: jenisMakanan,
            dropdownColor: const Color(0xFF5A0E0E),
            style: const TextStyle(color: Colors.white),
            decoration: inputStyle("Jenis Makanan"),
            onChanged: (v) => setState(() => jenisMakanan = v),
            items: [
              'Sumber karbohidrat', 'Protein hewani', 'Protein nabati',
              'Sayur', 'Buah', 'Sumber lemak', 'Susu'
            ]
                .map((e) =>
                DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white))))
                .toList(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField(
            value: hariTersedia,
            dropdownColor: const Color(0xFF5A0E0E),
            style: const TextStyle(color: Colors.white),
            decoration: inputStyle("Hari Tersedia"),
            onChanged: (v) => setState(() => hariTersedia = v),
            items: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat']
                .map((e) =>
                DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white))))
                .toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: penerimaController,
            style: const TextStyle(color: Colors.white),
            decoration: inputStyle("Penerima"),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, padding: const EdgeInsets.all(14)),
            onPressed: updateMenu,
            child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  InputDecoration inputStyle(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white),
    filled: true,
    fillColor: const Color(0xFF5A0E0E),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );
}
