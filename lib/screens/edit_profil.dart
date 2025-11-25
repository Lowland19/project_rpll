import 'package:flutter/material.dart';


class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController nameController =
  TextEditingController(text: "Andhika");
  final TextEditingController passwordController =
  TextEditingController(text: "********");
  final TextEditingController emailController =
  TextEditingController(text: "andhika@gmail.com");
  final TextEditingController phoneController =
  TextEditingController(text: "+62 855-2476-0692");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E0E),
      body: Stack(
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
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
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Avatar
                CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(
                    'https://thumbs.dreamstime.com/b/creative-illustration-default-avatar-profile-placeholder-isolated-background-art-design-grey-photo-blank-template-mockup-144855718.jpg',
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Ubah Foto",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 30),

                // FORM FIELD
                _buildField("Nama Lengkap", nameController),
                const SizedBox(height: 16),
                _buildField("Password", passwordController, isPassword: true),
                const SizedBox(height: 16),
                _buildField("Email", emailController),
                const SizedBox(height: 16),
                _buildField("Nomor Telepon", phoneController),

                const SizedBox(height: 30),

                // SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "SAVE CHANGES",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CUSTOM FORM FIELD
  Widget _buildField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
