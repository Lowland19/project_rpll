class ScanModel {
  int? id;
  String imagePath;
  String hasil;
  String createdAt;

  ScanModel({
    this.id,
    required this.imagePath,
    required this.hasil,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'hasil': hasil,
      'createdAt': createdAt,
    };
  }

  factory ScanModel.fromMap(Map<String, dynamic> map) {
    return ScanModel(
      id: map['id'],
      imagePath: map['imagePath'],
      hasil: map['hasil'],
      createdAt: map['createdAt'],
    );
  }
}
