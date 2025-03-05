import 'package:condoview/components/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:condoview/providers/aviso_provider.dart';
import 'package:condoview/models/aviso_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchTerm = '';
  String selectedCategory = 'Todos';
  List<Aviso> filteredData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AvisoProvider>(context, listen: false).fetchAvisos();
    });
  }

  void filterData(List<Aviso> avisos) {
    setState(() {
      filteredData = avisos.where((aviso) {
        final matchTerm = searchTerm.isEmpty ||
            aviso.title.toLowerCase().contains(searchTerm.toLowerCase());
        final matchCategory =
            selectedCategory == 'Todos' || aviso.title == selectedCategory;
        return matchTerm && matchCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final avisoProvider = Provider.of<AvisoProvider>(context);
    final allAvisos = avisoProvider.avisos;

    // Filtrar os dados sempre que os avisos forem atualizados
    filterData(allAvisos);

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
          'Histórico de comunicações',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Pesquisar por título',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchTerm = value;
                });
                filterData(allAvisos);
              },
            ),
            const SizedBox(height: 16.0),
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
                filterData(allAvisos);
              },
              items: <String>['Todos', 'Mensagem', 'Aviso']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: avisoProvider.avisos.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final aviso = filteredData[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(aviso.title),
                            subtitle:
                                Text('${aviso.description} - ${aviso.time}'),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(aviso.title),
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Descrição: ${aviso.description}'),
                                      Text('Data: ${aviso.time}'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('Fechar'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          Navigator.pushNamed(context, _getRouteName(index));
        },
      ),
    );
  }

  String _getRouteName(int index) {
    switch (index) {
      case 0:
        return '/home';
      case 1:
        return '/search';
      case 2:
        return '/condominio';
      case 3:
        return '/conversas';
      default:
        return '/home';
    }
  }
}
