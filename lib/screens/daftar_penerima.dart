import 'package:flutter/material.dart';

class DaftarPenerimaScreen extends StatelessWidget {
  const DaftarPenerimaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),
      body: SafeArea(
        child: Stack(
          children: [
            // BULATAN DEKORASI
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
                        child: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
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
                    child: ListView(
                      children: [
                        penerimaTile(
                            nama: "SMA 3", img: "assets/img/sma3.png"),
                        penerimaTile(
                            nama: "SMP 12", img: "assets/img/smp12.png"),
                        penerimaTile(
                            nama: "TK", img: "assets/img/sma3.png"),
                        penerimaTile(
                            nama: "SD", img: "assets/img/smp12.png"),
                        penerimaTile(
                            nama: "PAUD", img: "assets/img/sma3.png"),
                      ],
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

  Widget penerimaTile({required String nama, required String img}) {
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
            child: Text(
              nama,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              img,
              width: 55,
              height: 55,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
