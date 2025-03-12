import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:condoview/models/manutencao_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ManutencaoProvider with ChangeNotifier {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.1.3:5000';
  List<Manutencao> _manutencoes = [];

  List<Manutencao> get manutencoes => _manutencoes;

  Future<void> adicionarManutencao(Manutencao manutencao) async {
    final url = Uri.parse('$_baseUrl/api/users/maintenance');

    try {
      var request = http.MultipartRequest('POST', url);

      request.fields['type'] = manutencao.tipo;
      request.fields['descriptionMaintenance'] = manutencao.descricao;
      request.fields['dataMaintenance'] = manutencao.data.toIso8601String();
      request.fields['usuarioNome'] = manutencao.usuarioNome; 

      if (manutencao.imagemPath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'imagePath',
          manutencao.imagemPath!,
        ));
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        notifyListeners();
      } else {
        throw Exception('Erro ao solicitar manutenção');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchManutencoes() async {
    final url = Uri.parse('$_baseUrl/api/users/admin/maintenance');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _manutencoes = data.map((item) => Manutencao.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Erro ao obter manutenções');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> atualizarManutencao(
      Manutencao manutencao, String manutencaoId) async {
    final url = Uri.parse('$_baseUrl/admin/maintenance/$manutencaoId');

    try {
      var request = http.MultipartRequest('PUT', url);

      request.fields['type'] = manutencao.tipo;
      request.fields['descriptionMaintenance'] = manutencao.descricao;
      request.fields['dataMaintenance'] = manutencao.data.toIso8601String();
      request.fields['status'] = manutencao.status;

      if (manutencao.imagemPath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'imagePath',
          manutencao.imagemPath!,
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        notifyListeners();
      } else {
        throw Exception('Erro ao atualizar manutenção');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deletarManutencao(String manutencaoId) async {
    final url = Uri.parse('$_baseUrl/admin/maintenance/$manutencaoId');

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        notifyListeners();
      } else {
        throw Exception('Erro ao deletar manutenção');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> aprovarManutencao(String manutencaoId) async {
    final url = Uri.parse(
        '$_baseUrl/api/users/admin/maintenance/approve/$manutencaoId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final index = _manutencoes.indexWhere((m) => m.id == manutencaoId);
        if (index != -1) {
          _manutencoes[index].status = 'Aprovada';
          _manutencoes[index].statusColor = Colors.green;
        }
        notifyListeners();
      } else {
        throw Exception('Erro ao aprovar manutenção: ${response.body}');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> rejeitarManutencao(String manutencaoId) async {
    final url =
        Uri.parse('$_baseUrl/api/users/admin/maintenance/reject/$manutencaoId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final index = _manutencoes.indexWhere((m) => m.id == manutencaoId);
        if (index != -1) {
          _manutencoes[index].status = 'Rejeitada';
          _manutencoes[index].statusColor = Colors.red;
        }
        notifyListeners();
      } else {
        throw Exception('Erro ao rejeitar manutenção: ${response.body}');
      }
    } catch (error) {
      rethrow;
    }
  }
}
