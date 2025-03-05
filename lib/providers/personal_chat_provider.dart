import 'dart:convert';
import 'package:condoview/models/personal_chat_message_model.dart';
import 'package:condoview/services/secure_storege_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PersonalChatProvider with ChangeNotifier {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.1.3:5000';

  List<PersonalChatMessageModel> _messages = [];
  final SecureStorageService _secureStorageService = SecureStorageService();

  List<PersonalChatMessageModel> get messages => _messages;

  Future<void> fetchMessages(String userId, String currentUserId) async {
    try {
      final token = await _secureStorageService.loadToken();
      if (token == null) {
        throw Exception(
            "Token não encontrado. O usuário não está autenticado.");
      }

      final url = Uri.parse('$_baseUrl/api/users/personal-chat/$userId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("Log: Dados decodificados: $data");

        _messages = data
            .map((json) =>
                PersonalChatMessageModel.fromJson(json, currentUserId))
            .cast<PersonalChatMessageModel>()
            .toList();

        notifyListeners();
      } else {
        print(
            "Log: Erro ao carregar mensagens. Status Code: ${response.statusCode}");
        throw Exception('Erro ao carregar mensagens');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> sendMessage(
    String message,
    String? imagePath,
    String? filePath,
    String receiverId,
    String userName,
    String currentUserId,
  ) async {
    final url = Uri.parse('$_baseUrl/api/users/personal-chat');

    try {
      final token = await _secureStorageService.loadToken();
      if (token == null) {
        throw Exception(
            "Token não encontrado. O usuário não está autenticado.");
      }

      var request = http.MultipartRequest('POST', url);
      request.fields['message'] = message;
      request.fields['receiver'] = receiverId;
      request.fields['userName'] = userName;

      request.headers['Authorization'] = 'Bearer $token';

      if (imagePath != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', imagePath));
      }

      if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        final respStr = await response.stream.bytesToString();
        final jsonResponse = json.decode(respStr);

        final newMessage =
            PersonalChatMessageModel.fromJson(jsonResponse, currentUserId);

        _messages.add(newMessage);
        notifyListeners();
      } else {
        throw Exception('Erro ao enviar mensagem: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erro ao enviar mensagem: $error');
    }
  }
}
