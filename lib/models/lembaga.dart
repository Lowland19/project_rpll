class Lembaga {
  final int id;
  final String idPenggunaTerkait;
  final String namaLembaga;
  final String jenisLembaga;
  final String alamat;
  final double latitude;
  final double longitude;
  final int jumlahPenerima;

  Lembaga({
    required this.id,
    required this.idPenggunaTerkait,
    required this.namaLembaga,
    required this.jenisLembaga,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    required this.jumlahPenerima,
  });

  factory Lembaga.fromMap(Map<String, dynamic> map) {
    return Lembaga(
      id: map['id'] ?? 0,
      namaLembaga: map['nama_lembaga'] ?? 'Tanpa Nama',
      jenisLembaga: map['jenis_lembaga'] ?? '-',
      alamat: map['alamat'] ?? '-',

      // Konversi aman ke double (bisa jadi int atau double di DB)
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),

      jumlahPenerima: map['jumlah_penerima'] ?? 0,
      idPenggunaTerkait: map['id_pengguna_terkait'],
    );
  }
}
