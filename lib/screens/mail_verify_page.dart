import 'dart:async';
import 'package:flutter/material.dart';
import 'main_page.dart';

class MailVerifyPage extends StatefulWidget {
  MailVerifyPage({super.key});

  @override
  State<MailVerifyPage> createState() => _MailVerifyPageState();
}

class _MailVerifyPageState extends State<MailVerifyPage> with SingleTickerProviderStateMixin {
  double _opacity = 1.0;
  int _remainingSeconds = 180;
  late Timer _timer;
  late AnimationController _controller;
  List<TextEditingController> _codeControllers =
  List.generate(6, (index) => TextEditingController());
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 0.0;
      });
    });

    _startTimer();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 180),
    )..forward();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Widget _buildCodeField(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _codeControllers[index],
        focusNode: _focusNodes[index],
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, color: Colors.white),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white24,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          }

          if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }

          // Tüm kutular dolduğunda kontrol et
          Future.delayed(const Duration(milliseconds: 100), () {
            String enteredCode = _codeControllers.map((c) => c.text).join();
            if (enteredCode.length == 6) {
              if (enteredCode == '000000') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kod yanlış!')),
                );
              }
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan
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

          // İçerik
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Büyük beyaz çember ve sayaç
                SizedBox(
                  width: 150, // 5 kat büyütülmüş
                  height: 150,
                  child: CustomPaint(
                    painter: CircleCountdownPainter(
                      progress: 1.0 - _controller.value,
                      color: Colors.white,
                      strokeWidth: 5,
                    ),
                    child: Center(
                      child: Text(
                        '$_remainingSeconds',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Kod kutuları
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildCodeField(index),
                    );
                  }),
                ),
                const SizedBox(height: 30),


                // Tekrar Kod Gönder butonu
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _remainingSeconds = 180;
                      _controller.reset();
                      _controller.forward();
                      _timer.cancel();
                      _startTimer();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Tekrar Kod Gönder',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              ],
            ),
          ),


        ],
      ),
    );
  }
}

class CircleCountdownPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircleCountdownPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint basePaint = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Paint progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - strokeWidth) / 2;

    // Dış çember
    canvas.drawCircle(center, radius, basePaint);

    // Geriye kalan süre çemberi (ters yönde)
    double sweepAngle = 2 * 3.1415926535897932 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircleCountdownPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
