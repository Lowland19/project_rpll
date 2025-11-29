import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
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
  Uint8List? webImage;
  String? fotoUrl;

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
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        webImage = await picked.readAsBytes();
      } else {
        selectedImage = File(picked.path);
      }
      setState(() {});
    }
  }

  // ================= FIXED UPLOAD =================
  Future<String?> uploadImage() async {
    if (selectedImage == null && webImage == null) return fotoUrl;

    final fileName = "menu_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final storage = Supabase.instance.client.storage.from("menu_foto");

    try {
      if (kIsWeb) {
        await storage.uploadBinary(
          fileName,
          webImage!,
          fileOptions: const FileOptions(contentType: "image/jpeg"),
        );
      } else {
        final mimeType = lookupMimeType(selectedImage!.path);
        final bytes = await selectedImage!.readAsBytes();

        await storage.uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(contentType: mimeType),
        );
      }

      return storage.getPublicUrl(fileName);
    } catch (e) {
      print("Upload Error: $e");
      return fotoUrl;
    }
  }
  // ===============================================

  Future<void> updateMenu() async {
    try {
      final imageUrl = await uploadImage();

      await Supabase.instance.client.from('daftar_menu').update({
        'nama_makanan': namaController.text,
        'penerima': penerimaController.text,
        'jenis_makanan': jenisMakanan,
        'hari_tersedia': hariTersedia,
        'foto_url': imageUrl,
      }).eq('id', widget.menu['id']);

      Navigator.pop(context, true);
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
                backgroundImage: webImage != null
                    ? MemoryImage(webImage!)
                    : selectedImage != null
                    ? FileImage(selectedImage!)
                    : (fotoUrl != null ? NetworkImage(fotoUrl!) : null)
                as ImageProvider?,
                child: (selectedImage == null && webImage == null && fotoUrl == null)
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
              child: Text(e, style: const TextStyle(color: Colors.white)),
            ))
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
              child: Text(e, style: const TextStyle(color: Colors.white)),
            ))
                .toList(),
          ),

          const SizedBox(height: 16),
          DropdownButtonFormField(
            value: penerimaController.text.isNotEmpty
                ? penerimaController.text
                : null,
            dropdownColor: const Color(0xFF5A0E0E),
            style: const TextStyle(color: Colors.white),
            decoration: inputStyle("Penerima"),
            onChanged: (value) {
              setState(() {
                penerimaController.text = value.toString();
              });
            },
            items: penerimaList
                .map((item) => DropdownMenuItem(
              value: item['nama'],
              child: Text(item['nama'],
                  style: const TextStyle(color: Colors.white)),
            ))
                .toList(),
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(14)),
            onPressed: updateMenu,
            child: const Text("Simpan Perubahan",
                style: TextStyle(color: Colors.white)),
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
