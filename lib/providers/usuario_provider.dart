import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:condoview/services/secure_storege_service.dart';
import 'package:condoview/models/usuario_model.dart';

class UsuarioProvider with ChangeNotifier {
  final String _baseUrl = 'https://backend-condoview.onrender.com';

  String _userName = '';
  String _userProfileImage = '';
  Usuario? _usuario;
  String? _token;

  final SecureStorageService _secureStorageService = SecureStorageService();

  String get userName => _userName;
  String get userProfileImage => _userProfileImage;
  Usuario? get usuario => _usuario;
  String? get token => _token;
  String get userId => _usuario?.id ?? '';
  String get currentName => _usuario?.nome ?? 'Usuário';

  UsuarioProvider() {
    _loadTokenFromSecureStorage();
  }

  Future<void> _loadTokenFromSecureStorage() async {
    _token = await _secureStorageService.loadToken();
    if (_token != null) {
      await getCurrentUser();
    }
  }

  Future<void> _saveTokenToSecureStorage(String token) async {
    await _secureStorageService.saveToken(token);
  }

  Future<void> _removeTokenFromSecureStorage() async {
    await _secureStorageService.deleteToken();
    _token = null;
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Future<void> createUser(String nome, String email, String senha,
      {String role = 'morador'}) async {
    final url = Uri.parse('$_baseUrl/api/users/register');
    final body = jsonEncode({
      'nome': nome,
      'email': email,
      'senha': senha,
      'role': role,
    });

    try {
      final response = await http.post(url, headers: _getHeaders(), body: body);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        await _saveTokenToSecureStorage(_token!);
        await getCurrentUser();
        notifyListeners();
      } else {
        throw Exception('Erro ao criar conta: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao criar conta: $e');
    }
  }

  Future<void> login(String email, String senha) async {
    final url = Uri.parse('$_baseUrl/api/users/login');
    final body = jsonEncode({'email': email, 'senha': senha});

    try {
      final response = await http.post(url, headers: _getHeaders(), body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        await _saveTokenToSecureStorage(_token!);
        await getCurrentUser();
        notifyListeners();
      } else {
        throw Exception('Erro ao autenticar: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao autenticar: $e');
    }
  }

  Future<void> getCurrentUser() async {
    if (_token == null) {
      throw Exception('Usuário não autenticado.');
    }

    final url = Uri.parse('$_baseUrl/api/users/profile');

    try {
      final response = await http.get(url, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _usuario = Usuario.fromJson(data);
        _userName = _usuario!.nome;

        if (_usuario!.profileImageUrl?.isNotEmpty ?? false) {
          _userProfileImage =
              '$_baseUrl/uploads/users/${_usuario!.profileImageUrl}';
        } else {
          _userProfileImage = '';
        }
        notifyListeners();
      } else {
        throw Exception('Erro ao obter dados do usuário: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao obter dados do usuário: $e');
    }
  }

  Future<void> update({
    String? nome,
    String? senha,
    String? telefone,
    String? profileImage,
  }) async {
    if (_usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    final url = Uri.parse('$_baseUrl/api/users/update');
    final request = http.MultipartRequest('PUT', url);

    request.headers['Authorization'] = 'Bearer $_token';

    if (nome != null) request.fields['nome'] = nome;
    if (senha != null) request.fields['senha'] = senha;
    if (telefone != null) request.fields['telefone'] = telefone;
    if (profileImage != null) {
      request.files
          .add(await http.MultipartFile.fromPath('profileImage', profileImage));
    }

    try {
      final response = await request.send();
      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar usuário.');
      }
      await getCurrentUser();
    } catch (e) {
      throw Exception('Erro ao atualizar usuário: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    final url = Uri.parse('$_baseUrl/api/users/admin/$id');

    try {
      final response = await http.delete(url, headers: _getHeaders());
      if (response.statusCode != 200) {
        throw Exception('Erro ao excluir o usuário: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao excluir o usuário: $e');
    }
  }

  Future<List<Usuario>> getAllUsers() async {
    final url = Uri.parse('$_baseUrl/api/users/admin/all');

    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Usuario.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar todos os usuários: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar todos os usuários: $e');
    }
  }

  Future<Usuario?> getUserById(String id) async {
    final url = Uri.parse('$_baseUrl/api/users/$id');

    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Usuario.fromJson(data);
      } else {
        throw Exception('Erro ao buscar usuário: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }
}
