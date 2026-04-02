import 'dart:convert';

import 'package:get_storage/get_storage.dart';

import '../encrypt/encrypt.dart';
import 'storage.dart';

class RelaxStorage implements IRelaxStorage {
  factory RelaxStorage([String? encryptionKey]) =>
      RelaxStorage._internal(encryptionKey);

  late GetStorage _box;
  late String _encryptionKey;

  final IEncrypter encrypt = Encrypter();

  RelaxStorage._internal([String? encryptionKey]) {
    _box = GetStorage();
    _encryptionKey = encryptionKey ?? 'encryption_default_salt';
  }

  static Future<bool> init([String? encryptionKey]) => GetStorage.init();

  @override
  Future<void> clear() => _box.erase();

  @override
  Future<void> delete(String key) => _box.remove(key);

  @override
  T? read<T>(String key) {
    // Retrieve encrypted data from storage
    final encrypted = _box.read(key);
    if (encrypted == null) return null;

    // Decrypt the data using AES-CBC
    final decrypted = encrypt.decrypt(encrypted, _encryptionKey);
    
    // Parse JSON string back to Map
    final map = jsonDecode(decrypted);

    // Extract the stored value
    final value = map['value'];

    // Perform type conversion based on requested type T
    if (T == String) return (value?.toString() ?? '') as T;
    if (T == int) return (value is num ? value.toInt() : int.tryParse(value.toString()) ?? 0) as T;
    if (T == double) return (value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 0.0) as T;
    if (T == bool) return (value is bool ? value : value.toString() == 'true') as T;

    // For other types (custom objects, lists, etc.), direct casting
    return value as T;
  }

  @override
  Future<void> save<T>(String key, T data) async {
    // Create payload with type information and data
    final payload = {'type': T.toString(), 'value': data};

    // Serialize payload to JSON string
    final encrypted = encrypt.encrypt(jsonEncode(payload), _encryptionKey);

    // Store encrypted data in GetStorage
    return await _box.write(key, encrypted);
  }
}
