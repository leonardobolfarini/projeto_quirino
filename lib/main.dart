import 'package:flutter/material.dart';
import 'package:projeto_quirino/components/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_quirino/services/database_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final dbService = DatabaseService();
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      dbService.initializeUserStats();
    }
  });

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TelaLogin());
  }
}
