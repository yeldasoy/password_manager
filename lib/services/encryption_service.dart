// lib/services/encryption_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart' as pointy;
import 'package:flutter/foundation.dart'; // `compute` fonksiyonu için gereklidir

/// Bu fonksiyon, ağır hesaplama yaptığı için `compute` ile arka planda (ayrı bir Isolate'ta) çalıştırılacaktır.
/// Bu yüzden sınıfın dışında, en üst seviyede tanımlanmalıdır.
Uint8List _deriveKey(Map<String, String> params) {
  final masterPassword = params['masterPassword']!;
  final salt = params['salt']!;

  final saltBytes = base64.decode(salt);
  final keyBytes = utf8.encode(masterPassword);

  // PBKDF2 algoritması, paroladan güvenli bir anahtar türetmek için kullanılır.
  final derivator = pointy.KeyDerivator('SHA-256/HMAC/PBKDF2');

  // Tekrar sayısı, güvenlik ve performans arasındaki dengeyi belirler.
  // Geliştirme için 30,000 makul bir değerdir.
  final pbkdf2Params = pointy.Pbkdf2Parameters(saltBytes, 30000, 32); // salt, iterations, key length (32 byte = 256 bit)

  derivator.init(pbkdf2Params);

  // Ana paroladan 256-bit'lik anahtar türetilir.
  return derivator.process(Uint8List.fromList(keyBytes));
}

class EncryptionService {
  late final encrypt.Key _key;

  // Constructor boştur. Başlatma işlemi asenkron olarak yapılır.
  EncryptionService();

  /// Servisi, ana parola ve salt ile asenkron olarak başlatır.
  /// Ağır anahtar türetme işlemi bu aşamada arka planda yapılır.
  Future<void> initialize({required String masterPassword, required String salt}) async {
    final derivedKeyBytes = await compute(_deriveKey, {
      'masterPassword': masterPassword,
      'salt': salt,
    });
    _key = encrypt.Key(derivedKeyBytes);
  }

  encrypt.IV generateIV() {
    return encrypt.IV.fromLength(16);
  }

  /// Verilen bir metni, DIŞARIDAN VERİLEN bir IV ile şifreler.
  String encryptField(String plainText, encrypt.IV iv) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  /// Verilen şifreli metnin, verilen bir IV ile şifresini çözer.
  String decryptField({required String encryptedBase64, required String ivBase64}) {
    try {
      final iv = encrypt.IV.fromBase64(ivBase64);
      final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
      final encrypted = encrypt.Encrypted.fromBase64(encryptedBase64);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      return decrypted;
    } catch (e) {
      print("DECRYPTION ERROR: $e");
      return "Şifre çözülemedi";
    }
  }
}