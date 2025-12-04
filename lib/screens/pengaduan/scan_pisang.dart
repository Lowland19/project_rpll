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
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    _initializeControllerFuture = _controller!.initialize().then((_) async {
      // Matikan flash dulu
      await _controller!.setFlashMode(FlashMode.off);

      // Tunggu 200ms biar preview stabil (penting buat Xiaomi)
      await Future.delayed(const Duration(milliseconds: 200));

      // Jangan lock exposure dulu, cukup AUTO tanpa precapture
      try {
        await _controller!.setExposureMode(ExposureMode.auto);
        await _controller!.setFocusMode(FocusMode.auto);
      } catch (_) {}

      // MATIKAN AE/AF TRIGGER SEBELUM FOTO → anti precapture Xiaomi
      try {
        await _controller!.setExposurePoint(null);
        await _controller!.setFocusPoint(null);
      } catch (_) {}
    });

    if (mounted) setState(() {});
  }


  // ====================== LOAD MODEL ========================
  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/model/model_pisang.tflite');

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

    // Resize
    final resized = img.copyResize(image, width: 224, height: 224);

    // Siapkan input float32 [1,224,224,3]
    final input = List.generate(224, (y) {
      return List.generate(224, (x) {
        final pixel = resized.getPixel(x, y);

        final r = (pixel.r - 127.5) / 127.5;
        final g = (pixel.g - 127.5) / 127.5;
        final b = (pixel.b - 127.5) / 127.5;

        return [r, g, b];
      });
    });


    // Tambah batch dimension
    final inputTensor = [input];

    // Output 1x4
    var output = List.generate(1, (_) => List.filled(4, 0.0));
    interpreter!.run(inputTensor, output);
    final scores = output[0];


    int maxIndex = 0;
    double maxValue = scores[0];

    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > maxValue) {
        maxValue = scores[i];
        maxIndex = i;
      }
    }
    if (maxValue < 0.6) {
      return {
        "label": "bukan_pisang",
        "confidence": maxValue * 100,
      };
    }
    return {
      "label": labels[maxIndex],
      "confidence": maxValue * 100,
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
