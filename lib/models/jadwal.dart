class Jadwal {
  final int idLembaga;
  final String namaLembaga;
  final String namaMenu;
  final String jenisMakanan;
  final int jumlahPenerima;
  final double jarakMeter;
  final String jarakText; // Contoh: "2.5 km"
  final double skorPrioritas;
  final int urutan; // Urutan pengiriman (1, 2, 3...)

  Jadwal({
    required this.idLembaga,
    required this.namaLembaga,
    required this.namaMenu,
    required this.jenisMakanan,
    required this.jumlahPenerima,
    required this.jarakMeter,
    required this.jarakText,
    required this.skorPrioritas,
    required this.urutan,
  });
}
