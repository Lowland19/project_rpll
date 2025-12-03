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

  // ========================= CAMERA ======================================
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

  // ========================= LOAD MODEL ===================================
  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('model/model_pisang.tflite');

      final rawLabels =
      await rootBundle.loadString('assets/model/labels_pisang.txt');

      labels = rawLabels.split('\n').where((e) => e.trim().isNotEmpty).toList();

      print("MODEL LOADED");
      print("Labels loaded: $labels");
      print("Jumlah labels: ${labels.length}");
    } catch (e) {
      print("ERROR loadModel: $e");
    }
  }

  // ========================= RUN MODEL ====================================
  Future<String> runModelOnImage(File imageFile) async {
    if (interpreter == null) return "Model belum siap";
    if (labels.isEmpty) return "Labels kosong - gagal load file label";

    final raw = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(raw);

    if (image == null) return "Gambar tidak dapat dibaca";

    img.Image resized = img.copyResize(image, width: 224, height: 224);

    var input = List.generate(224, (y) {
      return List.generate(224, (x) {
        final pixel = resized.getPixel(x, y);
        return [
          pixel.r / 255.0,
          pixel.g / 255.0,
          pixel.b / 255.0,
        ];
      });
    }).reshape([1, 224, 224, 3]);

    // Gunakan shape output model
    var outputShape = interpreter!.getOutputTensor(0).shape;
    var output = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
        .reshape(outputShape);

    interpreter!.run(input, output);
    final result = output[0];

    int maxIndex = 0;
    double maxValue = -999;

    for (int i = 0; i < result.length; i++) {
      if (result[i] > maxValue) {
        maxValue = result[i];
        maxIndex = i;
      }
    }

    return "${labels[maxIndex]} (confidence: ${maxValue.toStringAsFixed(2)})";
  }

  // ========================= DISPOSE ======================================
  @override
  void dispose() {
    _controller?.dispose();
    interpreter?.close();
    super.dispose();
  }

  // ========================= UI ===========================================
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

            // ============ 1. JALANKAN MODEL ============
            final hasil = await runModelOnImage(file);

            // ============ 2. UPLOAD FOTO KE SUPABASE ============
            final imageUrl = await scanService.uploadImage(file);

            // ============ 3. SIMPAN KE DATABASE ============
            await scanService.saveScanResult(
              imageUrl: imageUrl,
              hasil: hasil,
            );

            // ============ 4. TAMPILKAN HALAMAN HASIL ============
            if (!mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HasilScanScreen(
                  imagePath: image.path,
                  hasilModel: hasil,
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
