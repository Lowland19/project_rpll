import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:project_rpll/services/scan_service.dart';
import 'hasil_scan.dart';

class ScanPisangScreen extends StatefulWidget {
  const ScanPisangScreen({super.key});

  @override
  State<ScanPisangScreen> createState() => _ScanPisangScreenState();
}

class _ScanPisangScreenState extends State<ScanPisangScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  Interpreter? interpreter;
  List<String> labels = [];

  @override
  void initState() {
    super.initState();
    initCamera();
    loadModel();
  }

  // ====================== CAMERA SETUP ======================
  Future<void> initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  // ====================== LOAD MODEL ========================
  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('model/model_pisang.tflite');

      final rawLabels =
      await rootBundle.loadString('assets/model/labels_pisang.txt');

      labels = rawLabels.split('\n').where((e) => e.trim().isNotEmpty).toList();

      print("MODEL LOADED");
      print("Labels loaded: $labels");
    } catch (e) {
      print("ERROR loading model: $e");
    }
  }

  // ====================== RUN MODEL =========================
  Future<Map<String, dynamic>> runModelOnImage(File imageFile) async {
    if (interpreter == null) {
      return {"label": "ERROR", "confidence": 0.0};
    }

    final raw = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(raw);

    if (image == null) {
      return {"label": "Invalid Image", "confidence": 0.0};
    }

    // Resize sesuai model (224x224)
    img.Image resized = img.copyResize(image, width: 224, height: 224);

    // Input float32 1 x 224 x 224 x 3
    final input = List.generate(224, (y) {
      return List.generate(224, (x) {
        final p = resized.getPixel(x, y);
        return [
          p.r / 255.0,
          p.g / 255.0,
          p.b / 255.0,
        ];
      });
    });

    // Output: 1 × 4
    var output = List<double>.filled(4, 0.0);

    interpreter!.run([input], [output]);

    // Cari nilai terbesar (softmax)
    int maxIndex = 0;
    double maxValue = output[0];

    for (int i = 1; i < output.length; i++) {
      if (output[i] > maxValue) {
        maxValue = output[i];
        maxIndex = i;
      }
    }

    return {
      "label": labels[maxIndex],      // label diambil dari file txt
      "confidence": maxValue * 100,   // %, model softmax output 0–1
    };
  }

  // ====================== DISPOSE ===========================
  @override
  void dispose() {
    _controller?.dispose();
    interpreter?.close();
    super.dispose();
  }

  // ====================== UI ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Pisang")),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller!);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller!.takePicture();
            final file = File(image.path);

            // 1️⃣ RUN MODEL
            final hasil = await runModelOnImage(file);

            // 2️⃣ UPLOAD FOTO
            final imageUrl = await scanService.uploadImage(file);

            // 3️⃣ SIMPAN DATABASE
            await scanService.saveScanResult(
              imageUrl: imageUrl,
              hasil: hasil["label"],
              confidence: hasil["confidence"] is double
                  ? hasil["confidence"]
                  : double.tryParse(hasil["confidence"].toString()) ?? 0.0,
            );
            // 4️⃣ TAMPILKAN HASIL
            if (!mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HasilScanScreen(
                  imagePath: image.path,
                  hasilModel: hasil["label"],
                  confidence: hasil["confidence"],
                ),
              ),
            );
          } catch (e) {
            print("Error: $e");
          }
        },
      ),
    );
  }
}
