import 'dart:io';
import 'dart:typed_data'; // <--- Tambahan
import 'package:flutter/foundation.dart'; // <--- Tambahan untuk kIsWeb
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
  Uint8List? webImage; // <--- Tambahan untuk Web

  final List<Map<String, dynamic>> penerimaList = [
    {"nama": "PAUD Darul Falah"},
    {"nama": "Kober Qurrotu'ain Al Istiqomah"},
    {"nama": "PAUD KENANGA 12"},
    {"nama": "PAUD Melati 10"},
    {"nama": "PAUD Mawar Putih"},
    {"nama": "RA DARUL IKHLAS"},
    {"nama": "RA Darul Hufadz"},
    {"nama": "RA Nurul Huda"},
    {"nama": "Kober Nurul Huda Al Khudlory"},
    {"nama": "TK DAAIMUL HIDAYAH AL-QURANI"},
    {"nama": "TK HARAPAN MULYA"},
    {"nama": "TK PAMEKAR BUDI"},
    {"nama": "SDN Pasirkaliki Mandiri 1"},
    {"nama": "SDN Pasirkaliki Mandiri 2"},
    {"nama": "SMPN 12"},
    {"nama": "SMAN 3"},
    {"nama": "SLB B PRIMA BHAKTI"},
  ];

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        // Web
        webImage = await picked.readAsBytes();
      } else {
        // Android/iOS
        selectedImage = File(picked.path);
      }
      setState(() {});
    }
  }

  // ================= FIXED UPLOAD =================
  Future<String?> uploadImage() async {
    if (selectedImage == null && webImage == null) return null;

    final fileName = "menu_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final storage = Supabase.instance.client.storage.from("menu_foto");

    try {
      if (kIsWeb) {
        // Upload Web (pakai uploadBinary)
        await storage.uploadBinary(
          fileName,
          webImage!,
          fileOptions: const FileOptions(contentType: "image/jpeg"),
        );
      } else {
        // Upload Mobile
        await storage.upload(
          fileName,
          selectedImage!,
          fileOptions: const FileOptions(contentType: "image/jpeg"),
        );
      }

      return storage.getPublicUrl(fileName);
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }
  // ===============================================

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
                backgroundImage: kIsWeb
                    ? (webImage != null ? MemoryImage(webImage!) : null)
                    : (selectedImage != null ? FileImage(selectedImage!) : null),
                child: (webImage == null && selectedImage == null)
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
              'Sumber karbohidrat',
              'Protein hewani',
              'Protein nabati',
              'Sayur',
              'Buah',
              'Sumber lemak',
              'Susu'
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
          DropdownButtonFormField(
            value: penerimaController.text.isNotEmpty ? penerimaController.text : null,
            dropdownColor: const Color(0xFF5A0E0E),
            style: const TextStyle(color: Colors.white),
            decoration: inputStyle("Penerima"),
            onChanged: (value) {
              setState(() {
                penerimaController.text = value.toString();
              });
            },
            items: penerimaList.map((item) {
              return DropdownMenuItem(
                value: item['nama'],
                child: Text(
                  item['nama'],
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
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
