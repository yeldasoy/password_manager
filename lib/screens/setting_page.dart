// lib/screens/setting_page.dart

import 'package:flutter/material.dart';
import 'package:password_manager/screens/main_page.dart';
import 'package:password_manager/screens/password_generator.dart';
import 'package:password_manager/screens/login_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingPage extends StatefulWidget {
  final String masterPassword;
  final String salt;
  const SettingPage(
      {super.key, required this.masterPassword, required this.salt});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int _selectedIndex = 2;
  final List<String> _menuItems = ["Şifrelerim", "Şifre Yaratıcı", "Ayarlarım"];

  void _logout() async {
    final storage = const FlutterSecureStorage();
    await storage.deleteAll(); // Güvenli depolamadaki her şeyi sil
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan
          Container(
            decoration: BoxDecoration(
              // ... (gradient aynı) ...
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text("Ayarlar",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 30),
                        TextButton(onPressed: _logout, child: const Text("Oturumu Kapat")),
                        const SizedBox(height: 12),
                        TextButton(onPressed: () {}, child: const Text("Hesabı Sil")),
                      ],
                    ),
                  ),
                ),
                // Alt Menü
                Container(
                  color: Colors.white,
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_menuItems.length, (index) {
                      bool isSelected = index == _selectedIndex;
                      return GestureDetector(
                        onTap: () {
                          // --- DEĞİŞİKLİK BURADA ---
                          if (index == 0) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainPage(
                                      masterPassword: widget.masterPassword,
                                      salt: widget.salt)),
                            );
                          } else if (index == 1) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PasswordGenerator(
                                      masterPassword: widget.masterPassword,
                                      salt: widget.salt)),
                            );
                          }
                          // --- DEĞİŞİKLİK SONU ---
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.grey.shade300
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _menuItems[index],
                            style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}