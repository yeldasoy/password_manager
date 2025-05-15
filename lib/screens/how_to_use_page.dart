import 'package:flutter/material.dart';
import 'register_page.dart';
import 'login_page.dart';

class HowToUsePage extends StatefulWidget {
  HowToUsePage({super.key});

  @override
  State<HowToUsePage> createState() => _HowToUsePageState();
}

class _HowToUsePageState extends State<HowToUsePage> {
  double _opacity = 1.0;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 0.0;
      });
    });
  }

  List<Widget> get _slides => [
    _buildSlide("Hoşgeldiniz ", "Bu uygulama ile şifrelerinizi güvenle saklayabilirsiniz."),
    _buildSlide("Güvenlik", "Uygulamaya ilk defa kayıt olduktan sonra bir ana şifre oluşturmalısınız. Bu şifre sayesinde tüm uygulamalarda kullanacağınız şifreler uygulamamızda özel şifreleme tekniği ile saklanır. Üçüncü kişilerin hırsızlık girişimlerinden korunursunuz. "),
    _buildSlide("!!!Uyarı!!!", "Ana Şifrenizi unutmanız durumunda şifre yeniden oluşturulamamaktadır!!!"),
    _buildSlide("Başlayalım", "Kayıt olarak hemen kullanmaya başlayabilirsiniz.",
        showButtons: true),
  ];

  Widget _buildSlide(String title, String description, {bool showButtons = false}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          Text(description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.white70)),
          const SizedBox(height: 40),
          if (showButtons)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => RegisterPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text("Kayıt Ol"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => LoginPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text("Giriş Yap"),
                ),
              ],
            )
        ],
      ),
    );
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

          // Gri opak katman
          AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(seconds: 3),
            curve: Curves.easeOut,
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),

          // Popup Slide (Ortalanmış)
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.95,
              heightFactor: 0.8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: _slides,
                    ),

                    // Sol ok
                    if (_currentPage > 0)
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () {
                            _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          },
                        ),
                      ),

                    // Sağ ok
                    if (_currentPage < _slides.length - 1)
                      Positioned(
                        right: 8,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          onPressed: () {
                            _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
