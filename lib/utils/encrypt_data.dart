import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class AesEncryption {
  // Function to generate the key, IV, and create an encrypter
  static AesResult generateKeyIvAndEncrypter1(String plainText) {
    final key = Key.fromSecureRandom(32); // 32 bytes for AES-256
    final iv = IV.fromLength(16); // 16 bytes for AES in GCM mode

    final keyBase64 = base64Encode(key.bytes); // Convert key bytes to Base64
    final ivBase64 = base64Encode(iv.bytes); // Convert IV bytes to Base64

    final encrypter = Encrypter(AES(key)); // Create the AES encrypter
    final text = encrypter.encrypt(plainText, iv: iv);
    final decrypted = encrypter.decrypt(text, iv: iv);

    return AesResult(key: keyBase64, iv: ivBase64, encrypter: text.base64);

  }
  static String decryptData(String key64,String iv64, String text){
    final  retrievedKey = Key.fromBase64(key64);
    final retrievedIv = IV.fromBase64(iv64);
    final encrypterForDecryption = Encrypter(AES(retrievedKey));
    return encrypterForDecryption.decrypt(Encrypted.fromBase64(text), iv: retrievedIv);

  }


}

// Class to hold the result
class AesResult {
  final String key;
  final String iv;
  final String encrypter;

  AesResult({
    required this.key,
    required this.iv,
    required this.encrypter,
  });
}