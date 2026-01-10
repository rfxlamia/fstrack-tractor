import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _encryptionKeyName = 'hive_encryption_key';
  static const String _authBoxName = 'auth';
  static const String _weatherCacheBoxName = 'weather_cache';

  static late Box _authBox;
  static late Box _weatherCacheBox;

  static Box get authBox => _authBox;
  static Box get weatherCacheBox => _weatherCacheBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();

    final encryptionKey = await _getOrCreateEncryptionKey();

    _authBox = await Hive.openBox(
      _authBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    _weatherCacheBox = await Hive.openBox(_weatherCacheBoxName);

    assert(_authBox.isOpen, 'Auth box failed to open');
    assert(_weatherCacheBox.isOpen, 'Weather cache box failed to open');
  }

  static Future<List<int>> _getOrCreateEncryptionKey() async {
    const secureStorage = FlutterSecureStorage();

    String? encodedKey = await secureStorage.read(key: _encryptionKeyName);

    if (encodedKey == null) {
      final key = Hive.generateSecureKey();
      encodedKey = base64UrlEncode(key);
      await secureStorage.write(key: _encryptionKeyName, value: encodedKey);
    }

    return base64Url.decode(encodedKey);
  }

  static Future<void> clearAll() async {
    await _authBox.clear();
    await _weatherCacheBox.clear();
  }
}
