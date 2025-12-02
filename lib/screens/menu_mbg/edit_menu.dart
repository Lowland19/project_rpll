import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';

class EditMenuScreen extends StatefulWidget {
  final Map<String, dynamic> menu;

  const EditMenuScreen({super.key, required this.menu});

  @override
  State<EditMenuScreen> createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  late TextEditingController namaController;

  int? selectedPenerimaId;
  String? hariTersedia;

  File? selectedImage;
  Uint8List? webImage;
  String? fotoUrl;

  List<Map<String, dynamic>> lembagaList = [];
  bool isLoadingLembaga = true;

  // MULTI SELECT
  List<String> selectedJenis = [];
  Map<String, List<String>> selectedDetail = {};

  String persenGizi = "-";
  String statusGizi = "-";

  /// MENU RELASI
  Map<String, List<String>> subMenuOptions = {
    "Sumber karbohidrat": ["Nasi Goreng", "Nasi Putih", "Bubur Ayam", "Roti", "Kentang"],
    "Protein hewani": ["Ayam Goreng", "Telur", "Ikan Bandeng", "Daging Sapi"],
    "Protein nabati": ["Tahu", "Tempe", "Kacang Merah", "Kedelai"],
    "Sayur": ["Tumis Kangkung", "Sayur Sop", "Sayur Bayam"],
    "Buah": ["Pisang", "Apel", "Pepaya", "Semangka"],
    "Sumber lemak": ["Mentega", "Keju", "Minyak Sayur"],
    "Susu": ["Susu UHT", "Susu Bubuk"],
  };

  /// TABEL PERHITUNGAN GIZI
  final Map<String, Map<String, double>> giziTable = {
    "TK/PAUD/RA": {"Karbohidrat": 20.9, "Protein": 25.0, "Lemak": 23.7},
    "Siswa SD": {"Karbohidrat": 21.6, "Protein": 28.1, "Lemak": 27.5},
    "Siswa SMP": {"Karbohidrat": 30.8, "Protein": 34.8, "Lemak": 30.7},
    "Siswa SMA": {"Karbohidrat": 30.4, "Protein": 36.4, "Lemak": 31.0},
  };

  final Map<String, String> kategoriPenerima = {
    "PAUD Darul Falah": "TK/PAUD/RA",
    "Kober Qurrotu'ain Al Istiqomah": "TK/PAUD/RA",
    "PAUD KENANGA 12": "TK/PAUD/RA",
    "PAUD Melati 10": "TK/PAUD/RA",
    "PAUD Mawar Putih": "TK/PAUD/RA",
    "RA DARUL IKHLAS": "TK/PAUD/RA",
    "RA Darul Hufadz": "TK/PAUD/RA",
    "RA Nurul Huda": "TK/PAUD/RA",
    "Kober Nurul Huda Al Khudlory": "TK/PAUD/RA",
    "TK DAAIMUL HIDAYAH AL-QURANI": "TK/PAUD/RA",
    "TK HARAPAN MULYA": "TK/PAUD/RA",
    "TK PAMEKAR BUDI": "TK/PAUD/RA",
    "SDN Pasirkaliki Mandiri 1": "Siswa SD",
    "SDN Pasir Kaliki Mandiri 2": "Siswa SD",
    "SMPN 12": "Siswa SMP",
    "SMAN 3": "Siswa SMA",
    "SLB B PRIMA BHAKTI": "Siswa SD",
  };

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.menu['nama_makanan']);
    jenisMakananFromDB();
    hariTersedia = widget.menu['hari_tersedia'];
    fotoUrl = widget.menu['foto_url'];
    selectedPenerimaId = widget.menu['id_penerima'];
    fetchLembaga();
    updatePersenGizi();
  }

  void jenisMakananFromDB() {
    if (widget.menu['jenis_makanan'] != null) {
      // Ambil jenis makanan
      selectedJenis = (widget.menu['jenis_makanan'] as String).split(', ');

      // Ambil detail makanan
      if (widget.menu['detail_makanan'] != null) {
        List<String> detailDb = (widget.menu['detail_makanan'] as String).split(', ');

        for (var jenis in selectedJenis) {
          List<String> filtered = subMenuOptions[jenis]!
              .where((item) => detailDb.contains(item))
              .toList();
          selectedDetail[jenis] = filtered;
        }
      } else {
        for (var jenis in selectedJenis) {
          selectedDetail[jenis] = [];
        }
      }
    }
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
      setState(() => isLoadingLembaga = false);
      print("Error fetching lembaga: $e");
    }
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

  Future<String?> uploadImage() async {
    if (selectedImage == null && webImage == null) return fotoUrl;
    final fileName = "menu_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final storage = Supabase.instance.client.storage.from("menu_foto");
    try {
      if (kIsWeb) {
        await storage.uploadBinary(fileName, webImage!,
            fileOptions: const FileOptions(contentType: "image/jpeg"));
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

  void updatePersenGizi() {
    if (selectedPenerimaId == null || selectedJenis.isEmpty) {
      setState(() {
        persenGizi = "-";
        statusGizi = "-";
      });
      return;
    }
    final penerima = lembagaList.firstWhere(
            (e) => e['id'] == selectedPenerimaId,
        orElse: () => {"nama_lembaga": ""});
    final kategori = kategoriPenerima[penerima["nama_lembaga"]] ?? "Siswa SD";

    List<double> totalNilai = [];
    for (var kategoriMakanan in selectedJenis) {
      String gizi = (kategoriMakanan == "Sumber karbohidrat" ||
          kategoriMakanan == "Sayur" ||
          kategoriMakanan == "Buah")
          ? "Karbohidrat"
          : (kategoriMakanan == "Sumber lemak")
          ? "Lemak"
          : "Protein";
      final nilai = giziTable[kategori]?[gizi];
      if (nilai != null) totalNilai.add(nilai);
    }
    double total = totalNilai.fold(0, (a, b) => a + b);
    setState(() {
      persenGizi = "${total.toStringAsFixed(1)}%";
      statusGizi = total >= 100 ? "✔ Tercukupi" : "❌ Belum Tercukupi";
    });
  }

  Future<void> updateMenu() async {
    if (selectedJenis.isEmpty || selectedDetail.isEmpty || selectedPenerimaId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Harap lengkapi semua data!")));
      return;
    }
    try {
      final imgUrl = await uploadImage();
      await Supabase.instance.client.from("daftar_menu").update({
        "nama_makanan": namaController.text,
        "jenis_makanan": selectedJenis.join(", "),
        "detail_makanan": selectedDetail.values.expand((e) => e).join(", "),
        "hari_tersedia": hariTersedia,
        "id_penerima": selectedPenerimaId,
        "persen_gizi": persenGizi,
        "status_gizi": statusGizi,
        "foto_url": imgUrl,
      }).eq('id', widget.menu['id']);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal Update: $e")));
      }
    }
  }

  Widget buildMultiSelectJenis() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.brown.shade800,
          builder: (_) => StatefulBuilder(
            builder: (context, setStateSheet) {
              return ListView(
                children: subMenuOptions.keys.map((item) {
                  return CheckboxListTile(
                    title: Text(item, style: const TextStyle(color: Colors.white)),
                    value: selectedJenis.contains(item),
                    onChanged: (v) {
                      setStateSheet(() {
                        if (v == true) {
                          selectedJenis.add(item);
                          selectedDetail[item] = [];
                        } else {
                          selectedJenis.remove(item);
                          selectedDetail.remove(item);
                        }
                      });
                      updatePersenGizi();
                      setState(() {});
                    },
                  );
                }).toList(),
              );
            },
          ),
        );
      },
      child: boxField(
          selectedJenis.isEmpty ? "Pilih Jenis Makanan" : selectedJenis.join(", ")),
    );
  }

  Widget buildMultiSelectDetail() {
    if (selectedJenis.isEmpty) return const SizedBox();
    return Column(
      children: selectedJenis.map((kategori) {
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.brown.shade800,
              builder: (_) => StatefulBuilder(
                builder: (context, setStateSheet) {
                  return ListView(
                    children: subMenuOptions[kategori]!.map((item) {
                      return CheckboxListTile(
                        title: Text(item, style: const TextStyle(color: Colors.white)),
                        value: selectedDetail[kategori]!.contains(item),
                        onChanged: (v) {
                          setStateSheet(() {
                            if (v == true) {
                              selectedDetail[kategori]!.add(item);
                            } else {
                              selectedDetail[kategori]!.remove(item);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            );
          },
          child: boxField(selectedDetail[kategori]!.isEmpty
              ? "Pilih menu untuk $kategori"
              : "$kategori: ${selectedDetail[kategori]!.join(", ")}"),
        );
      }).toList(),
    );
  }

  Widget boxField(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF5A0E0E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A0E0E),
        title: const Text("Edit Menu", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white10,
                backgroundImage: kIsWeb
                    ? (webImage != null ? MemoryImage(webImage!) : null)
                    : (selectedImage != null ? FileImage(selectedImage!) : (fotoUrl != null ? NetworkImage(fotoUrl!) : null) as ImageProvider?),
                child: (webImage == null && selectedImage == null && fotoUrl == null)
                    ? const Icon(Icons.camera_alt, size: 32, color: Colors.white)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          buildMultiSelectJenis(),
          buildMultiSelectDetail(),
          DropdownButtonFormField(
            value: hariTersedia,
            decoration: inputStyle("Hari Tersedia"),
            dropdownColor: const Color(0xFF5A0E0E),
            style: const TextStyle(color: Colors.white),
            onChanged: (v) => setState(() => hariTersedia = v),
            items: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat']
                .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white))))
                .toList(),
          ),
          const SizedBox(height: 16),
          isLoadingLembaga
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<int>(
            value: selectedPenerimaId,
            decoration: inputStyle("Penerima Manfaat"),
            dropdownColor: const Color(0xFF5A0E0E),
            style: const TextStyle(color: Colors.white),
            items: lembagaList.map((item) {
              return DropdownMenuItem<int>(
                value: item['id'],
                child: Text(item['nama_lembaga'], style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedPenerimaId = value;
                updatePersenGizi();
              });
            },
          ),
          const SizedBox(height: 20),
          const Text("Persentase Gizi Total:", style: TextStyle(color: Colors.white)),
          Text(persenGizi, style: const TextStyle(fontSize: 22, color: Colors.yellow, fontWeight: FontWeight.bold)),
          Text(statusGizi, style: const TextStyle(fontSize: 18, color: Colors.white)),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.all(14)),
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
