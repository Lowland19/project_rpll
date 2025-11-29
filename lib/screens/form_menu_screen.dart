import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormMenuScreen extends StatefulWidget {
  const FormMenuScreen({super.key});

  @override
  State<FormMenuScreen> createState() => _FormMenuScreenState();
}

class _FormMenuScreenState extends State<FormMenuScreen> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController penerimaController = TextEditingController();
  String? jenisMakanan;
  String? hariTersedia;
  File? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => selectedImage = File(picked.path));
    }
  }

  Future<String?> uploadImage() async {
    if (selectedImage == null) return null;

    final fileName = "menu_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final storage = Supabase.instance.client.storage.from("menu_foto");

    await storage.upload(fileName, selectedImage!);
    return storage.getPublicUrl(fileName);
  }

  Future<void> saveMenu() async {
    try {
      final imgUrl = await uploadImage();

      await Supabase.instance.client.from("daftar_menu").insert({
        "nama_makanan": namaController.text,
        "jenis_makanan": jenisMakanan,
        "hari_tersedia": hariTersedia,
        "penerima": penerimaController.text,
        "foto_url": imgUrl,
      });

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A0E0E),
        title: const Text("Tambah Menu", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                selectedImage != null ? FileImage(selectedImage!) : null,
                child: selectedImage == null
                    ? const Icon(Icons.camera_alt, size: 32, color: Colors.white)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: namaController,
            style: const TextStyle(color: Colors.white),
            decoration: inputStyle("Nama Makanan"),
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
                .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: const TextStyle(color: Colors.white))))
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
                .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: const TextStyle(color: Colors.white))))
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
            onPressed: saveMenu,
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
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
