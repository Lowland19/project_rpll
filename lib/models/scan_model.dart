class ScanModel {
  int? id;
  String imagePath;
  String hasil;
  double confidence;
  String createdAt;

  ScanModel({
    this.id,
    required this.imagePath,
    required this.hasil,
    required this.confidence,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'hasil': hasil,
      'confidence': confidence,
      'createdAt': createdAt,
    };
  }

  factory ScanModel.fromMap(Map<String, dynamic> map) {
    return ScanModel(
      id: map['id'],
      imagePath: map['imagePath'],
      hasil: map['hasil'],
      confidence: (map['confidence'] is double)
          ? map['confidence']
          : double.tryParse(map['confidence'].toString()) ?? 0.0,
      createdAt: map['createdAt'],
    );
  }
}
