/// ============================================
/// SERVIÇO DE CRIPTOGRAFIA - CORRIGIDO
/// ============================================

import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

class EncryptionService {
  // ← Removendo const
  EncryptionService();

  encrypt.Key? _key;
  encrypt.IV? _iv;

  void initialize(String keyString, String ivString) {
    _key = encrypt.Key.fromBase64(keyString);
    _iv = encrypt.IV.fromBase64(ivString);
  }

  String encryptText(String text) {
    try {
      if (_key == null || _iv == null) {
        throw Exception('EncryptionService não foi inicializado');
      }
      final encrypter = encrypt.Encrypter(encrypt.AES(_key!));
      final encrypted = encrypter.encrypt(text, iv: _iv!);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Erro ao criptografar dados: $e');
    }
  }

  String decryptText(String encrypted) {
    try {
      if (_key == null || _iv == null) {
        throw Exception('EncryptionService não foi inicializado');
      }
      final encrypter = encrypt.Encrypter(encrypt.AES(_key!));
      final decrypted = encrypter.decrypt(
        encrypt.Encrypted.fromBase64(encrypted),
        iv: _iv!,
      );
      return decrypted;
    } catch (e) {
      throw Exception('Erro ao descriptografar dados: $e');
    }
  }

  String hashPassword(String password, {String? salt}) {
    final bytes = utf8.encode(password + (salt ?? ''));
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  bool verifyPassword(String password, String hash, {String? salt}) {
    final computedHash = hashPassword(password, salt: salt);
    return computedHash == hash;
  }

  String generateSecureToken(int length) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(bytes).substring(0, length);
  }

  String encryptMap(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    return encryptText(jsonString);
  }

  Map<String, dynamic> decryptMap(String encrypted) {
    final jsonString = decryptText(encrypted);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  String generateKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String generateIV() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
