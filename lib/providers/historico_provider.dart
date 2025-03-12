import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HistoricoProvider with ChangeNotifier {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.1.3:5000';

  List<dynamic> _avisos = [];
  List<dynamic> _assembleias = [];
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
}
