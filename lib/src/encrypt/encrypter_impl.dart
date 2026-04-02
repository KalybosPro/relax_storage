import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:relax_storage/src/encrypt/encrypt.dart';

class Encrypter implements IEncrypter {
  final String salt;

  Encrypter({this.salt = 'encryption_default_salt'});

  @override
  enc.Key deriveKey(String key, {String? customSalt}) {
    final combined = key + (customSalt ?? salt);

    // Hash the combined string using SHA-256
    final keyHash = sha256.convert(utf8.encode(combined)).bytes;

    // Convert hash bytes to Uint8List and create enc.Key object
    return enc.Key(Uint8List.fromList(keyHash));
  }

  @override
  String encrypt<T>(T data, String key) {
    // Convert input data to String format
    String text;
    if (data is String) {
      text = data;
    } else {
      text = data.toString();
    }

    // Derive encryption key using SHA-256 with salt
    final newKey = deriveKey(key);

    // Generate unique random IV for this encryption (16 bytes = 128 bits)
    // This prevents pattern analysis and ensures each encryption is unique
    final iv = enc.IV.fromSecureRandom(16);

    // Create AES-CBC encrypter with derived key
    final encrypter = enc.Encrypter(enc.AES(newKey, mode: enc.AESMode.cbc));

    // Encrypt the text using the random IV
    final encrypted = encrypter.encrypt(text, iv: iv);

    // Combine IV and encrypted data in Base64 format for storage
    // Format: "IV_BASE64:ENCRYPTED_DATA_BASE64"
    return '${iv.base64}:${encrypted.base64}';
  }

  @override
  String decrypt(String payload, String key) {
    // Validate payload format (must contain exactly one colon)
    final parts = payload.split(':');
    if (parts.length != 2) {
      throw ArgumentError('Invalid encrypted payload format');
    }

    // Extract and decode IV from first part of payload
    final iv = enc.IV.fromBase64(parts[0]);

    // Extract and decode encrypted data from second part of payload
    final encrypted = enc.Encrypted.fromBase64(parts[1]);

    // Derive the same key used for encryption
    final newKey = deriveKey(key);

    // Create AES-CBC decrypter with derived key
    final encrypter = enc.Encrypter(enc.AES(newKey, mode: enc.AESMode.cbc));

    // Decrypt the data using the IV and derived key
    return encrypter.decrypt(encrypted, iv: iv);
  }
}
