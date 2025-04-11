import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionHelper {
  static final _storage = FlutterSecureStorage();

  static Future<encrypt.Key> _getKey() async {
    String? storedKey = await _storage.read(key: "aes_key");
    if (storedKey == null) {
      final key = encrypt.Key.fromSecureRandom(32);
      await _storage.write(key: "aes_key", value: key.base64);
      return key;
    }
    return encrypt.Key.fromBase64(storedKey);
  }

  static Future<String> encryptData(String plainText) async {
    final key = await _getKey();
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return "${encrypted.base64}:${iv.base64}";
  }

  static Future<String> decryptData(String encryptedText) async {
    final key = await _getKey();
    final parts = encryptedText.split(":");
    final iv = encrypt.IV.fromBase64(parts[1]);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    return encrypter.decrypt(encrypt.Encrypted.fromBase64(parts[0]), iv: iv);
  }
}
