import 'package:flutter/material.dart';

class DaftarPenerimaScreen extends StatelessWidget {
  const DaftarPenerimaScreen({super.key});

  // DATA PENERIMA
  final List<Map<String, dynamic>> penerimaList = const [
    {"nama": "SMAN 3 Cimahi", "jumlah": 1250, "jarak": "3.2 km"},
    {"nama": "SDN Pasirkaliki Mandiri 2", "jumlah": 656, "jarak": "950 m"},
    {"nama": "SMPN 12", "jumlah": 595, "jarak": "900 m"},
    {"nama": "SDN Pasirkaliki Mandiri 1", "jumlah": 397, "jarak": "350 m"},
    {"nama": "SLB B Prima Bhakti", "jumlah": 89, "jarak": "1.2 km"},
    {"nama": "RA Nurul Huda", "jumlah": 55, "jarak": "3 km"},
    {"nama": "TK Pamekar Budi", "jumlah": 52, "jarak": "1.2 km"},
    {"nama": "PAUD Melati 10", "jumlah": 47, "jarak": "8.8 km"},
    {"nama": "PAUD Darul Falah", "jumlah": 46, "jarak": "800 m"},
    {"nama": "Kober Qurrotu'ain Al Istiqomah", "jumlah": 45, "jarak": "5 km"},
    {"nama": "PAUD Mawar Putih", "jumlah": 30, "jarak": "1.6 km"},
    {"nama": "PAUD Kenanga 12", "jumlah": 27, "jarak": "7.7 km"},
    {"nama": "RA Darul Hufadz", "jumlah": 27, "jarak": "1 km"},
    {"nama": "RA Darul Ikhlas", "jumlah": 25, "jarak": "1.3 km"},
    {"nama": "TK Daarul Hidayah Al-Qurani", "jumlah": 21, "jarak": "1.1 km"},
    {"nama": "TK Harapan Mulya", "jumlah": 20, "jarak": "500 m"},
    {"nama": "Kober Nurul Huda Al Khudlory", "jumlah": 20, "jarak": "400 m"},
  ];

  // KONVERSI JARAK (meter/km → angka)
  double konversiJarak(String jarakStr) {
    if (jarakStr.contains("km")) {
      return double.tryParse(jarakStr.replaceAll(" km", "")) ?? 9999;
    } else if (jarakStr.contains("m")) {
      return (double.tryParse(jarakStr.replaceAll(" m", "")) ?? 9999) / 1000;
    }
    return 9999;
  }

  @override
  Widget build(BuildContext context) {
    // SORT JUMLAH & JARAK
    List<Map<String, dynamic>> sortedList = [...penerimaList];

    sortedList.sort((a, b) {
      // 1. Urutkan jumlah tertinggi
      if (b["jumlah"] != a["jumlah"]) {
        return b["jumlah"].compareTo(a["jumlah"]);
      }

      // 2. Jika jumlah sama → jarak terdekat
      double ja = konversiJarak(a["jarak"]);
      double jb = konversiJarak(b["jarak"]);
      return ja.compareTo(jb);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),
      body: SafeArea(
        child: Stack(
          children: [
            // BULATAN HIASAN
            Positioned(
              bottom: -40,
              left: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(40, 255, 0, 0),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Daftar Penerima",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedList.length,
                      itemBuilder: (context, index) {
                        return penerimaTile(
                          nama: sortedList[index]["nama"],
                          jumlah: sortedList[index]["jumlah"],
                          jarak: sortedList[index]["jarak"],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget penerimaTile({
    required String nama,
    required int jumlah,
    required String jarak,
    // required String img,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF5A0E0E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Jumlah: $jumlah",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  "Jarak: $jarak",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // ClipRRect(
          //   borderRadius: BorderRadius.circular(8),
          //   child: Image.asset(img, width: 55, height: 55, fit: BoxFit.cover),
          // ),
        ],
      ),
    );
  }
}
