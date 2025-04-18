import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Başlık
                  Text(
                    'Kayıt Ol',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Ad
                  _buildTextField(label: "Ad"),
                  const SizedBox(height: 16),

                  // Soyad
                  _buildTextField(label: "Soyad"),
                  const SizedBox(height: 16),

                  // Email
                  _buildTextField(label: "Email", keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),

                  // Şifre
                  _buildTextField(label: "Şifre", obscure: true),
                  const SizedBox(height: 16),

                  // Şifre Tekrar
                  _buildTextField(label: "Şifre (Tekrar)", obscure: true),
                  const SizedBox(height: 32),

                  // Kayıt Ol Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Backend'e gönderilecek alanlar burada işlenebilir
                        }
                      },
                      child: const Text(
                        "Kayıt Ol",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Giriş yap bağlantısı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Zaten bir hesabın var mı?"),
                      TextButton(
                        onPressed: () {
                          // Giriş sayfasına yönlendirme
                        },
                        child: const Text("Giriş Yap"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.teal[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? '$label boş bırakılamaz' : null,
    );
  }
}
