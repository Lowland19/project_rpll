import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
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

  // Variabel ID untuk disimpan ke Database
  int? selectedPenerimaId;

  String? jenisMakanan;
  String? hariTersedia;
  File? selectedImage;
  Uint8List? webImage;

  List<Map<String, dynamic>> lembagaList = [];
  bool isLoadingLembaga = true;

  @override
  void initState() {
    super.initState();
    fetchLembaga();
  }

  Future<void> fetchLembaga() async {
    try {
      final response = await Supabase.instance.client
          .from('lembaga')
          .select('id, nama_lembaga')
          .order('nama_lembaga', ascending: true); // Urutkan A-Z biar rapi

      setState(() {
        lembagaList = List<Map<String, dynamic>>.from(response);
        isLoadingLembaga = false;
      });
    } catch (e) {
      print("Error fetching lembaga: $e");
      setState(() => isLoadingLembaga = false);
    }
  }

  // ... (Fungsi pickImage dan uploadImage SAMA SEPERTI SEBELUMNYA) ...
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
    if (selectedImage == null && webImage == null) return null;
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
        await storage.upload(
          fileName,
          selectedImage!,
          fileOptions: const FileOptions(contentType: "image/jpeg"),
        );
      }
      return storage.getPublicUrl(fileName);
    } catch (e) {
      return null;
    }
  }
  // ... (End Fungsi Image) ...

  Future<void> saveMenu() async {
    if (selectedPenerimaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap cari dan pilih penerima manfaat")),
      );
      return;
    }

    try {
      final imgUrl = await uploadImage();

      await Supabase.instance.client.from("daftar_menu").insert({
        "nama_makanan": namaController.text,
        "jenis_makanan": jenisMakanan,
        "hari_tersedia": hariTersedia,
        "id_penerima": selectedPenerimaId, // Tetap simpan ID-nya
        "foto_url": imgUrl,
      });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Foto Profile
          Center(
            child: GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white10,
                backgroundImage: kIsWeb
                    ? (webImage != null ? MemoryImage(webImage!) : null)
                    : (selectedImage != null
                          ? FileImage(selectedImage!)
                          : null),
                child: (webImage == null && selectedImage == null)
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
              'Susu',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField(
            value: hariTersedia,
            dropdownColor: const Color(0xFF5A0E0E),
            style: const TextStyle(color: Colors.white),
            decoration: inputStyle("Hari Tersedia"),
            onChanged: (v) => setState(() => hariTersedia = v),
            items: [
              'Senin',
              'Selasa',
              'Rabu',
              'Kamis',
              'Jumat',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          ),
          const SizedBox(height: 16),

          // ==========================================
          // FITUR PENCARIAN PENERIMA (SEARCHABLE)
          // ==========================================
          isLoadingLembaga
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownMenu<int>(
                      width: constraints.maxWidth, // Agar lebar full
                      enableFilter: true, // AKTIFKAN FITUR CARI
                      requestFocusOnTap: true, // Keyboard muncul saat diklik
                      leadingIcon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Cari Penerima Manfaat",
                        style: TextStyle(color: Colors.white),
                      ),

                      // Style Input
                      textStyle: const TextStyle(color: Colors.white),
                      inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        fillColor: const Color(0xFF5A0E0E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelStyle: const TextStyle(color: Colors.white70),
                      ),

                      // Style Menu Dropdown
                      menuStyle: MenuStyle(
                        backgroundColor: MaterialStateProperty.all(
                          const Color(0xFF5A0E0E),
                        ),
                      ),

                      // Saat user memilih salah satu
                      onSelected: (int? id) {
                        setState(() {
                          selectedPenerimaId = id;
                        });
                      },

                      // Konversi Data List ke Dropdown Entry
                      dropdownMenuEntries: lembagaList.map((item) {
                        return DropdownMenuEntry<int>(
                          value: item['id'], // Nilai dibalik layar (ID)
                          label: item['nama_lembaga'], // Yang terlihat (Nama)
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(
                              Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

          // ==========================================
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.all(14),
            ),
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
