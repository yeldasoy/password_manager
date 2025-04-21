import 'package:flutter/material.dart';
import 'screens/register_page.dart'; // dosya adı küçük harfle, doğru import

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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  bool _startFade = false;
  bool _showTapText = true;

  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();

    // Yanıp sönme animasyonu
    _blinkController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _blinkController.repeat(reverse: true);
  }

  void _startFadeInAndNavigate() {
    setState(() {
      _startFade = true;
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      // yavaşça 0.0 -> 1.0 opaklık
      for (int i = 1; i <= 10; i++) {
        Future.delayed(Duration(milliseconds: i * 200), () {
          setState(() {
            _opacity = i / 10;
          });
        });
      }

      // tamamen opak olunca sayfa geçişi
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => RegisterPage()),
        );
      });
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startFade ? null : _startFadeInAndNavigate,
      child: Scaffold(
        body: Stack(
          children: [
            // Arka plan ve SOYCEL yazısı
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
              child: Center(
                child: Text(
                  'SOYCEL',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),

            // Yanıp sönen "Ekrana dokunun"
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _blinkController,
                child: Text(
                  'Ekrana dokunun',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),

            // Gri opaklık efekti
            AnimatedOpacity(
              opacity: _startFade ? _opacity : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
