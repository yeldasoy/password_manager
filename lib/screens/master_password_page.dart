// lib/screens/master_password_page.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:password_manager/services/api_service.dart'; // Proje adına göre yolu düzelt
import 'dart:convert';
import 'main_page.dart';

class MasterPasswordPage extends StatefulWidget {
  final String email;
  const MasterPasswordPage({super.key, required this.email});

  @override
  State<MasterPasswordPage> createState() => _MasterPasswordPageState();
}

class _MasterPasswordPageState extends State<MasterPasswordPage> {
  double _opacity = 1.0;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordCompliant = false;
  bool _arePasswordsMatching = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  final RegExp _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  String? _passwordErrorText;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _opacity = 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _confirmPasswordController.removeListener(_validateConfirmPassword);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    List<String> errors = [];

    if (password.length < 12) errors.add('En az 12 karakter olmalı.');
    if (!_uppercaseRegex.hasMatch(password)) errors.add('En az bir büyük harf içermeli.');
    if (!_lowercaseRegex.hasMatch(password)) errors.add('En az bir küçük harf içermeli.');
    if (!_specialCharRegex.hasMatch(password)) errors.add('En az bir özel karakter içermeli.');

    if (mounted) {
      setState(() {
        _isPasswordCompliant = errors.isEmpty;
        _passwordErrorText = errors.isNotEmpty ? errors.join('\n') : null;
        _validateConfirmPassword();
      });
    }
  }

  void _validateConfirmPassword() {
    if (mounted) {
      setState(() {
        _arePasswordsMatching = _passwordController.text.isNotEmpty &&
            _passwordController.text == _confirmPasswordController.text;
      });
    }
  }

  bool get _isButtonEnabled => _isPasswordCompliant && _arePasswordsMatching;

  // master_password_page.dart içindeki _saveMasterPassword fonksiyonunun yeni hali

  void _saveMasterPassword() async {
    if (_isButtonEnabled && !_isLoading) {
      setState(() => _isLoading = true);

      try {
        final response = await ApiService.setMasterPassword(
          email: widget.email,
          password: _passwordController.text,
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          // --- DEĞİŞİKLİK BURADA ---
          // Backend'den gelen salt'ı ve kullanıcının girdiği parolayı alıyoruz
          final String salt = responseData['salt'];
          final String masterPassword = _passwordController.text;

          // Oturumun kalıcı olması için bu bilgileri güvenli depolamaya da yazalım
          final storage = const FlutterSecureStorage();
          await storage.write(key: 'master_password', value: masterPassword);
          await storage.write(key: 'salt', value: salt);
          // Login'de alınan token'ı da burada saklamak gerekebilir, ama login sonrası zaten saklanıyor.

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ana şifre başarıyla oluşturuldu! Giriş yapabilirsiniz.')),
          );

          // MainPage'e artık gerekli parametrelerle yönlendiriyoruz
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage()
            ),
                (route) => false,
          );
          // --- DEĞİŞİKLİK SONU ---

        } else {
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: ${responseData['message'] ?? 'Bilinmeyen hata.'}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bağlantı hatası: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
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
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade900,
                  Colors.blue.shade800,
                  Colors.blue.shade600,
                  Colors.blue.shade200,
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
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                    color: Colors.grey.shade800.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ]),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Ana Şifrenizi Belirleyin',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ana şifreniz',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade400),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          errorText: _passwordErrorText,
                          errorMaxLines: 3,
                          errorStyle: TextStyle(color: Colors.red.shade300),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Parolayı Tekrar Giriniz',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ana şifrenizi tekrar girin',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.lock_reset, color: Colors.grey.shade400),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          errorText: (_confirmPasswordController.text.isNotEmpty && !_arePasswordsMatching && _passwordController.text.isNotEmpty)
                              ? 'Parolalar eşleşmiyor.'
                              : null,
                          errorStyle: TextStyle(color: Colors.red.shade300),
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      ElevatedButton(
                        onPressed: _isButtonEnabled && !_isLoading ? _saveMasterPassword : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isButtonEnabled ? Colors.green.shade600 : Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                        )
                            : Text(
                          'Ana Şifreyi Kaydet',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: _isButtonEnabled ? Colors.white : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}