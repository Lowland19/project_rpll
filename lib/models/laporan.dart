class Laporan {
  final int id;
  final DateTime tanggalPelaporan;
  final String gambarUrl;
  final String deskripsi;
  final String penerimaManfaat;

  // ID Foreign Key (Penting untuk Logic)
  final int idLembagaPengirim;

  // Data Display (Dari Relasi)
  final String namaLembaga;

  Laporan({
    required this.id,
    required this.tanggalPelaporan,
    required this.gambarUrl,
    required this.deskripsi,
    required this.penerimaManfaat,
    required this.idLembagaPengirim, // Tambahkan ini
    required this.namaLembaga,
  });

  factory Laporan.fromMap(Map<String, dynamic> map) {
    final lembagaData = map['lembaga'];

    return Laporan(
      id: map['id'] ?? 0,

      tanggalPelaporan: map['tanggal_pelaporan'] != null
          ? DateTime.parse(map['tanggal_pelaporan'])
          : DateTime.now(),

      gambarUrl: map['gambar'] ?? '',
      deskripsi: map['deskripsi'] ?? '-',
      penerimaManfaat: map['penerima_manfaat'] ?? '-',

      // --- AMBIL ID ASLI DARI KOLOM TABEL LAPORAN ---
      // Sesuaikan nama kolom dengan yang ada di screenshot database Anda
      idLembagaPengirim: map['id_lembaga_pengirim'] ?? 0,

      // Ambil Nama dari Tabel Sebelah
      namaLembaga: (lembagaData != null)
          ? (lembagaData['nama_lembaga'] ?? 'Tanpa Nama')
          : 'Lembaga Tidak Ditemukan',
    );
  }
}
