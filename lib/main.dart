import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:socialwall/auth/auth.dart';
import 'package:socialwall/theme/dark_theme.dart';
import 'package:socialwall/theme/light_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const AuthPage(),
    );
  }
}
