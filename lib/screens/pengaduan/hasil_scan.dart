import 'dart:io';
import 'package:flutter/material.dart';

class HasilScanScreen extends StatelessWidget {
  final String imagePath;
  final String hasilModel;
  final double confidence;

  const HasilScanScreen({
    super.key,
    required this.imagePath,
    required this.hasilModel,
    required this.confidence,
  });

  Color _confidenceColor(double value) {
    if (value >= 80) return Colors.green;
    if (value >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hasil Scan Pisang")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // FOTO
            SizedBox(
              height: 300,
              child: Image.network((imagePath), fit: BoxFit.cover),
            ),

            const SizedBox(height: 24),

            // CARD HASIL SCAN
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    hasilModel,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Akurasi: ${confidence.toStringAsFixed(2)}%",
                    style: TextStyle(
                      fontSize: 20,
                      color: _confidenceColor(confidence),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
              ),
              child: const Text("Kembali", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
