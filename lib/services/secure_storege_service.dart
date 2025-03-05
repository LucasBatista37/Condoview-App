import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'authToken', value: token);
    print('Token salvo com segurança.');
  }

  Future<String?> loadToken() async {
    final token = await _secureStorage.read(key: 'authToken');
    print('Token carregado com segurança: $token');
    return token;
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'authToken');
    print('Token removido com segurança.');
  }
}
