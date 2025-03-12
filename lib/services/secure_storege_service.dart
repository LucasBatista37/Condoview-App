import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'authToken', value: token);
  }

  Future<String?> loadToken() async {
    final token = await _secureStorage.read(key: 'authToken');
    return token;
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'authToken');
  }
}
