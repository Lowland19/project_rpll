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

  // Ganti controller teks dengan Variabel ID
  int? selectedPenerimaId;

  String? jenisMakanan;
  String? hariTersedia;

  File? selectedImage;
  Uint8List? webImage;
  String? fotoUrl;

  // List Data Lembaga dari DB
  List<Map<String, dynamic>> lembagaList = [];
  bool isLoadingLembaga = true;

  @override
  void initState() {
    super.initState();

    // 1. Isi data awal dari Menu yang dipilih
    namaController = TextEditingController(text: widget.menu['nama_makanan']);
    jenisMakanan = widget.menu['jenis_makanan'];
    hariTersedia = widget.menu['hari_tersedia'];
    fotoUrl = widget.menu['foto_url'];

    // Ambil ID Penerima Lama
    selectedPenerimaId = widget.menu['id_penerima'];

    // 2. Ambil List Lembaga buat Dropdown
    fetchLembaga();
  }

  Future<void> fetchLembaga() async {
    try {
      final response = await Supabase.instance.client
          .from('lembaga')
          .select('id, nama_lembaga')
          .order('nama_lembaga', ascending: true);

      setState(() {
        lembagaList = List<Map<String, dynamic>>.from(response);
        isLoadingLembaga = false;
      });
    } catch (e) {
      print("Error fetching lembaga: $e");
      setState(() => isLoadingLembaga = false);
    }
  }

  // ... (Fungsi Pick Image & Upload Image SAMA PERSIS seperti sebelumnya) ...
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
      return fotoUrl;
    }
  }
  // ... (End Fungsi Image) ...

  Future<void> updateMenu() async {
    // Validasi
    if (selectedPenerimaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap pilih penerima manfaat")),
      );
      return;
    }

    try {
      final imageUrl = await uploadImage();

      // 3. Update Database dengan ID Baru
      await Supabase.instance.client
          .from('daftar_menu')
          .update({
            'nama_makanan': namaController.text,
            'jenis_makanan': jenisMakanan,
            'hari_tersedia': hariTersedia,
            'id_penerima': selectedPenerimaId, // Update ID Penerima
            'foto_url': imageUrl,
          })
          .eq('id', widget.menu['id']);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal Update: $e")));
      }
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
          // FOTO
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
                child:
                    (selectedImage == null &&
                        webImage == null &&
                        fotoUrl == null)
                    ? const Icon(
                        Icons.camera_alt,
                        size: 32,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // NAMA
          TextField(
            controller: namaController,
            style: const TextStyle(color: Colors.white),
            decoration: inputStyle("Nama"),
          ),
          const SizedBox(height: 16),

          // JENIS
          DropdownButtonFormField(
            value: jenisMakanan,
            dropdownColor: const Color(0xFF5A0E0E),
            style: const TextStyle(color: Colors.white),
            decoration: inputStyle("Jenis Makanan"),
            onChanged: (v) => setState(() => jenisMakanan = v),
            items:
                [
                      'Sumber karbohidrat',
                      'Protein hewani',
                      'Protein nabati',
                      'Sayur',
                      'Buah',
                      'Sumber lemak',
                      'Susu',
                    ]
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 16),

          // HARI
          DropdownButtonFormField(
            value: hariTersedia,
            dropdownColor: const Color(0xFF5A0E0E),
            style: const TextStyle(color: Colors.white),
            decoration: inputStyle("Hari Tersedia"),
            onChanged: (v) => setState(() => hariTersedia = v),
            items: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat']
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(color: Colors.white)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),

          // ==========================================
          // DROPDOWN PENERIMA (SEARCHABLE / BIASA)
          // ==========================================
          // Disini saya pakai DropdownButton biasa agar sama gaya-nya dengan form lain.
          // Jika ingin Searchable, ganti dengan DropdownMenu seperti FormMenuScreen.
          isLoadingLembaga
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<int>(
                  value: selectedPenerimaId, // Nilai Awal dari DB
                  dropdownColor: const Color(0xFF5A0E0E),
                  style: const TextStyle(color: Colors.white),
                  decoration: inputStyle("Penerima Manfaat"),
                  items: lembagaList.map((item) {
                    return DropdownMenuItem<int>(
                      value: item['id'], // ID
                      child: Text(
                        item['nama_lembaga'], // Nama Teks
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedPenerimaId = value);
                  },
                ),

          // ==========================================
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.all(14),
            ),
            onPressed: updateMenu,
            child: const Text(
              "Simpan Perubahan",
              style: TextStyle(color: Colors.white),
            ),
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
