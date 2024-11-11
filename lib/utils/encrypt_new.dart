import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:SecureTalk/api/apis.dart';
import 'package:SecureTalk/test.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pointycastle/export.dart';
import 'package:asn1lib/asn1lib.dart'; // for encoding to ASN.1 (PEM format)
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:SecureTalk/test.dart';
import 'package:pointycastle/export.dart';

import '../models/message.dart'; // for encoding to ASN.1 (PEM format)

class EncryptData {

  AesResult generateEncrypter(String plainText) {
    var keyPair = generateRSAKeyPair();
    var publicKey = keyPair.publicKey as RSAPublicKey;
    var privateKey = keyPair.privateKey as RSAPrivateKey;
    final encryptedMessage = rsaEncrypt(publicKey, plainText);

    // Print public key in PEM format
    List<int> mydataint =
        utf8.encode(CryptoUtils.encodeRSAPublicKeyToPem(publicKey));
    String publick = base64.encode(mydataint);

    List<int> mydataint2 =
        utf8.encode(CryptoUtils.encodeRSAPrivateKeyToPem(privateKey));
    String privatek = base64.encode(mydataint2);

    return AesResult(
        pirvate_key: privatek,
        public_key: publick,
        encrypter: encryptedMessage);
  }

  String generateEncrypterNew(String plainText, RSAPublicKey publicKey) {
    return rsaEncrypt(publicKey, plainText);
  }

  RSAPublicKey convertPublic(String publickey) {
    List<int> decodedint = base64.decode(publickey);
    var pubKey = utf8.decode(decodedint);
    RSAPublicKey privateKey = CryptoUtils.rsaPublicKeyFromPem(pubKey);
    return privateKey;
  }

  RSAPrivateKey convertPrivate(String private_key) {
    List<int> decodedint = base64.decode(private_key);
    var priKey = utf8.decode(decodedint);
    RSAPrivateKey privateKey = CryptoUtils.rsaPrivateKeyFromPem(priKey);
    return privateKey;
  }

  String decryptData(String private_key, String text) {
    // Parse the PEM format
    List<int> decodedint = base64.decode(private_key);
    var privatekey = utf8.decode(decodedint);
    RSAPrivateKey privateKey = CryptoUtils.rsaPrivateKeyFromPem(privatekey);
    final decryptedMessage = rsaDecrypt(privateKey, text);
    print("Decrypted Message: $decryptedMessage");
    return decryptedMessage;
  }

  String? decryptDataTwo(String private_key, String text, Message message) {
    // Parse the PEM format
    late String decryptedMessage;
    if (message!.fromId == APIs.user.uid) {
      APIs.getUserKeys(message.toId).then((documentSnapshot) {
        List<int> decodedint =
            base64.decode(documentSnapshot.get("temp_public_key"));
        var privatekey = utf8.decode(decodedint);
        RSAPrivateKey privateKey = CryptoUtils.rsaPrivateKeyFromPem(privatekey);
        decryptedMessage = rsaDecrypt(privateKey, text);
        print("Decrypted Message222: $decryptedMessage");
        return decryptedMessage;
      });
    } else {
      List<int> decodedint = base64.decode(private_key);
      var privatekey = utf8.decode(decodedint);
      RSAPrivateKey privateKey = CryptoUtils.rsaPrivateKeyFromPem(privatekey);
      decryptedMessage = rsaDecrypt(privateKey, text);
      print("Decrypted Message11: $decryptedMessage");
      return decryptedMessage;

    }
  }

  String decryptDataOld(String private_key, String text) {
    // Parse the PEM format
    List<int> decodedint = base64.decode(private_key);
    var privatekey = utf8.decode(decodedint);

    RSAPrivateKey privateKey = CryptoUtils.rsaPrivateKeyFromPem(privatekey);
    final decryptedMessage = rsaDecrypt(privateKey, text);
    print("Decrypted Message: $decryptedMessage");
    return decryptedMessage;
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

    var dataBase64 = base64
        .encode(ASN1Sequence.fromBytes(topLevelSeq.encodedBytes).encodedBytes);
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
    topLevelSeq.add(ASN1Integer(
        privateKey.privateExponent! % (privateKey.p! - BigInt.one)));
    topLevelSeq.add(ASN1Integer(
        privateKey.privateExponent! % (privateKey.q! - BigInt.one)));
    topLevelSeq.add(ASN1Integer(privateKey.q!.modInverse(privateKey.p!)));

    var dataBase64 = base64
        .encode(ASN1Sequence.fromBytes(topLevelSeq.encodedBytes).encodedBytes);
    return '''-----BEGIN PRIVATE KEY-----\n${_chunkString(dataBase64)}\n-----END PRIVATE KEY-----''';
  }

// Helper function to format base64 strings in PEM format (64 characters per line)
  String _chunkString(String str, {int chunkSize = 64}) {
    final regex = RegExp('.{1,$chunkSize}');
    return regex.allMatches(str).map((match) => match.group(0)).join('\n');
  }
}

// Class to hold the result
class AesResult {
  final String pirvate_key;
  final String public_key;
  final String encrypter;

  AesResult({
    required this.pirvate_key,
    required this.public_key,
    required this.encrypter,
  });
}
