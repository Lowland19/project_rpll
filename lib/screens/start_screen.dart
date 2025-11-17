import 'package:flutter/material.dart';
import 'package:project_rpll/screens/login_screen.dart';
import 'package:project_rpll/screens/registration_page.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 72),
              Text(
                'Sistem Monitoring &',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Pelaporan MBG',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Image(
                image: AssetImage('lib/assets/images/logo.jpg'),
                height: 300,
                width: 300,
              ),
              SizedBox(height: 96),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text('Login'),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistrationPage()),
                    );
                  },
                  child: Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
