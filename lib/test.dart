import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:encrypt/encrypt.dart' as encryptLib;

void main() {
  // Step 1: Generate RSA key pair (public/private key)
  var keyPair = generateRSAKeyPair();
  var publicKey = keyPair.publicKey as RSAPublicKey;
  var privateKey = keyPair.privateKey as RSAPrivateKey;

  print("Public Key: ${publicKey}");
  print("Private Key: ${privateKey}");

  // Step 2: Encrypt a message using the public key
  final message = "This is a secret message.";
  print("Original Message: $message");

  final encryptedMessage = rsaEncrypt(publicKey, message);
  print("Encrypted Message: $encryptedMessage");

  // Step 3: Decrypt the message using the private key
  final decryptedMessage = rsaDecrypt(privateKey, encryptedMessage);
  print("Decrypted Message: $decryptedMessage");
}

// Function to generate RSA KeyPair
AsymmetricKeyPair<PublicKey, PrivateKey> generateRSAKeyPair() {
  final keyGen = RSAKeyGenerator();
  final secureRandom = _getSecureRandom();

  final params = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64);
  keyGen.init(ParametersWithRandom(params, secureRandom));

  return keyGen.generateKeyPair();
}

// Function to get a secure random instance
SecureRandom _getSecureRandom() {
  final secureRandom = FortunaRandom();
  final random = Random.secure();
  final seeds = <int>[];
  for (int i = 0; i < 32; i++) {
    seeds.add(random.nextInt(256));
  }
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
  return secureRandom;
}

// Function to encrypt a message using the public key
String rsaEncrypt(RSAPublicKey publicKey, String plainText) {
  final cipher = RSAEngine()
    ..init(
      true, // true=encrypt
      PublicKeyParameter<RSAPublicKey>(publicKey),
    );

  final encrypted = _processInBlocks(cipher, Uint8List.fromList(plainText.codeUnits));
  return base64Encode(encrypted);
}

// Function to decrypt the message using the private key
String rsaDecrypt(RSAPrivateKey privateKey, String encryptedText) {
  final cipher = RSAEngine()
    ..init(
      false, // false=decrypt
      PrivateKeyParameter<RSAPrivateKey>(privateKey),
    );

  final decrypted = _processInBlocks(cipher, base64Decode(encryptedText));
  return String.fromCharCodes(decrypted);
}

// Helper function to process data in blocks (RSA requires block processing)
Uint8List _processInBlocks(RSAEngine engine, Uint8List input) {
  final numBlocks = input.lengthInBytes ~/ engine.inputBlockSize + 1;
  final output = BytesBuilder();

  for (var i = 0; i < numBlocks; i++) {
    final start = i * engine.inputBlockSize;
    final end = (i + 1) * engine.inputBlockSize < input.length
        ? (i + 1) * engine.inputBlockSize
        : input.length;
    output.add(engine.process(input.sublist(start, end)));
  }

  return output.toBytes();
}
