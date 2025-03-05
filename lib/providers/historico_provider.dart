import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HistoricoProvider with ChangeNotifier {
  final String _baseUrl = 'https://backend-condoview.onrender.com';
  List<dynamic> _avisos = [];
  List<dynamic> _assembleias = [];
  Timer? _pollingTimer;

  List<dynamic> get avisos => _avisos;
  List<dynamic> get assembleias => _assembleias;

  Future<void> fetchAvisos() async {
    final url = Uri.parse('$_baseUrl/api/users/admin/notices');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _avisos = data;
        notifyListeners();
      } else {
        throw Exception('Falha ao carregar avisos: ${response.body}');
      }
    } catch (error) {
      print('Erro ao buscar avisos: $error');
    }
  }

  Future<void> fetchAssembleias() async {
    final url = Uri.parse('$_baseUrl/api/users/admin/assemblies');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _assembleias = data;
        notifyListeners();
      } else {
        throw Exception('Erro ao carregar assembleias: ${response.body}');
      }
    } catch (error) {
      print('Erro ao buscar assembleias: $error');
    }
  }

  void startPolling() {
    stopPolling();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchAssembleias();
      fetchAvisos();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
