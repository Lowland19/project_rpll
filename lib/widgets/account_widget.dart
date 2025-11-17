import 'package:flutter/material.dart';
import 'package:project_rpll/providers/auth_provider.dart';
import 'package:project_rpll/screens/start_screen.dart';
import 'package:provider/provider.dart';

class AccountWidget extends StatelessWidget {
  const AccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kelola Akun', textAlign: TextAlign.start,),
        ElevatedButton(
          onPressed: () {
            Provider.of<AuthProvider>(context,listen: false).logout();
            Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=> StartScreen()),(route)=>false);
          },
          child: Text('Logout'),
        ),
      ],
    );
  }
}
