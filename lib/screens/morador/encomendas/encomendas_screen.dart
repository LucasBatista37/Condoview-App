import 'dart:async';
import 'package:condoview/components/custom_empty.dart';
import 'package:condoview/models/encomenda_model.dart';
import 'package:condoview/providers/encomenda_provider.dart';
import 'package:condoview/screens/morador/encomendas/encomendas_detalhes_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EncomendasScreen extends StatefulWidget {
  const EncomendasScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EncomendasScreenState createState() => _EncomendasScreenState();
}

class _EncomendasScreenState extends State<EncomendasScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    final encomendasProvider =
        Provider.of<EncomendasProvider>(context, listen: false);

    debugPrint("Iniciando a busca por encomendas...");
    encomendasProvider.fetchEncomendas();

    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      debugPrint("Executando polling para buscar encomendas...");
      encomendasProvider.fetchEncomendas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 78, 20, 166),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Encomendas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<EncomendasProvider>(
        builder: (context, encomendasProvider, child) {
          debugPrint("Status de carregamento: ${encomendasProvider.isLoading}");
          if (encomendasProvider.encomendas.isEmpty &&
              encomendasProvider.isLoading) {
            debugPrint("Carregando encomendas...");
            return const Center(child: CircularProgressIndicator());
          } else if (encomendasProvider.encomendas.isEmpty) {
            debugPrint("Nenhuma encomenda registrada.");
            return const CustomEmpty(text: "Nenhuma encomenda registrada.");
          } else {
            debugPrint(
                "Encomendas carregadas: ${encomendasProvider.encomendas.length}");
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: encomendasProvider.encomendas.length,
                itemBuilder: (context, index) {
                  final encomenda = encomendasProvider.encomendas[index];
                  debugPrint(
                      "Processando encomenda: ${encomenda.title}, Caminho da imagem: ${encomenda.imagePath}");
                  return _buildEncomendaItem(context, encomenda);
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEncomendaItem(BuildContext context, Encomenda encomenda) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: encomenda.imagePath.isNotEmpty
              ? Builder(
                  builder: (context) {
                    final imageUrl =
                        'https://backend-condoview.onrender.com/uploads/package/${encomenda.imagePath.replaceAll(r'\', '/')}';
                    debugPrint(
                        'Caminho da imagem da encomenda corrigido: $imageUrl');

                    return Image.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        debugPrint(
                            'Carregando imagem... Progresso: ${loadingProgress.expectedTotalBytes != null ? (loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!) * 100 : 'indefinido'}%');
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint(
                            'Erro ao carregar a imagem da encomenda: $error');
                        return const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.red,
                        );
                      },
                    );
                  },
                )
              : const Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.grey,
                ),
        ),
        title: Text(encomenda.title),
        subtitle: Text('${encomenda.apartment}\n${encomenda.time}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_forward),
            const SizedBox(height: 4),
            Text(
              encomenda.status,
              style: TextStyle(
                color: encomenda.status == 'Entregue'
                    ? Colors.green
                    : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  EncomendaDetalhesScreen(encomenda: encomenda),
            ),
          );
        },
      ),
    );
  }
}
