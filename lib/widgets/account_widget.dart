import 'package:flutter/material.dart';
import 'package:project_rpll/providers/auth_provider.dart';
import 'package:project_rpll/screens/start_screen.dart';
import 'package:provider/provider.dart';

class AccountWidget extends StatelessWidget {
  const AccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network('https://thumbs.dreamstime.com/b/creative-illustration-default-avatar-profile-placeholder-isolated-background-art-design-grey-photo-blank-template-mockup-144855718.jpg',width: 200, height: 200,),
          SizedBox(height: 16,),
          Text('Username', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,),
          SizedBox(height: 8,),
          Text('Email', style: TextStyle(fontSize: 16),),
          SizedBox(height: 16,),
          ElevatedButton.icon(onPressed: (){
          }, label: Text('Edit Profile'),icon: Icon(Icons.edit),),
          SizedBox(height: 16,),
          ElevatedButton.icon(onPressed: (){
            AuthProvider().logout();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StartScreen()));
          }, label: Text('Logout'),icon: Icon(Icons.logout),),
        ],
      ),
    );
  }
}
