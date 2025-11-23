import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(color: Color(0xFF3B0E0E))),
          Positioned(
            top: -50,
            left: -40,
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
            const SizedBox(height: 170),
            const Text(
              "Lupa Password",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Email / User ID',
                labelStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.email, color: Colors.white),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
              validator: (value) => (value == null || value.isEmpty) ? "Email tidak boleh kosong" : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await context.read<AuthProvider>().forgotPassword(_emailController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Link reset password telah dikirim")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
                child: const Text("Kirim Reset", style: TextStyle(color: Colors.white)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Kembali ke Login", style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}
