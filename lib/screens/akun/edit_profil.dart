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

  @override
  void initState() {
    super.initState();
    // Isi form dengan data yang sudah ada di Service
    final service = context.read<ProfileService>();
    final user = service.userProfile;

    if (user != null) {
      nameCtrl.text = user.username;
      emailCtrl.text = user.email;
      alamatCtrl.text = user.alamat!;
      lembagaCtrl.text = user.lembaga!;
      jumlahCtrl.text = user.jumlahPenerima.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer untuk akses ProfileService
    return Consumer<ProfileService>(
      builder: (context, service, child) {
        // Logika Show/Hide berdasarkan role (Pakai helper di service)
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

              SingleChildScrollView(
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
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // AVATAR (Logic Pintar dari Service)
                    GestureDetector(
                      onTap: service.pickImage,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey,
                        // Cek: Ada foto temp? ATAU Ada foto lama? ATAU Default
                        backgroundImage: service.tempImageFile != null
                            ? FileImage(service.tempImageFile!)
                            : (service.userProfile?.avatarUrl?.isNotEmpty ==
                                  true)
                            ? NetworkImage(service.userProfile!.avatarUrl!)
                            : const NetworkImage(
                                    'https://thumbs.dreamstime.com/b/creative-illustration-default-avatar-profile-placeholder-isolated-background-art-design-grey-photo-blank-template-mockup-144855718.jpg',
                                  )
                                  as ImageProvider,
                        child: const Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.camera_alt, color: Colors.orange),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // FIELDS
                    _buildField("Username", nameCtrl),
                    const SizedBox(height: 16),
                    _buildField("Password", passCtrl, isPassword: true),
                    const SizedBox(height: 16),
                    _buildField("Email", emailCtrl),
                    const SizedBox(height: 16),

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

                    // PETA KOORDINAT (Ambil dari tempLat/tempLong di Service)
                    if (showLocation)
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
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
                                // Simpan ke variable sementara service
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

                    // TOMBOL SAVE
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!service.isSaving) {
                            // Panggil Save di Service
                            String? error = await service.saveProfile(
                              name: nameCtrl.text,
                              password: passCtrl.text,
                              email: emailCtrl.text,
                              alamat: alamatCtrl.text,
                              lembaga: lembagaCtrl.text,
                              jumlahPenerimaStr: jumlahCtrl.text,
                            );

                            if (context.mounted) {
                              if (error == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Berhasil disimpan!'),
                                  ),
                                );
                                Navigator.pop(context); // Langsung kembali
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
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

  // Widget Helper Field (Sama)
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
