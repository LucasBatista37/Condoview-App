import 'dart:async';
import 'dart:convert';
import 'package:condoview/models/chat_message.dart';
import 'package:condoview/services/secure_storege_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatProvider with ChangeNotifier {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.1.3:5000';

  List<ChatMessage> _messages = [];
  final StreamController<List<ChatMessage>> _messagesStreamController =
      StreamController<List<ChatMessage>>.broadcast();
  Timer? _pollingTimer;

  final SecureStorageService _secureStorageService = SecureStorageService();

  List<ChatMessage> get messages => _messages;
  Stream<List<ChatMessage>> get messagesStream =>
      _messagesStreamController.stream;

  Future<void> fetchMessages() async {
    try {
      final token = await _secureStorageService.loadToken();
      if (token == null) {
        throw Exception(
            "Token não encontrado. O usuário não está autenticado.");
      }

      final url = Uri.parse('$_baseUrl/api/users/admin/chat');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _messages = data.map((json) => ChatMessage.fromJson(json)).toList();

        _messagesStreamController.add(_messages);
        notifyListeners();
      } else {
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
    String userId,
    String userName,
  ) async {
    if (message.isEmpty &&
        (imagePath == null || imagePath.isEmpty) &&
        (filePath == null || filePath.isEmpty)) {
      throw Exception('Mensagem, imagem ou arquivo são obrigatórios.');
    }

    final url = Uri.parse('$_baseUrl/api/users/chat');

    try {
      final token = await _secureStorageService.loadToken();
      if (token == null) {
        throw Exception(
            "Token não encontrado. O usuário não está autenticado.");
      }

      var request = http.MultipartRequest('POST', url);

      request.fields['message'] = message;
      request.fields['userId'] = userId;
      request.fields['userName'] = userName;

      request.headers['Authorization'] = 'Bearer $token';

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imagePath,
        ));
      }

      if (filePath != null && filePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          filePath,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        final respStr = await response.stream.bytesToString();
        final jsonResponse = json.decode(respStr);
        final newMessage = ChatMessage.fromJson(jsonResponse);

        _messages.add(newMessage);
        _messagesStreamController.add(_messages);
        notifyListeners();
      } else {
        throw Exception('Erro ao enviar mensagem: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erro ao enviar mensagem: $error');
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messagesStreamController.close();
    super.dispose();
  }
}