import 'package:flutter/material.dart';
import 'rute_perkiraan_waktu.dart';

class JadwalPengirimanScreen extends StatefulWidget {
  const JadwalPengirimanScreen({super.key});

  @override
  State<JadwalPengirimanScreen> createState() => _JadwalPengirimanScreenState();
}

class _JadwalPengirimanScreenState extends State<JadwalPengirimanScreen> {
  String selectedFilter = "Semua Sekolah";

  final List<Map<String, String>> jadwalList = [
    {"jam": "09.30", "sekolah": "SMA 3"},
    {"jam": "09.50", "sekolah": "SMP 12"},
    {"jam": "10.30", "sekolah": "TK"},
    {"jam": "10.55", "sekolah": "SD"},
    {"jam": "11.30", "sekolah": "PAUD"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.white70),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Cari...",
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Dropdown filter
              Align(
                alignment: Alignment.centerLeft,
                child: DropdownButton<String>(
                  dropdownColor: Colors.white,
                  value: selectedFilter,
                  items: ["Semua Sekolah", "SMA 3", "SMP 12", "TK", "SD", "PAUD"]
                      .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  )).toList(),
                  onChanged: (value) {
                    setState(() => selectedFilter = value!);
                  },
                ),
              ),

              const SizedBox(height: 15),

              // List jadwal
              Expanded(
                child: ListView.builder(
                  itemCount: jadwalList.length,
                  itemBuilder: (context, index) {
                    return _jadwalItem(
                      jam: jadwalList[index]["jam"]!,
                      sekolah: jadwalList[index]["sekolah"]!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _jadwalItem({required String jam, required String sekolah}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RutePerkiraanWaktuScreen(
              jam: jam,
              sekolah: sekolah,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // jam kiri
            Container(
              width: 70,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF5A0E0E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                jam,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            const SizedBox(width: 20),

            // nama sekolah
            Expanded(
              child: Text(
                sekolah,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
