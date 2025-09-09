import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class CryptoHelper {
  final Key key; // 32 bytes for AES-256
  final IV iv; // 16 bytes

  CryptoHelper(String keyString, String ivString)
    : key = Key.fromUtf8(keyString.padRight(32, '0')),
      iv = IV.fromUtf8(ivString.padRight(16, '0'));

  String encryptText(String plainText) {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  String decryptText(String encryptedText) {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }
}
