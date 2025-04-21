// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/main.dart';
import 'package:password_manager/screens/register_page.dart';



void main() {
  testWidgets('Splash screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Ekranda "SOYCEL" yazısı var mı?
    expect(find.text('SOYCEL'), findsOneWidget);

    // Ekrana dokunulunca sayfa geçiyor mu? (kısmi test)
    await tester.tap(find.byType(GestureDetector));
    await tester.pump(); // animation başlar
    await tester.pump(const Duration(seconds: 3)); // animasyon ve navigation için süre tanı

    expect(find.byType(RegisterPage), findsOneWidget);
  });
}