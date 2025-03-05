import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:condoview/models/aviso_model.dart';
import 'package:logger/logger.dart';
import 'package:condoview/services/secure_storege_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AvisoProvider with ChangeNotifier {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.1.3:5000';

  List<Aviso> _avisos = [];
  Timer? _pollingTimer;

  final SecureStorageService _secureStorageService = SecureStorageService();
  final logger = Logger();

  List<Aviso> get avisos => _avisos;

  Future<void> addAviso(Aviso aviso) async {
    final url = Uri.parse('$_baseUrl/api/users/admin/notices');

    final requestBody = {
      'title': aviso.title,
      'message': aviso.description,
      'date': DateTime.now().toIso8601String(),
    };

    try {
      final token = await _secureStorageService.loadToken();
      if (token == null) {
        throw Exception(
            'Token não encontrado. O usuário não está autenticado.');
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        logger.i('Aviso adicionado com sucesso: ${response.body}');
      } else {
        logger.e('Falha ao adicionar aviso: ${response.body}');
        throw Exception('Falha ao adicionar aviso: ${response.body}');
      }
    } catch (error, stacktrace) {
      logger.e('Erro ao adicionar aviso', error: error, stackTrace: stacktrace);
      rethrow;
    }
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      fetchAvisos();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchAvisos() async {
    final url = Uri.parse('$_baseUrl/api/users/admin/notices');

    try {
      final token = await _secureStorageService.loadToken();
      if (token == null) {
        throw Exception(
            'Token não encontrado. O usuário não está autenticado.');
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _avisos = data.map((aviso) => Aviso.fromJson(aviso)).toList();
        notifyListeners();
      } else {
        throw Exception('Falha ao carregar avisos: ${response.body}');
      }
    } catch (error) {
      logger.e('Erro ao carregar avisos', error: error);
      rethrow;
    }
  }

  Future<void> updateAviso(Aviso aviso) async {
    final url = Uri.parse('$_baseUrl/api/users/admin/notices/${aviso.id}');

    final requestBody = {
      'title': aviso.title,
      'message': aviso.description,
      'date': aviso.time,
    };

    try {
      final token = await _secureStorageService.loadToken();
      if (token == null) {
        throw Exception(
            'Token não encontrado. O usuário não está autenticado.');
      }

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final updatedAviso = Aviso.fromJson(json.decode(response.body));
        int index = _avisos.indexWhere((a) => a.id == aviso.id);
        if (index != -1) {
          _avisos[index] = updatedAviso;
          notifyListeners();
        }
      } else {
        throw Exception('Falha ao atualizar aviso: ${response.body}');
      }
    } catch (error) {
      logger.e('Erro ao atualizar aviso', error: error);
      rethrow;
    }
  }

  Future<void> removeAviso(Aviso aviso) async {
    final url = Uri.parse('$_baseUrl/api/users/admin/notices/${aviso.id}');

    try {
      final token = await _secureStorageService.loadToken();
      if (token == null) {
        throw Exception(
            'Token não encontrado. O usuário não está autenticado.');
      }

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _avisos.removeWhere((a) => a.id == aviso.id);
        notifyListeners();
      } else {
        throw Exception('Falha ao excluir aviso: ${response.body}');
      }
    } catch (error) {
      logger.e('Erro ao excluir aviso', error: error);
      rethrow;
    }
  }

  Aviso getAvisoById(String id) {
    return _avisos.firstWhere(
      (aviso) => aviso.id == id,
      orElse: () {
        throw Exception('Aviso com ID $id não encontrado');
      },
    );
  }
}
