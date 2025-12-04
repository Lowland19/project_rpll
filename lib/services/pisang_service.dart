import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PisangService {
  Interpreter? _interpreter;
  List<String>? _labels;

  static const int INPUT_SIZE = 224;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model_pisang.tflite');

      final rawLabels = await rootBundle.loadString('labels.txt');
      _labels = rawLabels.split('\n');

      print("Model & label berhasil dimuat");
    } catch (e) {
      print("Gagal memuat model: $e");
    }
  }

  Future<String> predict(File imageFile) async {
    if (_interpreter == null) return "Model belum siap";

    // 1. Decode image
    final bytes = await imageFile.readAsBytes();
    img.Image? ori = img.decodeImage(bytes);
    if (ori == null) return "Gambar tidak terbaca";

    // 2. Resize
    img.Image resized = img.copyResize(ori, width: INPUT_SIZE, height: INPUT_SIZE);

    // 3. Konversi menjadi input [1, 224, 224, 3]
    List<List<List<List<double>>>> input = [
      List.generate(INPUT_SIZE, (y) {
        return List.generate(INPUT_SIZE, (x) {
          final p = resized.getPixel(x, y);
          return [
            p.r / 255.0,
            p.g / 255.0,
            p.b / 255.0,
          ];
        });
      })
    ];

    // 4. Output [1, jumlah_label]
    List<List<double>> output = [
      List.filled(_labels!.length, 0.0)
    ];

    // 5. Run model
    _interpreter!.run(input, output);

    final scores = output[0];
    int bestIndex = 0;
    double bestScore = 0;

    for (int i = 0; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIndex = i;
      }
    }

    return "${_labels![bestIndex]} — ${(bestScore * 100).toStringAsFixed(1)}%";
  }

  void close() {
    _interpreter?.close();
  }
}
