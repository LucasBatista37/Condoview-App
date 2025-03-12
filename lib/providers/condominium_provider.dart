import 'package:condoview/models/condominium_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CondoProvider with ChangeNotifier {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.1.3:5000';

  Future<void> createCondo(Condominium condo) async {
    final url = Uri.parse('$_baseUrl/api/users/admin/create-condominium');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(condo.toJson()),
      );

      if (response.statusCode == 201) {
        jsonDecode(response.body);
      } else if (response.statusCode == 422) {
      } else {
      }
    } catch (error) {
      print('Erro de conexão: $error');
    }
  }
}
