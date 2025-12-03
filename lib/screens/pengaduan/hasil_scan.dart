import 'dart:io';
import 'package:flutter/material.dart';

class HasilScanScreen extends StatelessWidget {
  final String imagePath;
  final String hasilModel;

  const HasilScanScreen({
    super.key,
    required this.imagePath,
    required this.hasilModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hasil Scan Pisang")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // FOTO
            SizedBox(
              height: 300,
              child: Image.file(File(imagePath)),
            ),

            const SizedBox(height: 20),

            // HASIL MODEL
            Text(
              hasilModel,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Kembali"),
            ),
          ],
        ),
      ),
    );
  }
}
