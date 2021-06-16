import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageObject{
  static FlutterSecureStorage _storage = new FlutterSecureStorage();
  static Future<void> setObject(String key, String val) async => await _storage.write(key: key, value: val);
  static Future<String> getObject(String key) async => await _storage.read(key: key);
}