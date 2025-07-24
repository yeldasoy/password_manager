// lib/screens/setting_page.dart

import 'package:flutter/material.dart';
import 'package:password_manager/screens/main_page.dart';
import 'package:password_manager/screens/password_generator.dart';
import 'package:password_manager/screens/login_page.dart';
import 'package:password_manager/services/api_service.dart';
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
  bool _agreedToDelete = false;
  bool _isDeleting = false;

  final List<String> _menuItems = ["Şifrelerim", "Şifre Yaratıcı", "Ayarlarım"];

  // Oturumu kapatır, sadece cihazdaki verileri siler
  void _logout() async {
    final storage = const FlutterSecureStorage();
    await storage.deleteAll(); // Güvenli depolamadaki her şeyi (token, salt vb.) sil
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );
    }
  }

  // Hesabı hem backend'den hem de cihazdan tamamen siler
  void _deleteAccount() async {
    setState(() { _isDeleting = true; });

    final response = await ApiService.deleteAccount();

    if (!mounted) return;

    if (response.statusCode == 200) {
      // Backend'den başarıyla silindiyse, cihazdaki oturumu da kapat
      _logout();
    } else {
      // Hata durumunda kullanıcıyı bilgilendir
      Navigator.of(context).pop(); // Onay diyaloğunu kapat
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hesap silinirken bir hata oluştu.")),
      );
    }

    if (mounted) {
      setState(() { _isDeleting = false; });
    }
  }

  void _showDeleteConfirmationDialog() {
    // Checkbox'ı her diyalog açıldığında sıfırla
    _agreedToDelete = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Dikkat", style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text("Hesabınız ve tüm şifreleriniz kalıcı olarak silinecektir!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _agreedToDelete,
                          onChanged: (value) {
                            setDialogState(() {
                              _agreedToDelete = value!;
                            });
                          },
                        ),
                        const Expanded(child: Text("Bu işlemin geri alınamayacağını anlıyorum ve onaylıyorum.", style: TextStyle(color: Colors.black))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _isDeleting
                        ? const CircularProgressIndicator()
                        : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600]),
                            child: const Text("Vazgeç"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _agreedToDelete ? _deleteAccount : null,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text("Hesabı Sil"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
                        const Text("Ayarlar", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        const SizedBox(height: 30),
                        TextButton(
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: Colors.grey[200]),
                          onPressed: _logout,
                          child: const Text("Oturumu Kapat", style: TextStyle(color: Colors.black, fontSize: 16)),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: Colors.red.withOpacity(0.1)),
                          onPressed: _showDeleteConfirmationDialog,
                          child: const Text("Hesabı Sil", style: TextStyle(color: Colors.red, fontSize: 16)),
                        ),
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
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.grey.shade300 : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _menuItems[index],
                            style: TextStyle(
                                fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal),
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