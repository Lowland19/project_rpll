import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF3B0E0E)),

          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 170,
              height: 170,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF5A0E0E),
              ),
            ),
          ),

          _buildContent(),

          const Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Kontak Bantuan:",
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                Text("Email : sppg_support@mbg.go.id",
                    style: TextStyle(color: Colors.white, fontSize: 11)),
                Text("Telepon : 0812-3456-7890",
                    style: TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 150),
            const Text(
              "Ganti Password",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            _inputField(
              controller: _newPass,
              label: "Password Baru",
              icon: Icons.lock_reset,
              isPassword: true,
            ),

            const SizedBox(height: 20),

            _inputField(
              controller: _confirmPass,
              label: "Konfirmasi Password",
              icon: Icons.lock,
              isPassword: true,
              validator: (value) =>
              value != _newPass.text ? "Password tidak cocok" : null,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await context
                          .read<AuthProvider>()
                          .changePassword(_newPass.text);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Password berhasil diganti."),
                        ),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
                child: const Text("Simpan",
                    style: TextStyle(color: Colors.white)),
              ),
            ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Kembali",
                  style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      validator: validator ??
              (value) =>
          (value == null || value.isEmpty)
              ? "$label tidak boleh kosong"
              : null,
    );
  }
}
