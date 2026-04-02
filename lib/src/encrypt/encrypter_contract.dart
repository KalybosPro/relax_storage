import 'package:encrypt/encrypt.dart' as enc;

abstract class IEncrypter{
  enc.Key deriveKey(String key, {String? customSalt});

  String encrypt<T>(T data, String key);

  String decrypt(String encryptedText, String key);
}
