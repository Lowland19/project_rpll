class Pengembalian {
  final int id;
  final int idLembaga;
  final DateTime createdAt;
  final String namaLembaga;
  final String alamatLembaga;
  final int jumlahPenerima;

  Pengembalian({
    required this.id,
    required this.idLembaga,
    required this.createdAt,
    required this.namaLembaga,
    required this.alamatLembaga,
    required this.jumlahPenerima,
  });

  factory Pengembalian.fromMap(Map<String, dynamic> map) {
    final lembagaData = map['lembaga'];

    print("🔍 CEK DATA: ID=${map['id_pengembalian']}");
    print("🔍 CEK DATA: ID Lembaga=${map['id_lembaga']}");

    if (lembagaData != null) {
      print("🔍 CEK DATA: Jumlah=${lembagaData['jumlah_penerima']}");
      print("🔍 CEK DATA: Nama=${lembagaData['nama_lembaga']}");
    } else {
      print("🚨 CEK DATA: Data Lembaga KOSONG/NULL!");
    }

    return Pengembalian(
      id: map['id_pengembalian'],
      idLembaga: map['id_lembaga'] ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      namaLembaga: lembagaData != null
          ? lembagaData['nama_lembaga'] ?? 'Tanpa Nama'
          : '-',
      alamatLembaga: lembagaData != null ? lembagaData['alamat'] ?? '-' : '-',
      jumlahPenerima: lembagaData != null
          ? (lembagaData['jumlah_penerima'] ?? 0)
          : 0,
    );
  }
}
