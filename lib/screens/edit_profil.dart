import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_rpll/screens/map_picker_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController lembagaController = TextEditingController();
  final TextEditingController jumlahPenerimaController =
      TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  File? _imageFile;
  String? _oldAvatarUrl;
  String _currentUserRole = '';
  double? _latitude;
  double? _longitude;
  String? lembaga;
  int? jumlahPenerima;
  final List<String> roleWithLocation = ['penanggungjawab_mbg', 'petugas_sppg'];
  final List<String> roleWithLembaga = ['penanggungjawab_mbg', 'petugas_sppg'];
  final List<String> roleWithJumlahPenerima = [
    'penanggungjawab_mbg',
    'petugas_sppg',
  ];

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    alamatController.dispose();
    super.dispose();
  }

  Future<void> _getProfileData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final data = await supabase
            .from('profiles')
            .select(
              'username, alamat, avatar_url,longitude,latitude, user_roles(roles(nama_role))',
            )
            .eq('id', user.id)
            .single();
        if (mounted) {
          setState(() {
            nameController.text = data['username'];
            emailController.text = user.email ?? '_';
            alamatController.text = data['alamat'];
            _oldAvatarUrl = data['avatar_url'];
            _latitude = data['latitude'];
            _longitude = data['longitude'];
            final List roleData = data['user_roles'] ?? [];
            if (roleData.isNotEmpty && roleData[0]['roles'] != null) {
              _currentUserRole = roleData[0]['roles']['nama_role']
                  .toString()
                  .toLowerCase();
            } else {
              _currentUserRole = 'pendatang';
            }
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _openMapPicker() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MapPickerScreen(initialLat: _latitude, initialLong: _longitude),
      ),
    );
    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path); // Simpan ke variabel state untuk preview
      });
    }
  }

  Future<String?> _uploadAvatar(String userId) async {
    if (_imageFile == null) return null;

    try {
      final supabase = Supabase.instance.client;
      final fileName =
          'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage
          .from('profile_picture')
          .upload(fileName, _imageFile!);
      final imageUrl = supabase.storage
          .from('profile_picture')
          .getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print("Gagal upload avatar: $e");
      throw "Gagal upload foto profil";
    }
  }

  ImageProvider _getAvatarImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (_oldAvatarUrl != null && _oldAvatarUrl!.isNotEmpty) {
      return NetworkImage(_oldAvatarUrl!);
    } else {
      return const NetworkImage(
        'https://thumbs.dreamstime.com/b/creative-illustration-default-avatar-profile-placeholder-isolated-background-art-design-grey-photo-blank-template-mockup-144855718.jpg',
      );
    }
  }

  Future<void> _updateUserProfile() async {
    setState(() {
      _isSaving = true;
    });
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final name = nameController.text;
        final password = passwordController.text;
        final alamat = roleWithLocation.contains(_currentUserRole)
            ? alamatController.text.trim()
            : null;
        final lembaga = lembagaController.text;
        final textInputJumlahPenerima = jumlahPenerimaController.text;
        final jumlahPenerima = int.tryParse(textInputJumlahPenerima);

        UserAttributes attributes = UserAttributes();
        bool needUpdateAuth = false;

        if (password.isNotEmpty || password.length > 6) {
          attributes.password = password;
          needUpdateAuth = true;
        }

        if (name.isEmpty || name.length < 3) {
          throw "Nama asli terlalu pendek";
        }

        if (needUpdateAuth) {
          await supabase.auth.updateUser(attributes);
        }

        String? newAvatarUrl;
        if (_imageFile != null) {
          newAvatarUrl = await _uploadAvatar(user.id);
        }

        await supabase
            .from('profiles')
            .update({
              'username': name,
              'alamat': alamat,
              'avatar_url': newAvatarUrl,
              'longitude': _longitude,
              'latitude': _latitude,
              'lembaga': lembaga,
              'jumlah_penerima': jumlahPenerima,
            })
            .eq('id', user.id);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Berhasil menyimpan data')));
          setState(() {
            _isLoading = false;
          });

          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showLocationField = roleWithLocation.contains(_currentUserRole);
    bool showLembagaField = roleWithLembaga.contains(_currentUserRole);
    bool showPenerimaField = roleWithJumlahPenerima.contains(_currentUserRole);
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Background lingkaran dekorasi
                Positioned(
                  bottom: -70,
                  left: -40,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF5A0E0E),
                    ),
                  ),
                ),

                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 50,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back & Save Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "< Back",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Avatar
                      GestureDetector(
                        onTap: _pickImage, // Klik foto untuk ganti
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey,
                              backgroundImage:
                                  _getAvatarImage(), // Logika Gambar Pintar
                            ),
                            // Ikon Kamera Kecil
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Text(
                        "Ketuk foto untuk mengubah",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 30),

                      const SizedBox(height: 10),

                      const Text(
                        "Ubah Foto",
                        style: TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 30),

                      // FORM FIELD
                      _buildField("Nama Lengkap", nameController),
                      const SizedBox(height: 16),
                      _buildField(
                        "Password",
                        passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      _buildField("Email", emailController),
                      const SizedBox(height: 16),
                      if (showLocationField) ...[
                        _buildField("Alamat / Lokasi", alamatController),
                        const SizedBox(height: 16),
                      ],
                      if (showLembagaField) ...[
                        _buildField("Nama Lembaga", lembagaController),
                        const SizedBox(height: 16),
                      ],
                      if (showPenerimaField) ...[
                        _buildField(
                          "Jumlah Penerima",
                          jumlahPenerimaController,
                        ),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 30),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Titik Koordinat'),
                          SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white54),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    (_latitude != null && _longitude != null)
                                        ? "${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}"
                                        : "Belum set lokasi",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _openMapPicker, // Buka Peta
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                  ),
                                  child: const Text("Pilih Peta"),
                                ),
                              ],
                            ),
                          ),

                          // SAVE BUTTON
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _isSaving ? null : _updateUserProfile();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53935),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isSaving
                                  ? null
                                  : const Text(
                                      "SAVE CHANGES",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // CUSTOM FORM FIELD
  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white54),
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
