import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MoradorProvider with ChangeNotifier {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.1.3:5000';

  Future<void> adicionarMorador(
      String email, String telefone, String funcionalidade) async {
    if (email.isEmpty || telefone.isEmpty || funcionalidade.isEmpty) {
      throw Exception('Por favor, preencha todos os campos!');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/admin/associate'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'telefone': telefone,
        'funcionalidade': funcionalidade,
      }),
    );

    if (response.statusCode != 200) {
      final errorResponse = json.decode(response.body);
      throw Exception(errorResponse['errors'][0]);
    }

    notifyListeners();
  }
}
