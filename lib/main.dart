// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:password_manager/screens/how_to_use_page.dart';
import 'package:password_manager/screens/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndNavigate();
  }

  Future<void> _checkLoginStatusAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    // --- DEĞİŞİKLİK BURADA ---
    // Sadece token'ı değil, diğer bilgileri de oku
    final token = await _storage.read(key: 'jwt_token');
    final masterPassword = await _storage.read(key: 'master_password');
    final salt = await _storage.read(key: 'salt');

    if (!mounted) return;

    // Tüm bilgiler mevcutsa Ana Sayfa'ya git
    if (token != null && masterPassword != null && salt != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                MainPage(masterPassword: masterPassword, salt: salt)),
      );
    } else {
      // Bilgilerden herhangi biri eksikse Tanıtım sayfasına git
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HowToUsePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // build metodu aynı kalabilir
    return Scaffold(
      body: Container(
        // ... (kodun geri kalanı aynı) ...
      ),
    );
  }
}