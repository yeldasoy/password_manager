import 'package:flutter/material.dart';

class MailVerifyPage extends StatefulWidget {
  MailVerifyPage({super.key});

  @override
  State<MailVerifyPage> createState() => _MailVerifyPageState();
}

class _MailVerifyPageState extends State<MailVerifyPage> {
  double _opacity = 1.0;

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

          // Gri opak katman
          AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(seconds: 3),
            curve: Curves.easeOut,
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}


