import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:SecureTalk/test.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart';
import 'package:asn1lib/asn1lib.dart'; // for encoding to ASN.1 (PEM format)

void main() {
  // Generate RSA key pair
  var keyPair = generateRSAKeyPair();
  var publicKey = keyPair.publicKey as RSAPublicKey;
  var privateKey = keyPair.privateKey as RSAPrivateKey;

  // Print public key in PEM format
  List<int> mydataint = utf8.encode(CryptoUtils.encodeRSAPublicKeyToPem(publicKey));
  String bs64str = base64.encode(mydataint);


  List<int> mydataint2 = utf8.encode(CryptoUtils.encodeRSAPrivateKeyToPem(privateKey));
  String bs64str2 = base64.encode(mydataint2);



  print("${bs64str}");
  print("$bs64str2");
  // print("Public Key (PEM):\n${customEncodeRSAPublicKeyToPem(publicKey)}");
  // // Print private key in PEM format
  // print("Private Key (PEM):\n${encodeRSAPrivateKeyToPem(privateKey)}");

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

// Encode RSA public key to PEM format
String encodeRSAPublicKeyToPem(RSAPublicKey publicKey) {
  var topLevelSeq = ASN1Sequence();
  topLevelSeq.add(ASN1Integer(publicKey.modulus!));
  topLevelSeq.add(ASN1Integer(publicKey.exponent!));

  var dataBase64 = base64.encode(ASN1Sequence.fromBytes(topLevelSeq.encodedBytes).encodedBytes);
  return '''-----BEGIN PUBLIC KEY-----\n${_chunkString(dataBase64)}\n-----END PUBLIC KEY-----''';
}

// Encode RSA private key to PEM format
String encodeRSAPrivateKeyToPem(RSAPrivateKey privateKey) {
  var topLevelSeq = ASN1Sequence();
  topLevelSeq.add(ASN1Integer(BigInt.from(0))); // version
  topLevelSeq.add(ASN1Integer(privateKey.n!));
  topLevelSeq.add(ASN1Integer(privateKey.exponent!));
  topLevelSeq.add(ASN1Integer(privateKey.privateExponent!));
  topLevelSeq.add(ASN1Integer(privateKey.p!));
  topLevelSeq.add(ASN1Integer(privateKey.q!));
  topLevelSeq.add(ASN1Integer(privateKey.privateExponent! % (privateKey.p! - BigInt.one)));
  topLevelSeq.add(ASN1Integer(privateKey.privateExponent! % (privateKey.q! - BigInt.one)));
  topLevelSeq.add(ASN1Integer(privateKey.q!.modInverse(privateKey.p!)));

  var dataBase64 = base64.encode(ASN1Sequence.fromBytes(topLevelSeq.encodedBytes).encodedBytes);
  return '''-----BEGIN PRIVATE KEY-----\n${_chunkString(dataBase64)}\n-----END PRIVATE KEY-----''';
}

// Helper function to format base64 strings in PEM format (64 characters per line)
String _chunkString(String str, {int chunkSize = 64}) {
  final regex = RegExp('.{1,$chunkSize}');
  return regex.allMatches(str).map((match) => match.group(0)).join('\n');
}
String customEncodeRSAPublicKeyToPem(RSAPublicKey publicKey) {
  // Convert modulus and exponent to hexadecimal strings
  String modulusHex = publicKey.modulus!.toRadixString(16);
  String exponentHex = publicKey.exponent!.toRadixString(16);

  // Ensure the hex strings are properly padded (must be a multiple of 2 in length)
  if (modulusHex.length % 2 != 0) modulusHex = "0$modulusHex";
  if (exponentHex.length % 2 != 0) exponentHex = "0$exponentHex";

  // Convert hexadecimal strings to bytes
  final modulusBytes = hexToBytes(modulusHex);
  final exponentBytes = hexToBytes(exponentHex);

  // Combine modulus and exponent bytes
  final keyBytes = Uint8List.fromList(modulusBytes + exponentBytes);

  // Base64 encode the combined key bytes
  final keyBase64 = base64.encode(keyBytes);

  // Return the PEM formatted key (split into 64 character lines)
  return '''-----BEGIN PUBLIC KEY-----\n${_chunkString(keyBase64)}\n-----END PUBLIC KEY-----''';
}

// Helper function to convert a hexadecimal string to bytes
Uint8List hexToBytes(String hex) {
  final length = hex.length;
  final bytes = Uint8List(length ~/ 2);
  for (var i = 0; i < length; i += 2) {
    bytes[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
  }
  return bytes;
}

