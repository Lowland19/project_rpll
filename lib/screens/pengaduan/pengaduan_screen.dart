import 'package:flutter/material.dart';
import 'package:project_rpll/screens/pengaduan/kamera_pengaduan_screen.dart';

class PengaduanScreen extends StatefulWidget {
  const PengaduanScreen({super.key, this.imagePath});
  final String? imagePath;

  @override
  State<PengaduanScreen> createState() => _PengaduanScreenState();
}

class _PengaduanScreenState extends State<PengaduanScreen> {
  final formController = GlobalKey<FormState>();
  late TextEditingController pengaduanController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menu Pengaduan (Siswa)',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF5A0E0E),
      ),
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(color: Color(0xFF3B0E0E))),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextFormField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi masalah',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: widget.imagePath != null ? null : () {
                      setState(() {
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>KameraPengaduanScreen()));
                      });
                      debugPrint('Berhasil disimpan');
                    },
                    label: Text(widget.imagePath != null ? "Sudah terisi" : 'Kirim bukti gambar'),
                    icon: Icon(Icons.camera),
                  ),
                  
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    label: const Text('Kirim pengaduan'),
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
