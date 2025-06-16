// lib/screens/mail_verify_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'master_password_page.dart';
import 'package:password_manager/services/api_service.dart'; // Proje adına göre yolu düzelt
import 'dart:convert';

class MailVerifyPage extends StatefulWidget {
  final String email;
  const MailVerifyPage({super.key, required this.email});

  @override
  State<MailVerifyPage> createState() => _MailVerifyPageState();
}

class _MailVerifyPageState extends State<MailVerifyPage> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  double _opacity = 1.0;
  int _remainingSeconds = 180;
  late Timer _timer;
  late AnimationController _controller;
  final List<TextEditingController> _codeControllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _opacity = 0.0;
        });
      }
    });
    _startTimer();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _remainingSeconds),
    )..forward();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Doğrulama süresi doldu. Lütfen tekrar kod isteyin.')),
          );
        }
      }
    });
  }

  void _resendCode() {
    // Backend'e yeniden kod gönderme isteği atılabilir. Şimdilik sadece arayüzü sıfırlıyoruz.
    if (mounted) {
      setState(() {
        _remainingSeconds = 180;
        _controller.reset();
        _controller.forward();
        if (_timer.isActive) {
          _timer.cancel();
        }
        _startTimer();
        for (var controller in _codeControllers) {
          controller.clear();
        }
        if (_focusNodes.isNotEmpty) {
          FocusScope.of(context).requestFocus(_focusNodes.first);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni doğrulama kodu mail adresinize gönderildi.')),
      );
    }
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

  Future<void> _verifyCode() async {
    if (_isLoading) return;
    String enteredCode = _codeControllers.map((c) => c.text).join();
    if (enteredCode.length != 6) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.verifyEmail(
        email: widget.email,
        code: enteredCode,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MasterPasswordPage(email: widget.email),
          ),
        );
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${responseData['message'] ?? 'Bilinmeyen hata.'}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bağlantı hatası: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          if (value.isNotEmpty && index < _focusNodes.length - 1) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
          String enteredCode = _codeControllers.map((c) => c.text).join();
          if (enteredCode.length == 6) {
            _verifyCode();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Mail Doğrulama',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Lütfen ${widget.email} adresine gönderilen 6 haneli doğrulama kodunu girin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: CircleCountdownPainter(
                                  progress: 1.0 - (_remainingSeconds / 180.0),
                                ),
                                child: Container(width: 150, height: 150),
                              );
                            },
                          ),
                          if (_isLoading)
                            const CircularProgressIndicator(color: Colors.white)
                          else
                            Text(
                              '$_remainingSeconds',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return _buildCodeField(index);
                      }),
                    ),
                    const SizedBox(height: 30),
                    TextButton(
                      onPressed: _remainingSeconds == 0 ? _resendCode : null,
                      child: Text(
                        'Tekrar Kod Gönder',
                        style: TextStyle(
                          color: _remainingSeconds == 0 ? Colors.white : Colors.white54,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
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

// Hatanın sebebi olan eksik metotlar burada eklendi.
class CircleCountdownPainter extends CustomPainter {
  final double progress;
  final Color color = Colors.white;
  final double strokeWidth = 8;

  CircleCountdownPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Paint progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(center, radius, backgroundPaint);

    double sweepAngle = 2 * 3.1415926535897932 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535897932 / 2,
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