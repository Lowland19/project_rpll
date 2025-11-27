import 'package:flutter/material.dart';

class RutePerkiraanWaktuScreen extends StatelessWidget {
  final String sekolah;
  final String jam;

  const RutePerkiraanWaktuScreen({
    super.key,
    required this.sekolah,
    required this.jam,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              width: 230,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.map, size: 60, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    "Status : Dalam Pengiriman",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 6),
                  Text("Alamat : $sekolah"),
                  const SizedBox(height: 4),
                  Text("Estimasi Tiba : 12 menit"),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.grey),
                          SizedBox(height: 5),
                          Text("Menu Ditetapkan"),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(height: 5),
                          Text("Dikirim"),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.radio_button_unchecked, color: Colors.grey),
                          SizedBox(height: 5),
                          Text("Sampai"),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Riwayat Perjalanan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text("$jam MBG sedang dikirim"),
                  Text("09.35 Dalam pengiriman"),
                  Text("09.42 MBG telah sampai"),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("Hubungi Sopir"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
