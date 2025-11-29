
import 'package:flutter/material.dart';
import 'package:project_rpll/providers/auth_provider.dart';
import 'package:project_rpll/screens/autentifikasi/change_password.dart';
import 'package:project_rpll/screens/start_screen.dart';
import 'package:project_rpll/services/profiles_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nllcrrhaopkxionuvzlp.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5sbGNycmhhb3BreGlvbnV2emxwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1NjUyMzQsImV4cCI6MjA3ODE0MTIzNH0.Ep_nBYRK8lNbLo_TppCmYsXFNuBs6yB6sAl66IiL964',
  );

  // 🔥 FIX: Supabase reset password URL: ?code=xxxx
  final uri = Uri.base;
  final bool isRecovery = uri.queryParameters.containsKey('code');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => ProfileService()..fetchUserProfile(),
        ),
      ],
      child: MyApp(isRecovery: isRecovery),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isRecovery;

  const MyApp({super.key, required this.isRecovery});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPPG MBG',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      // 🔥 Jika user membuka link email reset password → langsung ke ChangePasswordPage
      home: isRecovery ? const ChangePasswordPage() : const StartScreen(),
    );
  }
}
