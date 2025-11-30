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
      // Load Model
      _interpreter = await Interpreter.fromAsset('assets/model_pisang.tflite');

      // Load Label
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData.split('\n');

      print('Model & Label berhasil dimuat');
    } catch (e) {
      print('Gagal memuat model: $e');
    }
  }

  Future<String> predict(File imageFile) async {
    if (_interpreter == null) return "Model belum siap";

    // 1. Baca gambar & Resize
    var imageBytes = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) return "Gagal membaca gambar";

    img.Image resizedImage = img.copyResize(
      originalImage,
      width: INPUT_SIZE,
      height: INPUT_SIZE,
    );

    // 2. Konversi Gambar ke Format yang dimengerti AI (Float32 List)
    // Model butuh input: [1, 224, 224, 3]
    // Dan normalisasi nilai pixel jadi 0.0 - 1.0 (karena di Colab pakai rescale=1./255)

    var input = List.generate(
      1,
      (i) => List.generate(
        INPUT_SIZE,
        (y) => List.generate(INPUT_SIZE, (x) {
          var pixel = resizedImage.getPixel(x, y);
          // Ambil RGB, bagi 255.0 untuk normalisasi
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    );

    // 3. Siapkan Output buffer
    // Output shape: [1, 4] (karena ada 4 kelas)
    var output = List.filled(1 * 4, 0.0).reshape([1, 4]);

    // 4. Jalankan Prediksi
    _interpreter!.run(input, output);

    // 5. Cari hasil dengan probabilitas tertinggi
    List<double> result = output[0];
    double maxScore = 0.0;
    int maxIndex = 0;

    for (int i = 0; i < result.length; i++) {
      if (result[i] > maxScore) {
        maxScore = result[i];
        maxIndex = i;
      }
    }

    return "${_labels![maxIndex]} (${(maxScore * 100).toStringAsFixed(1)}%)";
  }

  void close() {
    _interpreter?.close();
  }
}
