part of kyber;

class Kyber {
  Kyber.k512() : _level = KyberLevel.k512;
  Kyber.k768() : _level = KyberLevel.k768;
  Kyber.k1024() : _level = KyberLevel.k1024;

  final KyberLevel _level;
  KyberLevel get level => _level;

  KyberGenerationResult generateKeys() {
    // IND-CPA keypair generation
    var keysINDCPA = INDCPA.generateKeys(level);

    var pk = keysINDCPA[0];
    var sk = keysINDCPA[1];

    // FO transform to make IND-CCA2
    var buffer1 = Uint8List.fromList(pk);
    var hash1 = sha3.SHA3(256, sha3.SHA3_PADDING, 256);
    hash1.update(buffer1);
    var pkh = hash1.digest();

    // Generate 32 random bytes
    var rnd = List<int>.filled(32, 0);
    for (int i = 0; i < 32; i++) {
      rnd[i] = KyberFunctions.nextInt(256);
    }

    // Concatenate pk, pkh, and rnd to sk
    sk.addAll(pk);
    sk.addAll(pkh);
    sk.addAll(rnd);

    return KyberGenerationResult(
      public: KyberDigest(pk),
      private: KyberDigest(sk),
    );
  }

  KyberEncryptionResult encrypt(List<int> pk, String message) {
    // Convert the message to bytes and ensure it's 32 bytes long
    List<int> m = utf8.encode(message); // explicitly List<int>
    if (m.length > 32) {
      m = m.sublist(0, 32); // truncate if too long
    } else if (m.length < 32) {
      m = List<int>.from(m)..addAll(List.filled(32 - m.length, 0)); // pad if too short
    }

    // Hash m with SHA3-256
    var buffer1 = Uint8List.fromList(m);
    var hash1 = sha3.SHA3(256, sha3.SHA3_PADDING, 256);
    hash1.update(buffer1);
    var mh = hash1.digest();

    // Hash pk with SHA3-256
    var buffer2 = Uint8List.fromList(pk);
    var hash2 = sha3.SHA3(256, sha3.SHA3_PADDING, 256);
    hash2.update(buffer2);
    var pkh = hash2.digest();

    // Hash mh and pkh with SHA3-512
    var buffer3 = Uint8List.fromList(mh);
    var buffer4 = Uint8List.fromList(pkh);
    var hash3 = sha3.SHA3(512, sha3.SHA3_PADDING, 512);
    hash3.update(buffer3).update(buffer4);
    var kr = hash3.digest();
    var kr1 = kr.sublist(0, 32);
    var kr2 = kr.sublist(32, 64);

    // Generate ciphertext with IND-CPA encryption
    var cipherText = INDCPA.encrypt(level, pk, mh, kr2);

    // Hash ciphertext with SHA3-256
    var buffer5 = Uint8List.fromList(cipherText);
    var hash4 = sha3.SHA3(256, sha3.SHA3_PADDING, 256);
    hash4.update(buffer5);
    var ch = hash4.digest();

    // Hash kr1 and ch with SHAKE-256
    var buffer6 = Uint8List.fromList(kr1);
    var buffer7 = Uint8List.fromList(ch);
    var hash5 = sha3.SHA3(256, sha3.SHAKE_PADDING, 256);
    hash5.update(buffer6).update(buffer7);
    var ss = hash5.digest();

    return KyberEncryptionResult(
      cipherText: KyberDigest(cipherText),
      sharedSecret: KyberDigest(ss),
    );
  }

  KyberDigest decrypt(List<int> cipherText, List<int> privateKey) {
    // Define indices based on Kyber level
    var end1 = (level == KyberLevel.k1024) ? 1536 : (level == KyberLevel.k768) ? 1152 : 768;
    var end2 = (level == KyberLevel.k1024) ? 3104 : (level == KyberLevel.k768) ? 2336 : 1568;
    var end3 = (level == KyberLevel.k1024) ? 3136 : (level == KyberLevel.k768) ? 2368 : 1600;
    var end4 = (level == KyberLevel.k1024) ? 3168 : (level == KyberLevel.k768) ? 2400 : 1632;

    // Extract sk, pk, pkh, and z from the private key
    var sk = privateKey.sublist(0, end1);
    var pk = privateKey.sublist(end1, end2);
    var pkh = privateKey.sublist(end2, end3);
    var z = privateKey.sublist(end3, end4);

    // IND-CPA decrypt
    var m = INDCPA.decrypt(level, cipherText, sk);

    // Hash m and pkh with SHA3-512
    var buffer1 = Uint8List.fromList(m);
    var buffer2 = Uint8List.fromList(pkh);
    var hash1 = sha3.SHA3(512, sha3.SHA3_PADDING, 512);
    hash1.update(buffer1).update(buffer2);
    var kr = hash1.digest();
    var kr1 = kr.sublist(0, 32);
    var kr2 = kr.sublist(32, 64);

    // IND-CPA encrypt
    var cmp = INDCPA.encrypt(level, pk, m, kr2);

    // Compare c and cmp
    var fail = KyberFunctions.compareArray(cipherText, cmp);

    // Hash c with SHA3-256
    var buffer3 = Uint8List.fromList(cipherText);
    var hash2 = sha3.SHA3(256, sha3.SHA3_PADDING, 256);
    hash2.update(buffer3);
    var ch = hash2.digest();
    var ss = <int>[];

    if (fail) {
      // Hash kr1 and ch with SHAKE-256
      var buffer4 = Uint8List.fromList(kr1);
      var buffer5 = Uint8List.fromList(ch);
      var hash3 = sha3.SHA3(256, sha3.SHAKE_PADDING, 256);
      hash3.update(buffer4).update(buffer5);
      ss = hash3.digest();
    } else {
      // Hash z and ch with SHAKE-256
      var buffer6 = Uint8List.fromList(z);
      var buffer7 = Uint8List.fromList(ch);
      var hash4 = sha3.SHA3(256, sha3.SHAKE_PADDING, 256);
      hash4.update(buffer6).update(buffer7);
      ss = hash4.digest();
    }

    return KyberDigest(ss);
  }
}
