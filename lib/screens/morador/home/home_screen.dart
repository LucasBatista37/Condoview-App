import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:condoview/components/custom_bottom_navigation_bar.dart';
import 'package:condoview/components/custom_drawer.dart';
import 'package:condoview/components/admin_grid.dart';
import 'package:condoview/components/menu_grid.dart';
import 'package:condoview/providers/usuario_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> confirmEmail(String token) async {
    final response = await http.get(
      Uri.parse('https://backend-condoview.onrender.com/confirm/$token'),
    );

    if (response.statusCode == 200) {
      print("E-mail confirmado com sucesso!");
    } else {
      print("Erro ao confirmar o e-mail: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final userName = usuarioProvider.userName;
    final userProfileImage = usuarioProvider.userProfileImage;

    print('Log: Nome do usuário na HomeScreen: $userName');
    print('Log: URL da imagem de perfil na HomeScreen: $userProfileImage');

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 78, 20, 166),
        elevation: 1,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 24,
              child: userProfileImage.isEmpty
                  ? CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade300,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(userProfileImage),
                      onBackgroundImageError: (_, __) {
                        print('Log: Erro ao carregar imagem de perfil');
                      },
                    ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName.isNotEmpty ? userName : 'Usuário',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Condomínio Atlas',
              style: TextStyle(
                fontSize: 14,
                color: Color.fromARGB(136, 255, 255, 255),
              ),
            ),
          ],
        ),
        actions: const [
          SizedBox(width: 48),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bem-vindo, você tem três novas notificações!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildNotificationCard(
                      'Conversas', 'Oi! Tudo bem?', 'De: Mario'),
                  _buildNotificationCard(
                      'Manutenção',
                      'Manutenção da piscina dia 25 de julho das 8h às 12h',
                      'De: João'),
                  _buildNotificationCard(
                      'Avisos',
                      'Não haverá coleta de lixo na sexta-feira',
                      'De: Administração'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Seções',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Consumer<UsuarioProvider>(
              builder: (context, usuarioProvider, child) {
                final userRole = usuarioProvider.usuario?.role ?? 'morador';

                if (userRole == 'administrador') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Administração',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const AdminGrid(),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Menu Completo',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const MenuGrid(),
                    ],
                  );
                } else if (userRole == 'morador') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Menu Completo',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const MenuGrid(),
                    ],
                  );
                } else {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Role desconhecida: $userRole',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildNotificationCard(
      String title, String description, String sender) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Text(
          sender,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
