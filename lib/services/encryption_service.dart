// lib/services/encryption_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart' as pointy;
import 'package:flutter/foundation.dart';

Uint8List _deriveKey(Map<String, String> params) {
  final masterPassword = params['masterPassword']!;
  final salt = params['salt']!;

  final saltBytes = base64.decode(salt);
  final keyBytes = utf8.encode(masterPassword);

  final derivator = pointy.KeyDerivator('SHA-256/HMAC/PBKDF2');

  // --- DEĞİŞİKLİK BURADA ---
  // Tekrar sayısını 480,000'den daha makul bir seviyeye düşürdük.
  final pbkdf2Params = pointy.Pbkdf2Parameters(saltBytes, 300, 32);
  // --- DEĞİŞİKLİK SONU ---

  derivator.init(pbkdf2Params);

  return derivator.process(Uint8List.fromList(keyBytes));
}

class EncryptionService {
  late final encrypt.Key _key;

  EncryptionService();

  Future<void> initialize({required String masterPassword, required String salt}) async {
    final derivedKeyBytes = await compute(_deriveKey, {
      'masterPassword': masterPassword,
      'salt': salt,
    });
    _key = encrypt.Key(derivedKeyBytes);
  }

  Map<String, String> encryptData(String plainText) {
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return {
      'data': encrypted.base64,
      'iv': iv.base64,
    };
  }

  String decryptData({required String encryptedBase64, required String ivBase64}) {
    try {
      final iv = encrypt.IV.fromBase64(ivBase64);
      final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
      final encrypted = encrypt.Encrypted.fromBase64(encryptedBase64);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      return decrypted;
    } catch (e) {
      return "Şifre çözülemedi";
    }
  }
}