import 'dart:convert';
import 'dart:typed_data';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart';
import 'package:asn1lib/asn1lib.dart'; // for encoding to ASN.1 (PEM format)

void main() {
  // Generate RSA key pair
  var publicKeyPemBase = "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUFuaTVFK0dWTjA5Y0YrSC9pUEV0dApycENCVnFjK0JveXNJMmhyQVRYNVlrbXRYYnQ3UXpsVXR2UHF1OUpGK3Q4UGlsNWFLVGFXTzdRL2kvb0tjRS9WCmR0enA4cjdpQSs0N01xdURLTjBKT3NTYldyNlRhU0Y5NkRJdVJBaXlDQkhTZ1o2RGF4M1VUSlUzWWNyaWRlQnoKUXcweGJudEV5dmhGVDdSYkx2aXcxWXhZK3lMU2dHUnBUZDlHYXRnZUxMdTA4WlR5cXFOVVdTSXZNZEROTjBGMwpCZE1neVpuZTVyZ3gwZ0tIL01LRHlqQXFuQ3A4QnZWYmRMNjN2NExKNDBEeW8zelNBVnJrU2V1VFVZTnJDMjBvClNhdzNEc2ErT0FZWUllUXZUOHRETTRpaHlGbVVoWDFTRnR1ejJlRHoxMGV3NERveTdBSk15UzdkM2FSNzB6SDIKcXdJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t";
  var privateKeyPemBase = "LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2UUlCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktjd2dnU2pBZ0VBQW9JQkFRQ0VXZkw1VGxRTFcxUXkKcWoxNUc4cFpSTHJTYnpYVENXS3lDaXZZZGFrR0RkVUR3a0JOL2ZVUHJHT1NLNU1jNXFteFZxSEJ4bDBsUFlqdApqTmRJT0tCK1BkVTdDRE9RNDlTeWRuTis4Mkt2eUFwVHNyb2VrTTBFZ1kzVmliWlo2VUp6cFN6YzNUZFpkbnljCm41c3prR3hHOG1KVUJTSFMxTWJKUVE3SVJHL0l6Sko0U0dGUGxxcFU0c2hVcnVrZWdaRXl4eW9YQk10TjBWMGQKVGVoNHM3bzhhWUF0MHRjWmlRTmtIK3J0b1NTUFZwUGZYclN3NG11SGE0NEs5cEtWeXp3eXk5RjdwY05ES0k5UgpoV1d2ckFJcS94cXk3cWptZ0F6NERRK0dyMnhNNzFjMGdQSnpzVmtTdWdaRWMxaE15UHRqRGNaclI1OVJSTkVoCjluSmRHeTdqQWdNQkFBRUNnZ0VBVU1raTBXQXBWc0ZKZEorTFpGZzlQQjRDdHg0Z3lZOHFDaWpCT0tBaEtzdlkKb1RHNTFLRldLMW43Y1NaZDVyODVCMEVzL1QyYWIzZlBFOGpyUTI4bEw4bUlWVDhkVXF4dWtQeFNaVVFra2MxVgoyRjc0MGwxcWR2eXBXWlYwbEE4WWU4UnZ6T1RPdXpIaXdDdUFMWXBUUFQ4SUcrY0NEVkhKZ09EUUtCZjE3NmRnCjhsVlp1MGxXbEFoSGh0UTNOU2Q2WkVqa0I0aDZHSk1WUEx5cWJmNGV5REJpNE94ZG1BREpNVS9uSlVrK1J4RDYKaXZOMmVFaTJqZWpaMTVZUGhiT3d2U1JnTDZpQnNCUWp2SC8rM1VQZGZKSUFQZXdDbHgzMFNqcmdxQ0orSklFeQp0K0wxYVplVDRDL3F6RUpQWUh3NndwdGVicUIvNjVEa0t6eVdDdkFRMlFLQmdRRGxlR29pUnJSa2FrNGhkYUZWCnRBaG91cHlIR0k1YUgwMEZNU2FMSFhFSVpZT3o0S1hncmkxWjhJVG56VHlxVVNDc1pGanVLc3FlN0dhUGdEOUcKWmhSMGJWRlB3WG4zOXJ5UUZacDR2cUNGb2d1QWxOUUp4dUlFbkQ5K1ZLM2cyekgvMDZzd3BmWG0zbG5WdWlhQQp1VkpnZ0xJR2F1M0lpNDdqUFdNRUhKVkNQd0tCZ1FDVHB4L0ZQMjB4MjV6MGNHNjlVVTVVT1hTeVFyS1B3OEpQCnF4SSt4TnNCTkUzUXYwVm55bmpBdlNLbzc5ZmV1NUd4N2dqaUNYWU5hbmhjSzZIdmNJMTBzYU9vOHgyditBVUsKNzBkYm5wN3JrZndNODNtbEQ3cnZ5aWUrV0FmeFJGOEpYSFcwYVkzZlJFZWx4WnczdVVZdzZtVTI4d1BIOXFFNgpnQzZLV3ZwaVhRS0JnUURKZ0ZUS3BvWFB5NTJ5T2dZaktRVmRXY2tMeEo5ME9obzdIZTczcURIU3FybmRJYjduCnJtdDZsLzlOUWVjc3RETFp6d0JjbTh6emd5bUloNWlJckNqNEYrcVgrNUNzRXNtQVNNZ3RrVStLS1VLcWRZWkEKMDVremJUVkFMUUhHK3hSTHpzWjc0TEF2UEQ5c3M1c04zQzZmT1VPYTZSakd5dTM5VTdGNE1kVkxwd0tCZ0FUNwp5eEs1UlZJOWUxcTB3TWdiQ20zRlVxOEJtVTFJNmpJT01CdDJRWDRVNmR0MTJUM2JrNS9Od25HNVJxdjU0TDBFCnI4QVJXYTZ5UFVXL0kwUVZwSENmM2twQmltcjZFQkdDYWdJcHBHdUhEZDdTQ1BVTlJ0MzVFTVpYNmt5MlpnN0cKMUNJMnZkY2ZVdHZCZzdoTnhKUzZGSmg2TTFKNGZKQ2c2dkU0aU9MeEFvR0FTbUZuN0RYd1dyL3JCZlBOdmxBNwpBNHd6ZGtMTEVNb3gxZXl4S1o4ZlZKRDVVTTRmWDJQaW1BUlFUM0lzT1NsRHJ5RkVuVW40NlREcmZSRnd1NEJyCmtlTy9yRjJxMVpzMXNCV1hVK1YyWjlzejI2QlZOa0hVU0NrUU45MUdsL1E4enlHWER6d2VoU1lrNExMdTFHNzcKN0RadlVabFpHRkxkUEpsTDFsekQxYTg9Ci0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0=";
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
  final decryptedMessage = rsaDecrypt(privateKey, "YX28hE+AeZZxTUvd3qZbXuc9xk3NKCbypuLQQ1Luvc4+3GE14um7P4S+JaGm5I7Net9L2ETiAp/gIGfKnhthiZ4yVxaTvGH39FMHDnqBgr+vczNDftmZqZjasEWZqsP7rKYE4o+uljX1dM1bM685L94/fqwahR7F2QuBs/cXom7flIJqlfolvWHT6HC9ywYq93nXPemopff+EfdL9i/ey0URrRCBxaysLz8rTm6E3CzFJrg53FFVGQhrayrvbbJKQYntB7ZUws4CZYMRAs+ERYnK4AJj+54wBrM21G+D+f83yVi0s3JvCcZlqo0R7AemTQmHI/RbLXUOuvk3QUNOJw==");
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
