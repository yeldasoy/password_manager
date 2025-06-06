import 'package:flutter/material.dart';
import 'main_page.dart';
import 'setting_page.dart';

class PasswordGenerator extends StatefulWidget {
  PasswordGenerator({super.key});

  @override
  State<PasswordGenerator> createState() => _PasswordGeneratorState();
}

class _PasswordGeneratorState extends State<PasswordGenerator> {
  double _opacity = 1.0;
  int _selectedIndex = 0;

  final List<String> _menuItems = ["Şifrelerim", "Şifre Yaratıcı", "Ayarlarım"];

  @override
  void initState() {
    super.initState();

    // Sayfa açıldığında opaklığı yavaşça azalt
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arkadaki mavi gradient arka plan
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Colors.blue.shade900,
                  Colors.blue.shade800,
                  Colors.blue.shade600,
                  Colors.blue.shade200
                ],
              ),
            ),
          ),

          // Gri opak katman (animasyonlu)
          AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(seconds: 3),
            curve: Curves.easeOut,
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),

          // Geri Dön Butonu
          Positioned(
            top: 40,
            left: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Önceki sayfaya döner
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Geri Dön',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
        // Alt Menü
        
      ),
    );
  }
}
