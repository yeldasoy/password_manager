// lib/screens/password_generator.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_manager/screens/main_page.dart';
import 'package:password_manager/screens/setting_page.dart';
import 'dart:math';

class PasswordGenerator extends StatefulWidget {
  final String masterPassword;
  final String salt;
  const PasswordGenerator({
    super.key,
    required this.masterPassword,
    required this.salt,
  });

  static String generateNewPassword() {
    const String uppercaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowercaseLetters = 'abcdefghijklmnopqrstuvwxyz';
    const String digits = '0123456789';
    const String specialChars = '!@#\$%^&*()_+-=';
    const String allChars =
        '$uppercaseLetters$lowercaseLetters$digits$specialChars';

    final random = Random.secure();

    String tempPassword = '';
    tempPassword += uppercaseLetters[random.nextInt(uppercaseLetters.length)];
    tempPassword += lowercaseLetters[random.nextInt(lowercaseLetters.length)];
    tempPassword += digits[random.nextInt(digits.length)];
    tempPassword += specialChars[random.nextInt(specialChars.length)];

    int desiredLength = 12;
    while (tempPassword.length < desiredLength) {
      tempPassword += allChars[random.nextInt(allChars.length)];
    }

    List<String> passwordChars = tempPassword.split('');
    passwordChars.shuffle(random);

    return passwordChars.join('');
  }

  @override
  State<PasswordGenerator> createState() => _PasswordGeneratorState();
}

class _PasswordGeneratorState extends State<PasswordGenerator> {
  double _opacity = 1.0;
  int _selectedIndex = 1;
  String _generatedPassword = "";

  final List<String> _menuItems = ["Şifrelerim", "Şifre Yaratıcı", "Ayarlarım"];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _opacity = 0.0;
        });
      }
    });
  }

  void _generatePassword() {
    setState(() {
      _generatedPassword = PasswordGenerator.generateNewPassword();
    });
  }

  void _copyToClipboard() {
    if (_generatedPassword.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedPassword));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifre kopyalandı!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(seconds: 3),
            curve: Curves.easeOut,
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Rastgele Şifre Üret",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _generatedPassword.isEmpty
                                      ? "Şifre oluşturmak için butona basın"
                                      : _generatedPassword,
                                  style: TextStyle(
                                      color: _generatedPassword.isEmpty
                                          ? Colors.grey[600]
                                          : Colors.black,
                                      fontSize: 16),
                                ),
                              ),
                              Positioned(
                                right: 10,
                                child: TextButton(
                                  onPressed: _copyToClipboard,
                                  child: const Text("Kopyala"),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _generatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Şifre Üret",
                              style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_menuItems.length, (index) {
                      bool isSelected = index == _selectedIndex;
                      return GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainPage(
                                      masterPassword: widget.masterPassword,
                                      salt: widget.salt)),
                            );
                          } else if (index == 2) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingPage(
                                      masterPassword: widget.masterPassword,
                                      salt: widget.salt)),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color:
                            isSelected ? Colors.grey.shade300 : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _menuItems[index],
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}