import 'dart:convert';
import 'dart:typed_data';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart';
import 'package:asn1lib/asn1lib.dart'; // for encoding to ASN.1 (PEM format)

void main() {
  // Generate RSA key pair
  var publicKeyPemBase = "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUFuaTVFK0dWTjA5Y0YrSC9pUEV0dApycENCVnFjK0JveXNJMmhyQVRYNVlrbXRYYnQ3UXpsVXR2UHF1OUpGK3Q4UGlsNWFLVGFXTzdRL2kvb0tjRS9WCmR0enA4cjdpQSs0N01xdURLTjBKT3NTYldyNlRhU0Y5NkRJdVJBaXlDQkhTZ1o2RGF4M1VUSlUzWWNyaWRlQnoKUXcweGJudEV5dmhGVDdSYkx2aXcxWXhZK3lMU2dHUnBUZDlHYXRnZUxMdTA4WlR5cXFOVVdTSXZNZEROTjBGMwpCZE1neVpuZTVyZ3gwZ0tIL01LRHlqQXFuQ3A4QnZWYmRMNjN2NExKNDBEeW8zelNBVnJrU2V1VFVZTnJDMjBvClNhdzNEc2ErT0FZWUllUXZUOHRETTRpaHlGbVVoWDFTRnR1ejJlRHoxMGV3NERveTdBSk15UzdkM2FSNzB6SDIKcXdJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t";
  var privateKeyPemBase = "LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2UUlCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktjd2dnU2pBZ0VBQW9JQkFRQ1FMaGVrSkF6YkJ4aUIKMUt1TW44ZzR0Z1pWVm94eXV3NkpjWmx1V0hBYXgxWGh5N0o1bGJ1WURpUkFDMXFiM1lyZllqWEF0dWVhTGR2awp6a0luQmRCSEhYMUFvZjdtU1FlMEtrS01BVWFVZ2g4RFd5elRBUWV1QWdscGw4Q2FOaFY3ZmlKZ0R0N0pTSUZ5Cjk3VU0zRVZIcFVpaGsyN2hydHRvT1NyQVFRTzB6ekhaSHB5TzFwV1pDSzhsMmNOV0hHM2ZQUGYrVTM1UzhxL2gKa09mdmNsdkliMGlQb1JOWDd2MnJHWFVGWVBldmZpc3RENTE5aHQvNVVFVW5BdVE4RDEzQ0dOMUpjVVR0TnhvbQowclRSTTVaWjQ5SE1CdW5TeGRpRTkvUTkzREVnUFZmcTZxNUZmcTJubmt5U0VmWGNjWnNJaGtjblhjQUxHU1JoCnZHdlZ0eThEQWdNQkFBRUNnZ0VCQUlIT3ZjSXVJdFRmb3BUaFlFSVBhVGlGeVZYendpZFplbEVNVWRNakZHdEgKcEc3UjhqRzlPVlJCQnlvU0R0WGR0RFpDT1pyMEViaWlLU1BxLzJ3YXM5WVRHcjJpRzloQlVBcEpNZmpTL1RTZgpva1JuUmdnREdXTDB1bnl5LzlqWGNLZnFmQkIzMHVUdHZuNC92bVdCdTI0eHhSNlRtblRkOVBQMDVDU0xaRWJZCkZ2UFpxSDZnY0h2dXQvaTIybXY0R2lMZ0h2MnpCaWJxYjQva3dsTlcvWFBsYUVGOVdnY2RFS3JjcjlJOXdyNlIKZjJiV005NHkzZFJndTlWVzlYdEZIdXJsRnhCUVZkMnQxdVRTaE84Nkl3QkRsVFg3UDNhb0hFNmZNejVRNlJvNApGYTYzRXorMkpZdDFKSzhNM3hqZ1ozOFdGMDVycjhpYkdTWXVFOXdyaGNFQ2dZRUEzUW1ZQmlDRXA1c2l3SXJQCk5hWjhmaHoySHZINC9UNXREbzk2amZDMWQ4RzBiWmRsSUw4RHR0dFVaM0FXT2c3RGgvbmp2MlNDaWtKMWtVc0oKQldNLzlsU3VnRFU2dzNQeVVMSXVaVGk0NjdKTkl1T0E3VktkbU1WRG5zbk1PV3p0dzF1anhCamlZZy8wY3cvSwpxY3FidWtwSEhDZTBiK3M5WXlRMXJxUENCOHNDZ1lFQXB2eFZRNCtNNHpyd05Od3lNZ3BwOUVJYUlrY0ZibzNoCm1ZQTdja1loTGpBZ1BiMklqYnEvVmRkVW5nZ05WZGhRdG44Mmd2dkhsOUppbTFQNDJnZXNrRU5ZOXpOUXM3VDgKMlZkT1lVRlQzbnVlS0IvZG54K3ZHWmRiVkowZmdLcitKdmczeWt5QXBNbjJsMzJXQWszcmR6R1l6KytoUktiVQp5YmlrOGQvYTNxa0NnWUJmOFkwaWc3VHhCNTdURXEyVXJScDJwMTJSMnhobjNGUDhNUDFTWlR4dnFnNEdUK1BlCmplc3YwUTVYQThreUZEeDlabE9jUFNXSW5BWnFOYmJKdHVZSnA0SkRObGUyaFRxV0duR1hFRUw4VTkyMW1paloKV3JYN25ReVgvU0gvZnkvSlQ1ckxRTDNyTU4rN25nd3JIVDN4WTlKdi96QU1NSURwNnNxK2JtaUhkd0tCZ0NHSgpSKzU3cEFYMnprc3ZkZjFLemlDNkxkbDRmZ1RJQmVqNE1mZ3ZVWGFmUDdwbW1FZ3VtMEs0TGt4V3ZhYmgvTVBLCkpMNkZwbjQ5U0lSOWh0cnk4NXM5aTE2S05ja0JyazVRRkhPLzFRSTN2WG05ZkpyNm1BWUJ1ZHZ5ZW1NeTlEd0wKV2RrTktFRHdOdEFSN3RDanFZaVVzMlgvY0ZvRFQzVDcybFNoYXFtUkFvR0FBVU5NR0tGckhHYm5DYlU3cHJMdApFcUQ5TDlBL1N6N3RFL28xZ3VCRk84akRFMUE4b2hVU2RheGgwdzNLdGcrL3d5WGF2aUozNkx5TENDcjJvRTNtCi9yMjkzNkdGNDFuWEIvcWNDNHJzT3poY2NFZFI3TytmWmIwN3FiNWM0TDhFczkxSkFWU0NwMTNLdGI3YkdYOWYKcjdaQ3FXN0RaeHVaMUUvdTBwZDRsaU09Ci0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0";
  //
  // List<int> decodedint = base64.decode(publicKeyPemBase);
  // var publicKeyPem = utf8.decode(decodedint);
  //
  // List<int> decodedint2 = base64.decode(privateKeyPemBase);
  // var privateKeyPem = utf8.decode(decodedint2);
  //
  //
  // RSAPublicKey publicKey = CryptoUtils.rsaPublicKeyFromPem(publicKeyPem);
  // RSAPrivateKey privateKey = CryptoUtils.rsaPrivateKeyFromPem(privateKeyPem);
  //
  // final encryptedMessage = rsaEncrypt(publicKey, "Test");
  // print("Encrypted Message: $encryptedMessage");
  //
  // final decryptedMessage = rsaDecrypt(privateKey, encryptedMessage);
  // print("Decrypted Message: $decryptedMessage");

  List<int> decodedint = base64.decode(privateKeyPemBase);
  var privatekey = utf8.decode(decodedint);
  RSAPrivateKey privateKey = CryptoUtils.rsaPrivateKeyFromPem(privatekey);
  final decryptedMessage = rsaDecrypt(privateKey, "RKNiX+s5SUitee4o0vk79SSb0qci7IzNJ6/MTpCO4a2dTAoT7qboJv/84psXi0jGD2XaNGBWrz6Mzwbk0M2IB/4HOWieGnF9sxr71glTXSl2IKxxq8eICQ+t8OpFu8z7pnItxkoXsOw6yh92U33D1Jj0fZ8XS2N/PQpygijoZ3ecvFuyPW2qQLhQT+ev4wcyFAlwkdRAprFhfoRxNbFjpGRE+OW6112odZqj0IZ0MEcbTUefayQUTn2sySN7+rHgVRM+WTYyf/qz4/DKgTeejMfRrxqm2rfFI8+bRC5Y3G2aQtVdVZjZ639TuUonO3zUCnSYrikV/3n28csUAcSr4w==");
  print("Decrypted Message: $decryptedMessage");

}

// Function to encrypt data using RSA public key
String rsaEncrypt(RSAPublicKey publicKey, String plaintext) {
  final encrypter = RSAEngine();
  final params = PublicKeyParameter<RSAPublicKey>(publicKey);
  encrypter.init(true, params);

  final input = Uint8List.fromList(utf8.encode(plaintext));
  final encrypted = encrypter.process(input);
  return base64.encode(encrypted);
}

// Function to decrypt data using RSA private key
String rsaDecrypt(RSAPrivateKey privateKey, String encryptedBase64) {
  final decrypter = RSAEngine();
  final params = PrivateKeyParameter<RSAPrivateKey>(privateKey);
  decrypter.init(false, params);

  final encrypted = base64.decode(encryptedBase64);
  final decrypted = decrypter.process(Uint8List.fromList(encrypted));
  return utf8.decode(decrypted);
}
