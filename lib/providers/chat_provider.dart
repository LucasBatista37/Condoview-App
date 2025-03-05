import 'dart:async';
import 'dart:convert';
import 'package:condoview/models/chat_message.dart';
import 'package:condoview/services/secure_storege_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatProvider with ChangeNotifier {
  final String _baseUrl = 'https://backend-condoview.onrender.com';

  List<ChatMessage> _messages = [];
  final StreamController<List<ChatMessage>> _messagesStreamController =
      StreamController<List<ChatMessage>>.broadcast();
  Timer? _pollingTimer;

  final SecureStorageService _secureStorageService = SecureStorageService();

  List<ChatMessage> get messages => _messages;
  Stream<List<ChatMessage>> get messagesStream =>
      _messagesStreamController.stream;

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchMessages();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  Future<void> fetchMessages() async {
    try {
      final token = await _secureStorageService.loadToken();
      if (token == null) {
        throw Exception("Token não encontrado. O usuário não está autenticado.");
      }

      print("Log: Token usado para buscar mensagens: $token");

      final url = Uri.parse('$_baseUrl/api/users/admin/chat');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(
          "Log: Status Code da resposta de fetchMessages: ${response.statusCode}");
      print("Log: Corpo da resposta de fetchMessages: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _messages = data.map((json) => ChatMessage.fromJson(json)).toList();
        print("Log: Mensagens carregadas com sucesso: $_messages");

        _messagesStreamController.add(_messages);
        notifyListeners();
      } else {
        print(
            "Log: Erro ao carregar mensagens. Status Code: ${response.statusCode}");
        throw Exception('Erro ao carregar mensagens');
      }
    } catch (error) {
      print("Log: Erro ao buscar mensagens: $error");
      throw error;
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
        throw Exception("Token não encontrado. O usuário não está autenticado.");
      }

      print("Log: Token usado para enviar mensagem: $token");

      var request = http.MultipartRequest('POST', url);

      request.fields['message'] = message;
      request.fields['userId'] = userId;
      request.fields['userName'] = userName;

      request.headers['Authorization'] = 'Bearer $token';

      if (imagePath != null && imagePath.isNotEmpty) {
        print("Log: Adicionando imagem ao request: $imagePath");
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imagePath,
        ));
      }

      if (filePath != null && filePath.isNotEmpty) {
        print("Log: Adicionando arquivo ao request: $filePath");
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          filePath,
        ));
      }

      print("Log: Enviando mensagem com request: ${request.fields}");

      final response = await request.send();

      print(
          "Log: Status Code da resposta de sendMessage: ${response.statusCode}");

      if (response.statusCode == 201) {
        final respStr = await response.stream.bytesToString();
        final jsonResponse = json.decode(respStr);
        final newMessage = ChatMessage.fromJson(jsonResponse);

        print("Log: Mensagem enviada com sucesso: $newMessage");

        _messages.add(newMessage);
        _messagesStreamController.add(_messages);
        notifyListeners();
      } else {
        print(
            "Log: Erro ao enviar mensagem. Status Code: ${response.statusCode}");
        throw Exception('Erro ao enviar mensagem: ${response.statusCode}');
      }
    } catch (error) {
      print("Log: Erro ao enviar mensagem: $error");
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
