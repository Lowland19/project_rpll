class Profiles {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? alamat;
  final String? lembaga;
  final double? latitude;
  final double? longitude;
  final int? jumlahPenerima;
  final List<String> roles;

  Profiles({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.alamat,
    this.lembaga,
    this.latitude,
    this.longitude,
    this.jumlahPenerima,
    required this.roles,
  });

  factory Profiles.fromMap(Map<String, dynamic> map, String emailAuth) {
    List<String> parsedRoles = [];
    if (map['user_roles'] != null) {
      for (var item in map['user_roles']) {
        if (item['roles'] != null) {
          parsedRoles.add(
            item['roles']['nama_role'].toString().toLowerCase().trim(),
          );
        }
      }
    }
    if (parsedRoles.isEmpty) parsedRoles.add('pendatang');
    return Profiles(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: emailAuth,
      avatarUrl: map['avatar_url'] ?? '',
      alamat: map['alamat'] ?? '',
      lembaga: map['lembaga'] ?? '',
      jumlahPenerima: map['jumlah_penerima'] ?? 0,
      latitude: map['latitude'],
      longitude: map['longitude'],
      roles: parsedRoles,
    );
  }
}
