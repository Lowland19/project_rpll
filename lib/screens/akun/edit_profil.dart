import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_rpll/services/profiles_service.dart';
import 'package:project_rpll/screens/akun/map_picker_screen.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // Controller Text UI
  final nameCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final alamatCtrl = TextEditingController();
  final lembagaCtrl = TextEditingController();
  final jumlahCtrl = TextEditingController();

  bool isLoadingData = true; // Indikator loading awal

  @override
  void initState() {
    super.initState();
    // Panggil fungsi load data khusus saat halaman dibuka
    _loadInitialData();
  }

  // --- FUNGSI LOAD DATA (GABUNGAN PROFILES & LEMBAGA) ---
  Future<void> _loadInitialData() async {
    final service = context.read<ProfileService>();
    final user = service.userProfile;

    // 1. Isi data dasar dari tabel Profiles (Username, Email)
    if (user != null) {
      nameCtrl.text = user.username;
      emailCtrl.text = user.email;
    }

    // 2. Isi data detail dari tabel Lembaga (Alamat, Nama Lembaga, Koordinat)
    // Fungsi ini harus sudah ada di ProfileService (seperti diskusi sebelumnya)
    final lembagaData = await service.fetchLembagaData();

    if (mounted) {
      if (lembagaData != null) {
        // Jika data lembaga ditemukan, isi controller dengan data tersebut
        setState(() {
          alamatCtrl.text = lembagaData['alamat'] ?? '';
          lembagaCtrl.text = lembagaData['nama_lembaga'] ?? '';
          jumlahCtrl.text = (lembagaData['jumlah_penerima'] ?? 0).toString();

          // Update Koordinat di Service agar peta muncul titiknya
          if (lembagaData['latitude'] != null &&
              lembagaData['longitude'] != null) {
            service.updateTempCoordinates(
              (lembagaData['latitude'] as num).toDouble(),
              (lembagaData['longitude'] as num).toDouble(),
            );
          }
          isLoadingData = false;
        });
      } else {
        // Jika belum ada data lembaga (misal akun baru), matikan loading saja
        setState(() => isLoadingData = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileService>(
      builder: (context, service, child) {
        // Logika Show/Hide berdasarkan role
        bool showLocation = service.hasRole([
          'penanggungjawab_mbg',
          'petugas_sppg',
        ]);
        bool showLembaga = service.hasRole([
          'penanggungjawab_mbg',
          'petugas_sppg',
        ]);
        bool showPenerima = service.hasRole(['penanggungjawab_mbg']);

        return Scaffold(
          backgroundColor: const Color(0xFF3B0E0E),
          body: Stack(
            children: [
              // Background Lingkaran
              Positioned(
                top: -50,
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

              // Jika sedang loading data awal, tampilkan spinner
              isLoadingData
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 50,
                      ),
                      child: Column(
                        children: [
                          // Header Back
                          Row(
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

                          // AVATAR
                          GestureDetector(
                            onTap: service.pickImage,
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey,
                              backgroundImage: service.tempImageFile != null
                                  ? FileImage(service.tempImageFile!)
                                  : (service
                                            .userProfile
                                            ?.avatarUrl
                                            ?.isNotEmpty ==
                                        true)
                                  ? NetworkImage(
                                      service.userProfile!.avatarUrl!,
                                    )
                                  : const NetworkImage(
                                          'https://thumbs.dreamstime.com/b/creative-illustration-default-avatar-profile-placeholder-isolated-background-art-design-grey-photo-blank-template-mockup-144855718.jpg',
                                        )
                                        as ImageProvider,
                              child: const Align(
                                alignment: Alignment.bottomRight,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // FIELDS UTAMA (Tabel Profiles)
                          _buildField("Username", nameCtrl),
                          const SizedBox(height: 16),
                          _buildField("Password", passCtrl, isPassword: true),
                          const SizedBox(height: 16),
                          _buildField("Email", emailCtrl),
                          const SizedBox(height: 16),

                          // FIELDS LEMBAGA (Tabel Lembaga)
                          if (showLocation) ...[
                            _buildField("Alamat", alamatCtrl),
                            const SizedBox(height: 16),
                          ],
                          if (showLembaga) ...[
                            _buildField("Nama Lembaga", lembagaCtrl),
                            const SizedBox(height: 16),
                          ],
                          if (showPenerima) ...[
                            _buildField("Jumlah Penerima", jumlahCtrl),
                            const SizedBox(height: 16),
                          ],

                          const SizedBox(height: 20),

                          // PETA KOORDINAT
                          if (showLocation)
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    (service.tempLat != null)
                                        ? "${service.tempLat}, ${service.tempLong}"
                                        : "Belum set lokasi",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final LatLng? result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MapPickerScreen(
                                          initialLat: service.tempLat,
                                          initialLong: service.tempLong,
                                        ),
                                      ),
                                    );
                                    if (result != null) {
                                      service.updateTempCoordinates(
                                        result.latitude,
                                        result.longitude,
                                      );
                                    }
                                  },
                                  child: const Text("Pilih Peta"),
                                ),
                              ],
                            ),

                          const SizedBox(height: 30),

                          // --- TOMBOL SAVE (LOGIKA DIPERBARUI) ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!service.isSaving) {
                                  // TAHAP 1: Simpan Data Profil Umum (Username, Foto)
                                  // (Kirim null untuk field lembaga karena akan disimpan terpisah)
                                  String? error = await service.saveProfile(
                                    name: nameCtrl.text,
                                    password: passCtrl.text,
                                    email: emailCtrl.text,
                                    alamat: '', // Jangan simpan ke profile
                                    lembaga: '', // Jangan simpan ke profile
                                    jumlahPenerimaStr:
                                        '', // Jangan simpan ke profile
                                  );

                                  // TAHAP 2: Simpan Data Lembaga Secara Terpisah
                                  // Hanya jika tidak ada error di tahap 1 DAN role-nya sesuai
                                  if (error == null &&
                                      (showLembaga || showLocation)) {
                                    try {
                                      // Panggil fungsi updateLembagaData di Service
                                      await service.updateLembagaData(
                                        namaLembaga: lembagaCtrl.text,
                                        alamat: alamatCtrl.text,
                                        jumlahPenerima:
                                            int.tryParse(jumlahCtrl.text) ?? 0,
                                        lat: service.tempLat,
                                        long: service.tempLong,
                                      );
                                    } catch (e) {
                                      error = "Gagal simpan data lembaga: $e";
                                    }
                                  }

                                  // Feedback ke User
                                  if (context.mounted) {
                                    if (error == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Berhasil disimpan!'),
                                        ),
                                      );
                                      Navigator.pop(
                                        context,
                                      ); // Kembali ke halaman Akun
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(error),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53935),
                              ),
                              child: service.isSaving
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "SAVE CHANGES",
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  // Widget Helper Field (Tidak Berubah)
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
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
