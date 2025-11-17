import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_screen.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 172),
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Masukan ID Pengguna Anda',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'User ID tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'Masukan Password Anda',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (value.length < 8) {
                    return 'Password harus memiliki minimal 8 karakter';
                  }
                  return null;
                },
              ),
              SizedBox(height: 48),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await context.read<AuthProvider>().registerUser(
                          email: _userIdController.text,
                          password: _passwordController.text,
                        );
                        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=> HomeScreen()),(route)=>false);
                      } catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
